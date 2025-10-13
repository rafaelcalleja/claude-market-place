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

# If already initialized, exit silently
if [ -f "$INITIALIZED_FLAG" ]; then
    exit 0
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
        ((COUNT++))
    done < <(find "${PLUGIN_ROOT}/agents" -type f -name "*.md" -print0)
fi

# Process .md files in commands/ directory
if [ -d "${PLUGIN_ROOT}/commands" ]; then
    while IFS= read -r -d '' md_file; do
        expand_variables "$md_file" "$PLUGIN_ROOT"
        ((COUNT++))
    done < <(find "${PLUGIN_ROOT}/commands" -type f -name "*.md" -print0)
fi

# Create marker file with metadata
cat > "$INITIALIZED_FLAG" << EOF
Initialized at: $(date -Iseconds)
Files processed: $COUNT
Plugin root: $PLUGIN_ROOT
Script version: 1.0.0
EOF

# Success message (visible in transcript with Ctrl-R)
echo "✓ fabric-helper plugin initialized successfully"
echo "  📂 Root: $PLUGIN_ROOT"
echo "  📝 Files processed: $COUNT"
echo "  ℹ️  Variable expansion completed for all markdown files"

exit 0
