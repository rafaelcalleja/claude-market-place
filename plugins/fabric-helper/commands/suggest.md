---
name: suggest
argument-hint: [user_prompt]
allowed-tools: [Bash, Task]
description: "Suggest Fabric patterns based on user prompt analysis"
category: utility
complexity: basic
mcp-servers: []
---

Suggest appropriate Fabric patterns for: "$1"

## Step 1: Load Pattern Library

Find the plugin and load the pattern descriptions:

```bash
# Find the fabric-helper plugin directory
PLUGIN_DIR=$(find ~/.claude/plugins/marketplaces -type d -name "fabric-helper" 2>/dev/null | head -1)

if [ -z "$PLUGIN_DIR" ]; then
  echo "Error: fabric-helper plugin not found"
  exit 1
fi

# Load pattern library
cat "$PLUGIN_DIR/.fabric-core/pattern_descriptions.json"
```

## Step 2: Check Result

If bash shows an error, tell the user the plugin may not be properly installed.

## Step 3: Get Suggestions

If library loaded, invoke pattern-suggester agent (Task tool, subagent_type: "pattern-suggester"):

```
Analyze this request and recommend Fabric patterns: "$1"

PATTERN LIBRARY:
[Paste the complete JSON from Step 1 here]

Task:
- Identify user's intent and domain
- Match 3-5 patterns by tags and semantic similarity
- Recommend specific pattern names with reasoning
- Suggest workflows for complex tasks
- Provide alternatives

Return only pattern names and reasoning.
```

## Step 4: Return Recommendations

Pass the agent's recommendations to the user.
