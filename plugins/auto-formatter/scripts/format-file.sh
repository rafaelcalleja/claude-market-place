#!/bin/bash
#
# Auto-format file based on file type
# This script is called automatically after Write/Edit operations
#

set -e

# Get the file path from tool use context (would be passed by Claude Code)
# For demonstration, this shows the structure of a formatting script

format_file() {
    local filepath="$1"

    if [ ! -f "$filepath" ]; then
        return 0
    fi

    # Detect file type and run appropriate formatter
    case "$filepath" in
        *.js|*.jsx|*.ts|*.tsx)
            # Format JavaScript/TypeScript with prettier if available
            if command -v prettier &> /dev/null; then
                prettier --write "$filepath" 2>/dev/null || true
            elif command -v npx &> /dev/null; then
                npx prettier --write "$filepath" 2>/dev/null || true
            fi
            ;;
        *.py)
            # Format Python with black if available
            if command -v black &> /dev/null; then
                black "$filepath" 2>/dev/null || true
            fi
            ;;
        *.go)
            # Format Go with gofmt
            if command -v gofmt &> /dev/null; then
                gofmt -w "$filepath" 2>/dev/null || true
            fi
            ;;
        *.rs)
            # Format Rust with rustfmt
            if command -v rustfmt &> /dev/null; then
                rustfmt "$filepath" 2>/dev/null || true
            fi
            ;;
        *.json)
            # Format JSON with jq if available
            if command -v jq &> /dev/null; then
                jq '.' "$filepath" > "${filepath}.tmp" && mv "${filepath}.tmp" "$filepath" 2>/dev/null || true
            fi
            ;;
        *)
            # No formatter for this file type
            return 0
            ;;
    esac
}

# Main execution
# In actual use, Claude Code would pass the file path
# This is a demonstration of the hook structure
if [ $# -gt 0 ]; then
    format_file "$1"
fi
