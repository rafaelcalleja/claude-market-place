---
name: orchestrate
allowed-tools: [Bash, Task, TodoWrite]
description: "Orchestrate complete Fabric pattern workflows"
argument-hint: [user_prompt]
category: utility
complexity: intermediate
mcp-servers: []
---

## Task

Orchestrate a complete multi-pattern workflow by automatically suggesting patterns, then executing them in sequence.

## Steps

### Step 1: Load Pattern Libraries

Use Bash tool to read both pattern files:

1. Pattern descriptions (for suggestion):
```bash
cat "${CLAUDE_PLUGIN_ROOT}/.fabric-core/pattern_descriptions.json"
```

2. Pattern extracts (for execution):
```bash
cat "${CLAUDE_PLUGIN_ROOT}/.fabric-core/pattern_extracts.json"
```

### Step 2: Get Pattern Suggestions

Use Task tool to invoke the `pattern-suggester` subagent with:
- User request: `$1`
- Pattern library: The pattern_descriptions.json content from Step 1

Ask the suggester to recommend a pattern workflow (sequence of patterns).

### Step 3: Parse Pattern Sequence

Extract the recommended pattern sequence from the suggester's response.
Example: If suggester returns "analyze_code → extract_issues → create_report",
the sequence is: [analyze_code, extract_issues, create_report]

### Step 4: Execute Pattern Chain

For each pattern in the sequence:

1. Extract the pattern prompt from pattern_extracts.json (loaded in Step 1)
2. Use Task tool to invoke `pattern-executor` subagent with:
   - Pattern name
   - Pattern prompt (extracted)
   - Input: For first pattern use `$1`, for subsequent patterns use previous output
3. Store the output for the next pattern

Continue until all patterns are executed.

### Step 5: Return Final Result

Return the output from the last pattern execution to the user.

## User Request

```
$1
```

## Workflow Management

Use TodoWrite tool to track progress:
1. Pattern suggestion
2. Pattern extraction for each pattern
3. Execution of each pattern
4. Final result delivery

## Examples

### Documentation Workflow
```
/orchestrate "Analyze this code and create documentation"
```

Workflow:
1. Suggester recommends: analyze_code → extract_structure → create_documentation
2. Execute analyze_code with the code
3. Execute extract_structure with analysis result
4. Execute create_documentation with structure result
5. Return final documentation

### Security Analysis Workflow
```
/orchestrate "Find security issues and create a report"
```

Workflow:
1. Suggester recommends: analyze_security → extract_vulnerabilities → create_report
2. Execute analyze_security with codebase
3. Execute extract_vulnerabilities with security analysis
4. Execute create_report with vulnerability list
5. Return security report

## Notes

- The orchestrator manages the entire workflow automatically
- Each pattern's output becomes the next pattern's input
- The user receives only the final result
- Progress is tracked with TodoWrite for visibility
