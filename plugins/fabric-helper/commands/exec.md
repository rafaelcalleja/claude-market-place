---
description: Execute a specific Fabric pattern by name
argument-hint: [pattern_name] [user_prompt]
allowed-tools: [Task]
category: utility
complexity: basic
mcp-servers: []
---

## Usage
```
/exec [pattern_name] [user_prompt]
```

## Arguments
- `pattern_name` - The name of the pattern to execute (e.g., "review_code", "summarize")
- `user_prompt` - The input text to process

## Examples
```
/exec review_code "analyze the login function"
/exec summarize "last 5 commits"
/exec analyze_security "[code here]"
```

## Execution

This command delegates to the pattern-executor subagent which uses the Sonnet model for high-quality analysis.

Use the pattern-executor subagent to execute the pattern with the following input:

--- PATTERN NAME ---
$1

--- INPUT START ---
$2
--- INPUT END ---

The pattern-executor will:
1. Extract the specified pattern from `.fabric-core/pattern_extracts.json`
2. Apply the pattern to the provided input
3. Generate comprehensive analysis using Sonnet model
4. Return the formatted result
