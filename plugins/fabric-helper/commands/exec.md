---
description: Execute a specific Fabric pattern by name
argument-hint: [pattern_name] [user_prompt]
allowed-tools: [Bash, Task]
category: utility
complexity: basic
mcp-servers: []
---

## Task

Execute a specific Fabric pattern on the user's input.

## Arguments

- `$1` - Pattern name (e.g., "review_code", "summarize", "analyze_security")
- `$2` - Input text to process

## Steps

1. **Extract the pattern**: Use the Bash tool to extract the specific pattern from the pattern library:
   ```bash
   cat "${CLAUDE_PLUGIN_ROOT}/.fabric-core/pattern_extracts.json" | jq -r '.patterns[] | select(.patternName=="$1") | .pattern_extract'
   ```
   This extracts the complete pattern prompt for the requested pattern name.

2. **Verify pattern exists**: If the pattern is not found (empty output), inform the user that the pattern "$1" doesn't exist and suggest using `/suggest` to find appropriate patterns.

3. **Invoke pattern-executor agent**: Use the Task tool to call the `pattern-executor` subagent with:
   - Pattern name: `$1`
   - Pattern prompt: The extracted `pattern_extract` from step 1
   - User input: `$2`

4. **Agent task**: Ask the pattern-executor to:
   - Apply the pattern prompt to the user's input
   - Generate high-quality analysis using the Sonnet model
   - Return the formatted result according to the pattern's specifications

5. **Return** the execution result to the user.

## Pattern Name

```
$1
```

## User Input

```
$2
```

## Examples

### Code Review
```
/exec review_code "function getData() { return data; }"
```

### Summarize Content
```
/exec summarize "[long article text]"
```

### Security Analysis
```
/exec analyze_security "[code snippet]"
```

## Error Handling

If pattern not found:
```
Pattern "$1" not found in the library.

Use /suggest to discover available patterns:
/suggest "describe what you want to do"
```
