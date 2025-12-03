#!/bin/bash
# infer_topic.sh - Infer conversation topic from user intentions
# Usage: infer_topic.sh /path/to/conversation.jsonl

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

# Check for dependencies
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required" >&2
    exit 1
fi

if ! command -v fabric &> /dev/null; then
    echo "Warning: fabric not found, skipping AI summarization" >&2
    FABRIC_AVAILABLE=false
else
    FABRIC_AVAILABLE=true
fi

echo "=== CONVERSATION TOPIC INFERENCE ===" >&2
echo "" >&2

# Step 1: Extract Claude Code summaries (if available)
echo "[1/4] Checking for existing summaries..." >&2
SUMMARIES=$(jq -r 'select(.type == "summary") | .summary' "$CONVERSATION_FILE" 2>/dev/null || true)

if [[ -n "$SUMMARIES" ]]; then
    echo "Found existing summaries:" >&2
    echo "$SUMMARIES" >&2
    echo "" >&2

    # Use first summary as primary topic
    PRIMARY_TOPIC=$(echo "$SUMMARIES" | head -1)
    echo "Primary topic: $PRIMARY_TOPIC" >&2
else
    echo "No summaries found, will infer from user prompts" >&2
    PRIMARY_TOPIC=""
fi

# Step 2: Extract ONLY user messages (user intentions)
echo "[2/4] Extracting user intentions..." >&2
USER_MESSAGES=$(jq -r '
select(.type == "user") |
.message.content // "[no content]"
' "$CONVERSATION_FILE" 2>/dev/null || true)

if [[ -z "$USER_MESSAGES" ]]; then
    echo "Error: No user messages found in conversation" >&2
    exit 1
fi

USER_COUNT=$(echo "$USER_MESSAGES" | grep -c '^' || echo 0)
echo "Found $USER_COUNT user messages" >&2

# Save user messages to temp file
TEMP_USER_FILE=$(mktemp)
trap "rm -f $TEMP_USER_FILE" EXIT
echo "$USER_MESSAGES" > "$TEMP_USER_FILE"

# Step 3: Analyze user intent with Fabric (if available)
if [[ "$FABRIC_AVAILABLE" == "true" ]]; then
    echo "[3/4] Analyzing user intent with Fabric..." >&2

    # Extract the core problem/objective from user messages
    INFERRED_OBJECTIVE=$(cat "$TEMP_USER_FILE" | fabric -p extract_primary_problem 2>/dev/null | head -5 || echo "")

    # Get a brief summary
    INFERRED_SUMMARY=$(cat "$TEMP_USER_FILE" | fabric -p summarize 2>/dev/null | head -3 || echo "")

    if [[ -n "$INFERRED_OBJECTIVE" ]]; then
        echo "Inferred objective:" >&2
        echo "$INFERRED_OBJECTIVE" >&2
    fi

    if [[ -n "$INFERRED_SUMMARY" ]]; then
        echo "" >&2
        echo "Inferred summary:" >&2
        echo "$INFERRED_SUMMARY" >&2
    fi
else
    echo "[3/4] Skipping Fabric analysis (not available)" >&2
    INFERRED_OBJECTIVE=""
    INFERRED_SUMMARY=""
fi

# Step 4: Generate topic summary
echo "" >&2
echo "[4/4] Generating topic summary..." >&2
echo "" >&2

# Output structured JSON
jq -n \
    --arg primary_topic "$PRIMARY_TOPIC" \
    --arg user_count "$USER_COUNT" \
    --arg inferred_objective "$INFERRED_OBJECTIVE" \
    --arg inferred_summary "$INFERRED_SUMMARY" \
    --arg first_user_msg "$(echo "$USER_MESSAGES" | head -1)" \
    --arg last_user_msg "$(echo "$USER_MESSAGES" | tail -1)" \
    '{
        primary_topic: $primary_topic,
        user_message_count: ($user_count | tonumber),
        inferred_objective: $inferred_objective,
        inferred_summary: $inferred_summary,
        first_user_message: $first_user_msg,
        last_user_message: $last_user_msg,
        suggested_skill_name: (
            if $primary_topic != "" then
                ($primary_topic | ascii_downcase | gsub("[^a-z0-9]+"; "-") | gsub("^-|-$"; ""))
            elif $inferred_objective != "" then
                ($inferred_objective | ascii_downcase | gsub("[^a-z0-9]+"; "-") | gsub("^-|-$"; "") | .[0:50])
            else
                "extracted-skill"
            end
        ),
        suggested_description: (
            if $inferred_summary != "" then
                $inferred_summary
            elif $primary_topic != "" then
                $primary_topic
            else
                "Skill extracted from conversation"
            end
        )
    }'
