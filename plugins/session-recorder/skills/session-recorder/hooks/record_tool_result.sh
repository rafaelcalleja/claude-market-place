#!/bin/bash
# record_tool_result.sh - PostToolUse hook
# Records tool calls and their results to the session log
#
# This hook runs after any tool completes. It receives tool name,
# arguments, and result via stdin as JSON.

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
LOG_DIR="${PROJECT_DIR}/.claude/session_logs"
TODAY=$(date -u +"%Y-%m-%d")
SESSION_FILE="${LOG_DIR}/session_${TODAY}.json"
LOCK_FILE="${LOG_DIR}/.session.lock"

# Maximum size for tool result content (to avoid bloating logs)
MAX_RESULT_SIZE=10000

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
# Truncate Large Content
# ============================================================================

truncate_content() {
    local content="$1"
    local max_size="${2:-$MAX_RESULT_SIZE}"

    local content_length=${#content}

    if [ $content_length -gt $max_size ]; then
        local truncated="${content:0:$max_size}"
        echo "${truncated}... [truncated, original size: ${content_length} chars]"
    else
        echo "${content}"
    fi
}

# ============================================================================
# Record Tool Usage
# ============================================================================

record_tool_usage() {
    local input="$1"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Extract tool information from hook input
    local tool_name
    tool_name=$(echo "${input}" | jq -r '.tool_name // "unknown"' 2>/dev/null)

    local tool_input
    tool_input=$(echo "${input}" | jq -c '.tool_input // {}' 2>/dev/null)

    local tool_result
    tool_result=$(echo "${input}" | jq -c '.tool_result // null' 2>/dev/null)

    # Truncate large results to avoid bloating logs
    local result_str
    result_str=$(echo "${tool_result}" | jq -r '. | tostring' 2>/dev/null || echo "${tool_result}")
    local truncated_result
    truncated_result=$(truncate_content "${result_str}" $MAX_RESULT_SIZE)

    # Generate UUIDs for both interactions
    local call_id=$(generate_uuid)
    local result_id=$(generate_uuid)

    # Create tool_call interaction
    local tool_call_interaction=$(jq -n \
        --arg id "${call_id}" \
        --arg ts "${timestamp}" \
        --arg tool "${tool_name}" \
        --argjson args "${tool_input}" \
        '{
            interaction_id: $id,
            timestamp: $ts,
            type: "tool_call",
            content: {
                tool: $tool,
                arguments: $args
            },
            metadata: {
                hook: "PostToolUse"
            }
        }')

    # Create tool_result interaction (slightly later timestamp)
    local result_timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Properly escape the truncated result for JSON
    local escaped_result
    escaped_result=$(echo "${truncated_result}" | jq -Rs '.')

    local tool_result_interaction=$(jq -n \
        --arg id "${result_id}" \
        --arg ts "${result_timestamp}" \
        --arg tool "${tool_name}" \
        --arg call_ref "${call_id}" \
        --argjson result "${escaped_result}" \
        '{
            interaction_id: $id,
            timestamp: $ts,
            type: "tool_result",
            content: {
                tool: $tool,
                result: $result,
                tool_call_id: $call_ref
            },
            metadata: {
                hook: "PostToolUse"
            }
        }')

    # Acquire lock for atomic update
    if ! acquire_lock 10; then
        echo "Warning: Could not acquire lock, skipping tool recording" >&2
        return 1
    fi
    trap 'release_lock' EXIT

    # Ensure session file exists
    if ! ensure_session_file; then
        return 1
    fi

    # Append both interactions to session file
    local temp_file="${SESSION_FILE}.tmp.$$"

    if jq --argjson call "${tool_call_interaction}" \
          --argjson result "${tool_result_interaction}" \
          '.interactions += [$call, $result]' \
          "${SESSION_FILE}" > "${temp_file}" 2>/dev/null; then
        mv "${temp_file}" "${SESSION_FILE}"
    else
        rm -f "${temp_file}" 2>/dev/null
        echo "Error: Failed to update session file" >&2
        return 1
    fi

    return 0
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    # Read hook input from stdin
    local input
    input=$(cat)

    # Check for jq dependency
    if ! command -v jq &>/dev/null; then
        echo '{"continue": true}'
        exit 0
    fi

    # Record the tool usage
    if record_tool_usage "${input}"; then
        echo '{"continue": true}'
    else
        # Don't block even if recording fails
        echo '{"continue": true}'
    fi
}

main "$@"
