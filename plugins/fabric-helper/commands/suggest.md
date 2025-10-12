---
name: suggest
argument-hint: [user_prompt]
allowed-tools: [Bash, Task]
description: "Suggest Fabric patterns based on user prompt analysis"
category: utility
complexity: basic
mcp-servers: []
---

Suggest appropriate Fabric patterns for this request: "$1"

## Instructions

1. Load the pattern library using Bash:

```bash
cat "${CLAUDE_PLUGIN_ROOT}/.fabric-core/pattern_descriptions.json"
```

2. Invoke the pattern-suggester agent using Task tool with:
   - subagent_type: "pattern-suggester"
   - prompt: Ask the agent to analyze the user request "$1" and recommend 3-5 appropriate patterns from the library you just loaded. Include the complete library content in your prompt to the agent.

3. Return the agent's pattern recommendations to the user.

Execute these steps now.
