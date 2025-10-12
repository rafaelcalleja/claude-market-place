---
name: orchestrate
allowed-tools: [Bash, Task, TodoWrite]
description: "Orchestrate complete Fabric pattern workflows"
argument-hint: [user_prompt]
category: utility
complexity: intermediate
mcp-servers: []
---

Orchestrate a complete Fabric pattern workflow for this request: "$1"

## Instructions

1. Load both pattern libraries using Bash:

```bash
cat "${CLAUDE_PLUGIN_ROOT}/.fabric-core/pattern_descriptions.json"
```

```bash
cat "${CLAUDE_PLUGIN_ROOT}/.fabric-core/pattern_extracts.json"
```

2. Invoke pattern-suggester agent to get a workflow sequence:
   - Use Task tool with subagent_type "pattern-suggester"
   - Ask it to recommend a pattern workflow for "$1"
   - Pass the pattern_descriptions content

3. Parse the recommended pattern sequence from the suggester's response.

4. For each pattern in the sequence:
   - Extract that pattern's instructions from pattern_extracts (loaded in step 1)
   - Invoke pattern-executor agent with the pattern instructions
   - Use the previous pattern's output as input to the next pattern
   - Track progress with TodoWrite

5. Return the final pattern's output to the user.

Execute these steps now.
