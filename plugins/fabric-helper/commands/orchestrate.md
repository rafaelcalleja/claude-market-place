---
name: orchestrate
allowed-tools: [Bash, Task, TodoWrite]
description: "Orchestrate complete Fabric pattern workflows"
argument-hint: [user_prompt]
category: utility
complexity: intermediate
mcp-servers: []
---

Orchestrate a Fabric pattern workflow for: "$1"

## Step 1: Find Plugin and Load Libraries

```bash
# Find fabric-helper plugin
PLUGIN_DIR=$(find ~/.claude/plugins/marketplaces -type d -name "fabric-helper" 2>/dev/null | head -1)

if [ -z "$PLUGIN_DIR" ]; then
  echo "Error: fabric-helper plugin not found"
  exit 1
fi

echo "=== PATTERN DESCRIPTIONS ==="
cat "$PLUGIN_DIR/.fabric-core/pattern_descriptions.json"

echo ""
echo "=== PATTERN EXTRACTS ==="
cat "$PLUGIN_DIR/.fabric-core/pattern_extracts.json"
```

## Step 2: Get Pattern Workflow

Invoke pattern-suggester (Task, subagent_type: "pattern-suggester"):

```
Recommend a pattern workflow for: "$1"

PATTERN LIBRARY:
[Insert pattern_descriptions from Step 1]

Return a sequence like: pattern1 → pattern2 → pattern3
```

## Step 3: Parse Sequence

Extract pattern names from suggester's response (e.g., [analyze_code, extract_issues, create_report])

## Step 4: Execute Chain

Use TodoWrite to track progress.

For each pattern in sequence:
1. Extract pattern from pattern_extracts (from Step 1) using jq
2. Invoke pattern-executor (Task, subagent_type: "pattern-executor") with:
   - Pattern instructions
   - Input: First pattern uses "$1", subsequent use previous output
3. Store output for next pattern

## Step 5: Return Final Result

Pass the last pattern's output to the user.
