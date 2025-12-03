#!/bin/bash
# extract_skill.sh - Full skill extraction pipeline using Fabric patterns
# Usage: extract_skill.sh /path/to/conversation.jsonl [output_dir]

set -euo pipefail

CONVERSATION_FILE="${1:-}"
OUTPUT_DIR="${2:-/tmp/skill_extraction}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -z "$CONVERSATION_FILE" ]]; then
    echo "Usage: $0 /path/to/conversation.jsonl [output_dir]" >&2
    exit 1
fi

if [[ ! -f "$CONVERSATION_FILE" ]]; then
    echo "Error: File not found: $CONVERSATION_FILE" >&2
    exit 1
fi

# Check for fabric
if ! command -v fabric &> /dev/null; then
    echo "Error: fabric is required but not installed" >&2
    echo "Install: go install github.com/danielmiessler/fabric@latest" >&2
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "=== SKILL EXTRACTION PIPELINE ==="
echo "Input: $CONVERSATION_FILE"
echo "Output: $OUTPUT_DIR"
echo ""

# Step 1: Parse conversation
echo "[1/5] Parsing conversation..."
bash "$SCRIPT_DIR/parse_conversation.sh" "$CONVERSATION_FILE" > "$OUTPUT_DIR/conversation.txt"
echo "  -> $OUTPUT_DIR/conversation.txt ($(wc -l < "$OUTPUT_DIR/conversation.txt") lines)"

# Step 2: Extract with Fabric patterns (parallel)
echo "[2/5] Extracting with Fabric patterns (parallel)..."

cat "$OUTPUT_DIR/conversation.txt" | fabric -p extract_wisdom > "$OUTPUT_DIR/wisdom.md" 2>&1 &
PID_WISDOM=$!

cat "$OUTPUT_DIR/conversation.txt" | fabric -p extract_instructions > "$OUTPUT_DIR/instructions.md" 2>&1 &
PID_INSTRUCTIONS=$!

cat "$OUTPUT_DIR/conversation.txt" | fabric -p extract_primary_problem > "$OUTPUT_DIR/problem.md" 2>&1 &
PID_PROBLEM=$!

cat "$OUTPUT_DIR/conversation.txt" | fabric -p extract_primary_solution > "$OUTPUT_DIR/solution.md" 2>&1 &
PID_SOLUTION=$!

# Wait for all extractions
wait $PID_WISDOM && echo "  -> wisdom.md extracted" || echo "  -> wisdom.md FAILED"
wait $PID_INSTRUCTIONS && echo "  -> instructions.md extracted" || echo "  -> instructions.md FAILED"
wait $PID_PROBLEM && echo "  -> problem.md extracted" || echo "  -> problem.md FAILED"
wait $PID_SOLUTION && echo "  -> solution.md extracted" || echo "  -> solution.md FAILED"

# Step 3: Summarize conversation topic
echo "[3/5] Generating summary..."
cat "$OUTPUT_DIR/conversation.txt" | fabric -p summarize > "$OUTPUT_DIR/summary.md" 2>&1 || true
echo "  -> summary.md generated"

# Step 4: Combine into skill draft
echo "[4/5] Combining into skill draft..."

# Extract skill name from summary (first line, simplified)
SKILL_NAME=$(head -1 "$OUTPUT_DIR/summary.md" 2>/dev/null | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//' | cut -c1-50)
SKILL_NAME="${SKILL_NAME:-extracted-skill}"

cat > "$OUTPUT_DIR/SKILL.md" << EOF
---
name: $SKILL_NAME
description: "[TODO: Add one-line description]"
---

# ${SKILL_NAME//-/ }

## Summary

$(cat "$OUTPUT_DIR/summary.md" 2>/dev/null | head -20)

## Problem Pattern

$(cat "$OUTPUT_DIR/problem.md" 2>/dev/null | head -30)

## Steps

$(cat "$OUTPUT_DIR/instructions.md" 2>/dev/null | head -50)

## Key Insights

$(cat "$OUTPUT_DIR/wisdom.md" 2>/dev/null | head -30)

## Solution Applied

$(cat "$OUTPUT_DIR/solution.md" 2>/dev/null | head -30)

---

*Extracted from conversation on $(date +%Y-%m-%d)*
*Review and refine before use*
EOF

echo "  -> SKILL.md generated"

# Step 5: Summary
echo "[5/5] Extraction complete!"
echo ""
echo "=== OUTPUT FILES ==="
ls -lh "$OUTPUT_DIR"/*.md
echo ""
echo "=== NEXT STEPS ==="
echo "1. Review: cat $OUTPUT_DIR/SKILL.md"
echo "2. Edit to remove noise and refine"
echo "3. Move to: .claude/skills/$SKILL_NAME/"
echo ""
echo "Done!"
