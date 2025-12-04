#!/bin/bash
# example_workflow.sh - Complete workflow for structured JSON output
# This demonstrates the full process from prompt creation to JSON extraction

set -euo pipefail

echo "=== Structured Output Workflow Example ==="
echo ""

# Step 1: Create base prompt
echo "[1/5] Creating base prompt..."
cat > /tmp/base_prompt.txt << 'EOF'
Analyze these user messages and return JSON with topic, tags, and summary.
EOF

# Step 2: Improve prompt with fabric
echo "[2/5] Improving prompt with fabric..."
cat /tmp/base_prompt.txt | fabric -p improve_prompt -o /tmp/improved_prompt.txt >/dev/null 2>&1

# Step 3: Combine prompt + data
echo "[3/5] Combining prompt with data..."
cat > /tmp/sample_data.txt << 'EOF'
User: How do I debug AWS EventBridge rules?
User: Can you show me the CloudWatch logs commands?
User: I need to check if my ECS task is running
EOF

(cat /tmp/improved_prompt.txt; echo ""; echo "## User Messages:"; cat /tmp/sample_data.txt) > /tmp/full_input.txt

# Step 4: Execute with fabric
echo "[4/5] Executing with fabric raw_query..."
cat /tmp/full_input.txt | fabric -p raw_query -m claude-3-5-haiku-latest -o /tmp/output.txt >/dev/null 2>&1

# Step 5: Extract clean JSON
echo "[5/5] Extracting clean JSON..."
sed -n '/^{/,/^}/p' /tmp/output.txt > /tmp/result.json

# Validate and display
if jq '.' /tmp/result.json >/dev/null 2>&1; then
    echo ""
    echo "=== SUCCESS: Valid JSON extracted ==="
    echo ""
    jq '.' /tmp/result.json
else
    echo ""
    echo "=== ERROR: Invalid JSON ==="
    echo ""
    cat /tmp/output.txt
fi

# Cleanup
rm -f /tmp/base_prompt.txt /tmp/improved_prompt.txt /tmp/sample_data.txt /tmp/full_input.txt /tmp/output.txt /tmp/result.json
