#!/bin/bash
# show_summaries.sh - Display Claude Code summaries from conversation files
# Usage: show_summaries.sh /path/to/conversation.jsonl [--verbose]

set -euo pipefail

CONVERSATION_FILE="${1:-}"
VERBOSE="${2:-}"

if [[ -z "$CONVERSATION_FILE" ]]; then
    echo "Usage: $0 /path/to/conversation.jsonl [--verbose]" >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  --verbose  Show timestamp and additional context for each summary" >&2
    exit 1
fi

if [[ ! -f "$CONVERSATION_FILE" ]]; then
    echo "Error: File not found: $CONVERSATION_FILE" >&2
    exit 1
fi

# Check for jq dependency
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required" >&2
    exit 1
fi

# Get file info
FILE_NAME=$(basename "$CONVERSATION_FILE")
SESSION_ID="${FILE_NAME%.jsonl}"

echo "=== SUMMARIES FROM CONVERSATION ===" >&2
echo "File: $CONVERSATION_FILE" >&2
echo "Session ID: $SESSION_ID" >&2
echo "" >&2

# Extract summaries
if [[ "$VERBOSE" == "--verbose" ]]; then
    # Verbose mode: show timestamp and context
    SUMMARY_COUNT=0
    while IFS= read -r line; do
        SUMMARY_COUNT=$((SUMMARY_COUNT + 1))
        SUMMARY=$(echo "$line" | jq -r '.summary')
        TIMESTAMP=$(echo "$line" | jq -r '.timestamp // "unknown"')

        echo "Summary #$SUMMARY_COUNT (timestamp: $TIMESTAMP):" >&2
        echo "$SUMMARY"
        echo "" >&2
    done < <(jq -c 'select(.type == "summary")' "$CONVERSATION_FILE")

    if [[ $SUMMARY_COUNT -eq 0 ]]; then
        echo "No summaries found in this conversation." >&2
        exit 0
    fi

    echo "Total summaries: $SUMMARY_COUNT" >&2
else
    # Simple mode: just show summaries
    SUMMARIES=$(jq -r 'select(.type == "summary") | .summary' "$CONVERSATION_FILE" 2>/dev/null || true)

    if [[ -z "$SUMMARIES" ]]; then
        echo "No summaries found in this conversation." >&2
        exit 0
    fi

    echo "$SUMMARIES"
    echo "" >&2

    SUMMARY_COUNT=$(echo "$SUMMARIES" | grep -c '^' || echo 0)
    echo "Total summaries: $SUMMARY_COUNT" >&2
fi
