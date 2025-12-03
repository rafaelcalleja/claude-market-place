#!/bin/bash
# record_user_prompt.sh - UserPromptSubmit hook
# Records user messages to the session log
#
# This hook receives the user's prompt via stdin as JSON and appends
# it to the current session's interactions array.

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
    # Check if session file exists
    if [ ! -f "${SESSION_FILE}" ]; then
        # Session wasn't initialized, create a minimal one
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

    # Validate JSON structure
    if ! jq empty "${SESSION_FILE}" 2>/dev/null; then
        echo "Error: Invalid session file JSON" >&2
        return 1
    fi

    return 0
}

# ============================================================================
# Record User Prompt
# ============================================================================

record_prompt() {
    local input="$1"
    local interaction_id=$(generate_uuid)
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Extract user prompt from hook input
    # UserPromptSubmit hook receives JSON with 'user_prompt' field
    local user_prompt
    user_prompt=$(echo "${input}" | jq -r '.user_prompt // empty' 2>/dev/null)

    # If user_prompt is empty, try 'prompt' field
    if [ -z "${user_prompt}" ]; then
        user_prompt=$(echo "${input}" | jq -r '.prompt // empty' 2>/dev/null)
    fi

    # If still empty, use the entire input as the prompt content
    if [ -z "${user_prompt}" ]; then
        user_prompt=$(echo "${input}" | jq -r '. | tostring' 2>/dev/null)
    fi

    # Escape the prompt for JSON embedding
    local escaped_prompt
    escaped_prompt=$(echo "${user_prompt}" | jq -Rs '.')

    # Create interaction object
    local interaction=$(cat <<EOF
{
  "interaction_id": "${interaction_id}",
  "timestamp": "${timestamp}",
  "type": "user_message",
  "content": ${escaped_prompt},
  "metadata": {
    "hook": "UserPromptSubmit"
  }
}
EOF
)

    # Acquire lock for atomic update
    if ! acquire_lock 10; then
        echo "Warning: Could not acquire lock, skipping user prompt recording" >&2
        return 1
    fi
    trap 'release_lock' EXIT

    # Ensure session file exists and is valid
    if ! ensure_session_file; then
        return 1
    fi

    # Append interaction to session file
    local temp_file="${SESSION_FILE}.tmp.$$"

    if jq --argjson interaction "${interaction}" \
        '.interactions += [$interaction]' \
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
        echo '{"continue": true}' # Don't block, just skip recording
        exit 0
    fi

    # Record the prompt
    if record_prompt "${input}"; then
        echo '{"continue": true}'
    else
        # Don't block the user even if recording fails
        echo '{"continue": true}'
    fi
}

main "$@"
