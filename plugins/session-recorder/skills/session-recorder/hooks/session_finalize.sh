#!/bin/bash
# session_finalize.sh - SessionEnd hook
# Finalizes the session by updating the end timestamp
#
# This hook runs when a Claude Code session ends.
# It updates the end_timestamp and performs cleanup.

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
# Session Finalization
# ============================================================================

finalize_session() {
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Check if session file exists
    if [ ! -f "${SESSION_FILE}" ]; then
        echo "No session file to finalize" >&2
        return 0
    fi

    # Acquire lock
    if ! acquire_lock 10; then
        echo "Warning: Could not acquire lock for finalization" >&2
        return 1
    fi
    trap 'release_lock' EXIT

    # Validate session file
    if ! jq empty "${SESSION_FILE}" 2>/dev/null; then
        echo "Error: Invalid session file, cannot finalize" >&2
        return 1
    fi

    # Update end timestamp
    local temp_file="${SESSION_FILE}.tmp.$$"

    if jq --arg ts "${timestamp}" \
          '.end_timestamp = $ts' \
          "${SESSION_FILE}" > "${temp_file}" 2>/dev/null; then
        mv "${temp_file}" "${SESSION_FILE}"
    else
        rm -f "${temp_file}" 2>/dev/null
        echo "Error: Failed to finalize session" >&2
        return 1
    fi

    # Cleanup: remove current session ID file
    rm -f "${LOG_DIR}/.current_session_id" 2>/dev/null || true

    # Calculate session statistics
    local interaction_count
    interaction_count=$(jq '.interactions | length' "${SESSION_FILE}" 2>/dev/null || echo "0")

    local user_messages
    user_messages=$(jq '[.interactions[] | select(.type == "user_message")] | length' "${SESSION_FILE}" 2>/dev/null || echo "0")

    local tool_calls
    tool_calls=$(jq '[.interactions[] | select(.type == "tool_call")] | length' "${SESSION_FILE}" 2>/dev/null || echo "0")

    local assistant_summaries
    assistant_summaries=$(jq '[.interactions[] | select(.type == "assistant_summary")] | length' "${SESSION_FILE}" 2>/dev/null || echo "0")

    # Output success message
    cat <<EOF
{
  "continue": true,
  "systemMessage": "Session finalized. Total interactions: ${interaction_count} (${user_messages} user messages, ${tool_calls} tool calls, ${assistant_summaries} assistant summaries)"
}
EOF
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    # Read hook input from stdin (consume even if not used)
    local input
    input=$(cat) || true

    # Check for jq dependency
    if ! command -v jq &>/dev/null; then
        echo '{"continue": true}'
        exit 0
    fi

    # Finalize session
    if finalize_session; then
        : # Output already sent
    else
        echo '{"continue": true}'
    fi
}

main "$@"
