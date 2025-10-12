#!/bin/bash
# Get a specific pattern from the Fabric library by name
# Usage: get-pattern.sh <pattern_name>

set -e

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
PATTERN_FILE="$PLUGIN_ROOT/.fabric-core/pattern_extracts.json"

if [ -z "$1" ]; then
    echo "Error: Pattern name required" >&2
    echo "Usage: get-pattern.sh <pattern_name>" >&2
    exit 1
fi

PATTERN_NAME="$1"

# Check if the pattern file exists
if [ ! -f "$PATTERN_FILE" ]; then
    echo "Error: Pattern library not found at $PATTERN_FILE" >&2
    exit 1
fi

# Extract the pattern using jq
PATTERN=$(jq -r ".patterns[] | select(.patternName==\"$PATTERN_NAME\") | .pattern_extract" "$PATTERN_FILE")

if [ -z "$PATTERN" ] || [ "$PATTERN" = "null" ]; then
    echo "Error: Pattern '$PATTERN_NAME' not found in library" >&2
    exit 1
fi

# Output the pattern
echo "$PATTERN"
