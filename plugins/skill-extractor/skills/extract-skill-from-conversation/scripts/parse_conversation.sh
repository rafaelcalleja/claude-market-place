#!/bin/bash
# parse_conversation.sh - Convert Claude Code JSONL conversation to readable text
# Usage: parse_conversation.sh /path/to/conversation.jsonl

set -euo pipefail

CONVERSATION_FILE="${1:-}"

if [[ -z "$CONVERSATION_FILE" ]]; then
    echo "Usage: $0 /path/to/conversation.jsonl" >&2
    exit 1
fi

if [[ ! -f "$CONVERSATION_FILE" ]]; then
    echo "Error: File not found: $CONVERSATION_FILE" >&2
    exit 1
fi

# Check for jq
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed" >&2
    exit 1
fi

# Extract summaries first (context)
echo "=== CONVERSATION SUMMARIES ==="
jq -r 'select(.type == "summary") | "Topic: \(.summary)"' "$CONVERSATION_FILE" 2>/dev/null || true
echo ""

# Extract user and assistant messages
jq -r '
select(.type == "user" or .type == "assistant") |
if .type == "user" then
  "=== USER ===\n\(.message.content // "[no content]")\n"
elif .type == "assistant" then
  if .message.content then
    if (.message.content | type) == "string" then
      "=== ASSISTANT ===\n\(.message.content)\n"
    elif (.message.content | type) == "array" then
      "=== ASSISTANT ===\n" + (.message.content | map(
        if .type == "text" then
          .text
        elif .type == "tool_use" then
          "[TOOL: \(.name)] \(.input | tostring | .[0:200])..."
        else
          "[unknown content type]"
        end
      ) | join("\n")) + "\n"
    else
      "=== ASSISTANT ===\n[complex content]\n"
    end
  else
    ""
  end
else
  ""
end
' "$CONVERSATION_FILE" 2>/dev/null

# Extract tool results (abbreviated)
echo ""
echo "=== TOOL CALLS SUMMARY ==="
jq -r '
select(.type == "assistant") |
.message.content // [] |
if type == "array" then
  .[] | select(.type == "tool_use") | "- \(.name): \(.input | tostring | .[0:100])..."
else
  empty
end
' "$CONVERSATION_FILE" 2>/dev/null | head -50 || true
