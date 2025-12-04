#!/bin/bash
# demo_approaches.sh - Quick demo of different approaches
# Usage: demo_approaches.sh <conversation.jsonl>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONVERSATION_FILE="${1:-}"

if [[ -z "$CONVERSATION_FILE" ]]; then
    echo "Usage: $0 <conversation.jsonl>" >&2
    exit 1
fi

echo "====================================================================="
echo "TOPIC INFERENCE APPROACHES DEMO"
echo "File: $CONVERSATION_FILE"
echo "====================================================================="
echo ""

# Source library
source "$SCRIPT_DIR/topic_inference_lib.sh"

# Preparar archivos de entrada
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

USER_MESSAGES="$TEMP_DIR/user_messages.txt"
CONVERSATION="$TEMP_DIR/conversation.txt"

echo "[Extracting user messages and conversation...]" >&2
extract_user_messages "$CONVERSATION_FILE" > "$USER_MESSAGES"
extract_full_conversation "$CONVERSATION_FILE" > "$CONVERSATION"

USER_COUNT=$(wc -l < "$USER_MESSAGES")
echo "User messages: $USER_COUNT" >&2
echo "" >&2

# =============================================================================
# Run each approach with timing
# =============================================================================

run_timed_approach() {
    local num="$1"
    local name="$2"
    local func="$3"
    local input="$4"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "[$num] $name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local start=$(date +%s)
    $func "$input" 2>&1 | jq -C '.' 2>/dev/null || $func "$input" 2>&1
    local end=$(date +%s)
    local duration=$((end - start))

    echo ""
    echo "⏱️  Time: ${duration}s"
    echo ""
}

# Run approaches
run_timed_approach "1" "Ultra-Concise" "approach_ultra_concise" "$USER_MESSAGES"
run_timed_approach "2" "Progressive Levels" "approach_progressive_levels" "$USER_MESSAGES"
run_timed_approach "3" "Insight Extraction" "approach_insight_extraction" "$USER_MESSAGES"
run_timed_approach "4" "Pattern Recognition" "approach_pattern_recognition" "$CONVERSATION"
run_timed_approach "5" "Temporal Segmentation" "approach_temporal_segmentation" "$CONVERSATION"
run_timed_approach "6" "Tags + Categorization" "approach_tags_categorization" "$USER_MESSAGES"
run_timed_approach "7" "Hybrid (Parallel)" "approach_hybrid" "$USER_MESSAGES"

echo "====================================================================="
echo "DEMO COMPLETE"
echo "====================================================================="
