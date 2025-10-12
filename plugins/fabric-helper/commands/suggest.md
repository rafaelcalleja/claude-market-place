---
name: suggest
argument-hint: [user_prompt]
allowed-tools: [Task]
description: "Suggest Fabric patterns based on user prompt analysis"
category: utility
complexity: basic
mcp-servers: []
---

## Usage
```
/suggest [user_prompt]
```

## Arguments
- `user_prompt` - Describe what you want to do

## Execution

Delegate to the `pattern-suggester` subagent with the provided user prompt for intelligent pattern suggestions based on semantic analysis.

The pattern-suggester agent will:
- Load and analyze the Fabric pattern library from `${CLAUDE_PLUGIN_ROOT}/.fabric-core/pattern_descriptions.json`
- Perform deep semantic analysis of the user prompt
- Identify primary intent, domain context, and specific requirements
- Match patterns based on tags, semantic similarity, and use case alignment
- Generate 3-5 targeted pattern recommendations with clear reasoning
- Suggest single patterns for simple tasks or multi-pattern workflows for complex tasks
- Provide alternative approaches for different outcomes

## Example
```
/suggest "I need to analyze security vulnerabilities in my codebase"
```

This will invoke the pattern-suggester subagent to recommend security-focused analysis patterns from the Fabric library.
