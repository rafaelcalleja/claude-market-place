#!/bin/bash
# Get the complete pattern descriptions library
# Usage: get-patterns-library.sh

set -e

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
PATTERN_FILE="$PLUGIN_ROOT/.fabric-core/pattern_descriptions.json"

# Check if the pattern file exists
if [ ! -f "$PATTERN_FILE" ]; then
    echo "Error: Pattern library not found at $PATTERN_FILE" >&2
    exit 1
fi

# Output the pattern library
cat "$PATTERN_FILE"
