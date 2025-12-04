#!/bin/bash
# infer_topic_v2.sh - Modular topic inference with multiple approaches
# Usage: infer_topic_v2.sh <conversation.jsonl> [approach] [model]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the library
source "$SCRIPT_DIR/topic_inference_lib.sh"

# =============================================================================
# MAIN
# =============================================================================

show_usage() {
    cat <<EOF
Usage: $0 <conversation.jsonl> [approach] [model]

Arguments:
  conversation.jsonl  - Path to Claude Code conversation file
  approach            - Optional: approach number or name (default: 7/hybrid)
                        Use 'all' to run all approaches
  model               - Optional: Fabric model (default: claude-3-5-haiku-latest)

Examples:
  # Run hybrid approach (recommended)
  $0 conversation.jsonl

  # Run specific approach
  $0 conversation.jsonl ultra-concise
  $0 conversation.jsonl 1

  # Run all approaches for comparison
  $0 conversation.jsonl all

  # Use different model
  $0 conversation.jsonl hybrid claude-3-5-sonnet-latest

Available approaches:
$(list_approaches)
EOF
}

CONVERSATION_FILE="${1:-}"
APPROACH="${2:-hybrid}"
MODEL="${3:-claude-3-5-haiku-latest}"

if [[ -z "$CONVERSATION_FILE" ]]; then
    show_usage
    exit 1
fi

if [[ ! -f "$CONVERSATION_FILE" ]]; then
    echo "Error: File not found: $CONVERSATION_FILE" >&2
    exit 1
fi

# Check dependencies
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required" >&2
    exit 1
fi

# =============================================================================
# RUN APPROACHES
# =============================================================================

if [[ "$APPROACH" == "all" ]]; then
    echo "Running ALL approaches for comparison..." >&2
    echo "" >&2

    # Run all approaches and combine results
    results="[]"

    for i in {1..7}; do
        result=$(run_approach "$i" "$CONVERSATION_FILE" "$MODEL" 2>/dev/null || echo '{}')
        results=$(echo "$results" | jq ". += [$result]")
    done

    # Output combined results
    echo "$results" | jq '{
        file: "'"$CONVERSATION_FILE"'",
        model: "'"$MODEL"'",
        approaches: .
    }'
else
    # Run single approach
    run_approach "$APPROACH" "$CONVERSATION_FILE" "$MODEL"
fi
