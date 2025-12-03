#!/bin/bash
# session_init.sh - SessionStart hook
# Creates a new session log file with initial structure
#
# This hook runs when a Claude Code session starts.
# It generates a unique session ID, creates the log directory,
# and initializes the session log file with metadata.

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

# Use CLAUDE_PROJECT_DIR if available, otherwise fall back to current directory
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
LOG_DIR="${PROJECT_DIR}/.claude/session_logs"
TODAY=$(date -u +"%Y-%m-%d")
SESSION_FILE="${LOG_DIR}/session_${TODAY}.json"

# ============================================================================
# Dependency Check
# ============================================================================

check_dependencies() {
    local missing=()

    if ! command -v jq &>/dev/null; then
        missing+=("jq")
    fi

    if ! command -v uuidgen &>/dev/null; then
        # Try alternative UUID generation methods
        if ! command -v uuid &>/dev/null && [ ! -f /proc/sys/kernel/random/uuid ]; then
            missing+=("uuidgen or uuid")
        fi
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        echo "Warning: Missing dependencies: ${missing[*]}" >&2
        echo "Session recording may not work correctly." >&2
        return 1
    fi
    return 0
}

# ============================================================================
# UUID Generation
# ============================================================================

generate_uuid() {
    # Try multiple methods for UUID generation
    if command -v uuidgen &>/dev/null; then
        uuidgen
    elif command -v uuid &>/dev/null; then
        uuid
    elif [ -f /proc/sys/kernel/random/uuid ]; then
        cat /proc/sys/kernel/random/uuid
    else
        # Fallback: generate pseudo-UUID using date and random
        local timestamp=$(date +%s%N)
        local random=$(head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n')
        echo "${timestamp:0:8}-${random:0:4}-4${random:4:3}-${random:7:4}-${random:11:12}"
    fi
}

# ============================================================================
# File Locking
# ============================================================================

# Acquire lock with timeout (prevents race conditions)
acquire_lock() {
    local lock_file="$1"
    local timeout="${2:-10}"
    local count=0

    while [ -f "${lock_file}" ] && [ $count -lt $timeout ]; do
        sleep 0.1
        count=$((count + 1))
    done

    if [ $count -ge $timeout ]; then
        echo "Warning: Could not acquire lock after ${timeout}s" >&2
        return 1
    fi

    echo $$ > "${lock_file}"
    return 0
}

# Release lock
release_lock() {
    local lock_file="$1"
    rm -f "${lock_file}" 2>/dev/null || true
}

# ============================================================================
# Session Initialization
# ============================================================================

init_session() {
    local lock_file="${LOG_DIR}/.session.lock"

    # Ensure log directory exists
    mkdir -p "${LOG_DIR}"

    # Acquire lock for atomic operations
    if ! acquire_lock "${lock_file}" 10; then
        echo "Warning: Proceeding without lock" >&2
    fi

    # Trap to ensure lock is released on exit
    trap "release_lock '${lock_file}'" EXIT

    # Generate session ID
    local session_id=$(generate_uuid)
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Check if session file already exists for today
    if [ -f "${SESSION_FILE}" ]; then
        # Validate existing file
        if jq empty "${SESSION_FILE}" 2>/dev/null; then
            # File is valid JSON, check if session is still active
            local existing_end=$(jq -r '.end_timestamp // "null"' "${SESSION_FILE}" 2>/dev/null)

            if [ "${existing_end}" = "null" ] || [ -z "${existing_end}" ]; then
                # Previous session wasn't finalized properly
                # Create backup and start fresh
                local backup_file="${SESSION_FILE}.backup.$(date +%s)"
                cp "${SESSION_FILE}" "${backup_file}"
                echo "Backed up incomplete session to: ${backup_file}" >&2
            fi
        else
            # Invalid JSON, backup and recreate
            local backup_file="${SESSION_FILE}.invalid.$(date +%s)"
            mv "${SESSION_FILE}" "${backup_file}"
            echo "Backed up invalid session file to: ${backup_file}" >&2
        fi
    fi

    # Create new session structure
    local session_json=$(cat <<EOF
{
  "session_id": "${session_id}",
  "start_timestamp": "${timestamp}",
  "end_timestamp": null,
  "project_path": "${PROJECT_DIR}",
  "interactions": []
}
EOF
)

    # Write session file atomically
    echo "${session_json}" | jq '.' > "${SESSION_FILE}.tmp"
    mv "${SESSION_FILE}.tmp" "${SESSION_FILE}"

    # Store session ID for other hooks to reference
    echo "${session_id}" > "${LOG_DIR}/.current_session_id"

    # Output success message for Claude context
    cat <<EOF
{
  "continue": true,
  "systemMessage": "Session recording initialized. Session ID: ${session_id}. Logs stored in: ${SESSION_FILE}"
}
EOF
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    # Read hook input from stdin (even if not used, consume it)
    local input
    input=$(cat) || true

    # Check dependencies (warn but don't fail)
    check_dependencies || true

    # Initialize session
    init_session
}

main "$@"
