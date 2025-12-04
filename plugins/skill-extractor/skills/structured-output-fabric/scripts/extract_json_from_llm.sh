#!/bin/bash
# extract_json_from_llm.sh - Extract clean JSON from LLM output
# Usage: extract_json_from_llm.sh <input_file>

set -euo pipefail

INPUT_FILE="${1:-/dev/stdin}"

if [[ "$INPUT_FILE" != "/dev/stdin" && ! -f "$INPUT_FILE" ]]; then
    echo "Error: File not found: $INPUT_FILE" >&2
    exit 1
fi

# Extract JSON from first { to last }
# Works even if LLM adds explanation text before/after
if [[ "$INPUT_FILE" == "/dev/stdin" ]]; then
    sed -n '/^{/,/^}/p'
else
    sed -n '/^{/,/^}/p' "$INPUT_FILE"
fi
