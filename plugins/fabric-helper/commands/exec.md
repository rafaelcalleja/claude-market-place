---
description: Execute a specific Fabric pattern by name
argument-hint: [pattern_name] [user_prompt]
allowed-tools: [Bash, Task]
category: utility
complexity: basic
mcp-servers: []
---

Execute the Fabric pattern "$1" on this input: "$2"

## Step 1: Extract the Pattern

Find the plugin directory and extract the pattern:

```bash
# Find the fabric-helper plugin directory
PLUGIN_DIR=$(find ~/.claude/plugins/marketplaces -type d -name "fabric-helper" 2>/dev/null | head -1)

if [ -z "$PLUGIN_DIR" ]; then
  echo "Error: fabric-helper plugin not found"
  exit 1
fi

# Extract the pattern
cd "$PLUGIN_DIR"
cat .fabric-core/pattern_extracts.json | jq -r '.patterns[] | select(.patternName=="$1") | .pattern_extract'
```

## Step 2: Check Result

If the bash output is empty or shows an error, tell the user:
- Pattern "$1" not found in library
- Suggest: `/suggest "what you want to do"`
- Stop here

## Step 3: Execute Pattern

If pattern found, invoke pattern-executor agent (Task tool, subagent_type: "pattern-executor"):

```
Execute Fabric pattern "$1".

PATTERN INSTRUCTIONS:
[Paste the complete pattern text from Step 1 here]

USER INPUT:
$2

The pattern-executor will:
!echo "CLAUDE_PLUGIN_ROOT=${CLAUDE_PLUGIN_ROOT:-${HOME}/.claude/plugins/fabric-helper}"
1. Extract the specified pattern from `${CLAUDE_PLUGIN_ROOT}/.fabric-core/pattern_extracts.json`
2. Apply the pattern to the provided input
3. Generate comprehensive analysis using Sonnet model
4. Return the formatted result
