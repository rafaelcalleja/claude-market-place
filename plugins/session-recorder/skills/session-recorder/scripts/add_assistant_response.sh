#!/bin/bash
# add_assistant_response.sh - Helper script for Claude self-reporting
# Allows Claude to explicitly log summaries of completed work
#
# Usage:
#   add_assistant_response.sh --summary "What was accomplished" \
#                             --actions "Key actions taken" \
#                             --tools "tool1,tool2,tool3"
#
# All arguments are optional but at least --summary should be provided.

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
LOG_DIR="${PROJECT_DIR}/.claude/session_logs"
TODAY=$(date -u +"%Y-%m-%d")
SESSION_FILE="${LOG_DIR}/session_${TODAY}.json"
LOCK_FILE="${LOG_DIR}/.session.lock"

# ============================================================================
# Help Message
# ============================================================================

show_help() {
    cat <<EOF
Usage: add_assistant_response.sh [OPTIONS]

Records an assistant summary to the current session log.

Options:
  --summary TEXT    Summary of what was accomplished (recommended)
  --actions TEXT    Key actions taken during the task
  --tools LIST      Comma-separated list of tools used (e.g., "Write,Bash,Read")
  --help            Show this help message

Examples:
  add_assistant_response.sh --summary "Created new API endpoint"

  add_assistant_response.sh \\
    --summary "Implemented user authentication" \\
    --actions "Created auth middleware, added JWT validation" \\
    --tools "Write,Edit,Bash"

  add_assistant_response.sh --summary "Fixed bug in data parser" \\
    --actions "Modified regex pattern, added error handling"

Notes:
  - At least --summary should be provided for meaningful logs
  - Session file is automatically created if it doesn't exist
  - Requires jq for JSON manipulation
EOF
}

# ============================================================================
# UUID Generation
# ============================================================================

generate_uuid() {
    if command -v uuidgen &>/dev/null; then
        uuidgen
    elif command -v uuid &>/dev/null; then
        uuid
    elif [ -f /proc/sys/kernel/random/uuid ]; then
        cat /proc/sys/kernel/random/uuid
    else
        local timestamp=$(date +%s%N)
        local random=$(head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n')
        echo "${timestamp:0:8}-${random:0:4}-4${random:4:3}-${random:7:4}-${random:11:12}"
    fi
}

# ============================================================================
# File Locking
# ============================================================================

acquire_lock() {
    local timeout="${1:-10}"
    local count=0
    local wait_time=0.1

    while [ -f "${LOCK_FILE}" ] && [ $count -lt $((timeout * 10)) ]; do
        sleep $wait_time
        count=$((count + 1))
    done

    if [ $count -ge $((timeout * 10)) ]; then
        return 1
    fi

    echo $$ > "${LOCK_FILE}"
    return 0
}

release_lock() {
    rm -f "${LOCK_FILE}" 2>/dev/null || true
}

# ============================================================================
# Session File Handling
# ============================================================================

ensure_session_file() {
    if [ ! -f "${SESSION_FILE}" ]; then
        mkdir -p "${LOG_DIR}"
        local session_id=$(generate_uuid)
        local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

        cat > "${SESSION_FILE}" <<EOF
{
  "session_id": "${session_id}",
  "start_timestamp": "${timestamp}",
  "end_timestamp": null,
  "project_path": "${PROJECT_DIR}",
  "interactions": []
}
EOF
        echo "${session_id}" > "${LOG_DIR}/.current_session_id"
    fi

    if ! jq empty "${SESSION_FILE}" 2>/dev/null; then
        echo "Error: Invalid session file JSON" >&2
        return 1
    fi

    return 0
}

# ============================================================================
# Find Most Recent Session File
# ============================================================================

find_session_file() {
    # First, try today's session file
    if [ -f "${SESSION_FILE}" ]; then
        echo "${SESSION_FILE}"
        return 0
    fi

    # Look for most recent session file
    local recent_file
    recent_file=$(ls -t "${LOG_DIR}"/session_*.json 2>/dev/null | head -1)

    if [ -n "${recent_file}" ] && [ -f "${recent_file}" ]; then
        echo "${recent_file}"
        return 0
    fi

    # No session file found, will create new one
    echo "${SESSION_FILE}"
    return 0
}

# ============================================================================
# Argument Parsing
# ============================================================================

parse_arguments() {
    SUMMARY=""
    ACTIONS=""
    TOOLS=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --summary)
                SUMMARY="$2"
                shift 2
                ;;
            --actions)
                ACTIONS="$2"
                shift 2
                ;;
            --tools)
                TOOLS="$2"
                shift 2
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo "Error: Unknown argument: $1" >&2
                echo "Use --help for usage information" >&2
                exit 1
                ;;
        esac
    done

    # Validate that at least summary is provided
    if [ -z "${SUMMARY}" ] && [ -z "${ACTIONS}" ] && [ -z "${TOOLS}" ]; then
        echo "Warning: No content provided. Use --summary, --actions, or --tools" >&2
        echo "Use --help for usage information" >&2
        # Don't exit with error, just warn
    fi
}

# ============================================================================
# Record Assistant Response
# ============================================================================

record_response() {
    local interaction_id=$(generate_uuid)
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Convert tools string to JSON array
    local tools_json="[]"
    if [ -n "${TOOLS}" ]; then
        tools_json=$(echo "${TOOLS}" | tr ',' '\n' | jq -R . | jq -s .)
    fi

    # Escape strings for JSON
    local summary_escaped
    summary_escaped=$(echo "${SUMMARY}" | jq -Rs '.')

    local actions_escaped
    actions_escaped=$(echo "${ACTIONS}" | jq -Rs '.')

    # Create interaction object
    local interaction=$(jq -n \
        --arg id "${interaction_id}" \
        --arg ts "${timestamp}" \
        --argjson summary "${summary_escaped}" \
        --argjson actions "${actions_escaped}" \
        --argjson tools "${tools_json}" \
        '{
            interaction_id: $id,
            timestamp: $ts,
            type: "assistant_summary",
            content: {
                summary: $summary,
                actions: $actions,
                tools_used: $tools
            },
            metadata: {
                source: "self_report"
            }
        }')

    # Find the session file to update
    local target_file
    target_file=$(find_session_file)

    # Acquire lock
    if ! acquire_lock 10; then
        echo "Error: Could not acquire lock" >&2
        return 1
    fi
    trap 'release_lock' EXIT

    # Ensure session file exists
    SESSION_FILE="${target_file}"
    if ! ensure_session_file; then
        return 1
    fi

    # Append interaction
    local temp_file="${SESSION_FILE}.tmp.$$"

    if jq --argjson interaction "${interaction}" \
          '.interactions += [$interaction]' \
          "${SESSION_FILE}" > "${temp_file}" 2>/dev/null; then
        mv "${temp_file}" "${SESSION_FILE}"
        echo "Assistant response recorded successfully"
        return 0
    else
        rm -f "${temp_file}" 2>/dev/null
        echo "Error: Failed to record assistant response" >&2
        return 1
    fi
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    # Check for jq dependency
    if ! command -v jq &>/dev/null; then
        echo "Error: jq is required but not installed" >&2
        echo "Install with: apt-get install jq (Debian/Ubuntu) or brew install jq (macOS)" >&2
        exit 1
    fi

    # Parse arguments
    parse_arguments "$@"

    # Record the response
    record_response
}

main "$@"
