---
description: Execute a specific Fabric pattern by name
argument-hint: [pattern_name] [user_prompt]
allowed-tools: [Bash, Task]
category: utility
complexity: basic
mcp-servers: []
---

Execute the Fabric pattern "$1" on this input: "$2"

## Instructions

1. First, extract the pattern from the library using Bash:

```bash
cat "${CLAUDE_PLUGIN_ROOT}/.fabric-core/pattern_extracts.json" | jq -r '.patterns[] | select(.patternName=="$1") | .pattern_extract'
```

2. If the pattern is not found (empty output), tell the user:
   - Pattern "$1" not found
   - Suggest using: /suggest "what you want to do"

3. If found, invoke the pattern-executor agent using Task tool with:
   - subagent_type: "pattern-executor"
   - prompt: Pass the extracted pattern instructions and ask the agent to apply them to the user input "$2"

4. Return the agent's result to the user.

Execute these steps now.
