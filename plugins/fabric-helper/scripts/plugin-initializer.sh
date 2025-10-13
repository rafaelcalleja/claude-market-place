#!/bin/bash

# Script: plugin-initializer.sh
# Purpose: Expand ${CLAUDE_PLUGIN_ROOT} variables in markdown files
# Usage: plugin-initializer.sh <PLUGIN_ROOT_PATH>
#
# This is a workaround for Claude Code slash commands not resolving
# ${CLAUDE_PLUGIN_ROOT} variables, while hooks do resolve them.

set -euo pipefail

# Receive CLAUDE_PLUGIN_ROOT as argument
PLUGIN_ROOT="$1"

# Marker file to check if already initialized
INITIALIZED_FLAG="${PLUGIN_ROOT}/.initialized"
PLUGIN_JSON="${PLUGIN_ROOT}/.claude-plugin/plugin.json"

# Get current plugin version from plugin.json
if [ -f "$PLUGIN_JSON" ]; then
    CURRENT_VERSION=$(grep -Po '"version":\s*"\K[^"]+' "$PLUGIN_JSON" 2>/dev/null || echo "unknown")
else
    CURRENT_VERSION="unknown"
fi

# Check if already initialized with same version
REINITIALIZING=false
if [ -f "$INITIALIZED_FLAG" ]; then
    INITIALIZED_VERSION=$(grep -Po 'Plugin version:\s*\K.*' "$INITIALIZED_FLAG" 2>/dev/null || echo "unknown")

    if [ "$INITIALIZED_VERSION" = "$CURRENT_VERSION" ]; then
        # Same version, skip initialization
        exit 0
    fi

    # Different version detected, will re-initialize
    REINITIALIZING=true
fi

# Verify plugin root directory exists
if [ ! -d "$PLUGIN_ROOT" ]; then
    echo "Error: Plugin root does not exist: $PLUGIN_ROOT" >&2
    exit 1
fi

# Function to expand variables in markdown files
expand_variables() {
    local file="$1"
    local plugin_root="$2"

    # Create temporary backup
    cp "$file" "${file}.bak"

    # Expand both ${CLAUDE_PLUGIN_ROOT} and $CLAUDE_PLUGIN_ROOT
    sed -i "s|\${CLAUDE_PLUGIN_ROOT}|${plugin_root}|g" "$file"
    sed -i "s|\$CLAUDE_PLUGIN_ROOT\([^}]\)|${plugin_root}\1|g" "$file"

    # Remove backup if successful
    rm -f "${file}.bak"
}

# Counter for processed files
COUNT=0

# Process .md files in agents/ directory
if [ -d "${PLUGIN_ROOT}/agents" ]; then
    while IFS= read -r -d '' md_file; do
        expand_variables "$md_file" "$PLUGIN_ROOT"
        COUNT=$((COUNT + 1))
    done < <(find "${PLUGIN_ROOT}/agents" -type f -name "*.md" -print0)
fi

# Process .md files in commands/ directory
if [ -d "${PLUGIN_ROOT}/commands" ]; then
    while IFS= read -r -d '' md_file; do
        expand_variables "$md_file" "$PLUGIN_ROOT"
        COUNT=$((COUNT + 1))
    done < <(find "${PLUGIN_ROOT}/commands" -type f -name "*.md" -print0)
fi

# Create marker file with metadata
cat > "$INITIALIZED_FLAG" << EOF
Initialized at: $(date -Iseconds)
Files processed: $COUNT
Plugin root: $PLUGIN_ROOT
Plugin version: $CURRENT_VERSION
EOF

# Output JSON with systemMessage for SessionStart hooks
# This ensures the message is shown to the user
if [ "$REINITIALIZING" = true ]; then
    MESSAGE="✓ Re-initialized fabric-helper v$CURRENT_VERSION ($COUNT files updated). Restart Claude Code to load changes."
else
    MESSAGE="✓ Initialized fabric-helper plugin v$CURRENT_VERSION ($COUNT files processed). Restart Claude Code to load changes."
fi

cat << EOF
{
  "systemMessage": "$MESSAGE"
}
EOF

exit 0
