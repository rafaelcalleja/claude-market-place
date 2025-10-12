---
name: suggest
argument-hint: [user_prompt]
allowed-tools: [Bash, Task]
description: "Suggest Fabric patterns based on user prompt analysis"
category: utility
complexity: basic
mcp-servers: []
---

## Task

Suggest appropriate Fabric patterns for the user's request.

## Steps

1. **Load the pattern library**: Read the file `${CLAUDE_PLUGIN_ROOT}/.fabric-core/pattern_descriptions.json` using the Bash tool with `cat` command. This file contains all available patterns with their names, descriptions, and tags.

2. **Invoke the pattern-suggester agent**: Use the Task tool to call the `pattern-suggester` subagent. Pass it:
   - The user's request: `$1`
   - The complete pattern library JSON from step 1

3. **Agent task**: Ask the pattern-suggester to:
   - Analyze the user's intent and domain
   - Match patterns by tags and semantic similarity
   - Recommend 3-5 specific pattern names with reasoning
   - Suggest workflows for complex needs
   - Provide alternatives if applicable

4. **Return** the agent's pattern recommendations to the user.

## User Request

```
$1
```

## Example

Input: `/suggest "analyze security vulnerabilities in code"`

Expected output:
```
Recommended: analyze_security, review_code, extract_vulnerabilities

Reasoning: Security-focused analysis. These patterns cover vulnerability
assessment, security-aware code review, and structured issue extraction.
```
