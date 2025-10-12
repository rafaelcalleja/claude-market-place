---
name: orchestrate
allowed-tools: [Task, TodoWrite]
description: "Orchestrate complete Fabric pattern workflows"
argument-hint: [user_prompt]
category: utility
complexity: intermediate
mcp-servers: []
---

## Usage
```
/orchestrate [user_prompt]
```

## Arguments
- `user_prompt` - Describe your complete workflow need

## Execution

This command orchestrates the complete pattern workflow:

1. **Get Pattern Suggestions**:
   Use Task tool to call pattern-suggester with user prompt

2. **Parse Pattern Sequence**:
   Extract the recommended pattern sequence from the response

3. **Execute Pattern Chain**:
   For each pattern in the sequence:
   - Use Task tool to call pattern-executor with the pattern name
   - Pass the previous pattern's output as input to the next pattern
   - Store each output for chaining

4. **Return Final Result**:
   Return the last pattern's output directly to the user

## Detailed Workflow

### Step 1: Get Suggestions
Call pattern-suggester agent with user prompt to get pattern sequence

### Step 2: Parse Response
Extract the pattern sequence from suggester's response (e.g., `analyze → extract → create_summary`)

### Step 3: Execute Each Pattern
For each pattern in the sequence, use Task tool with:
- description: "Execute [pattern_name] pattern"
- prompt: "Execute [pattern_name] pattern with this input: [previous_output or original_input]"
- subagent_type: "pattern-executor"

### Step 4: Chain Outputs
- First pattern receives the original user input
- Each subsequent pattern receives the output from the previous pattern
- Continue until all patterns are executed

### Step 5: Return Result
Return the final pattern's output directly without modification

## Examples

### Documentation Generation
```
/orchestrate "Document my codebase with clean, formatted output"
```
Workflow:
1. pattern-suggester returns: `analyze_code → extract_structure → create_documentation`
2. Execute analyze_code with original code
3. Execute extract_structure with code analysis
4. Execute create_documentation with structure data
5. Return final documentation

### Security Analysis
```
/orchestrate "Analyze security vulnerabilities and create a report"
```
Workflow:
1. pattern-suggester returns: `analyze_security → extract_vulnerabilities → create_report`
2. Execute analyze_security with codebase
3. Execute extract_vulnerabilities with security analysis
4. Execute create_report with vulnerability list
5. Return security report

## Important Notes
- The command handles all orchestration directly
- Each pattern's output becomes the next pattern's input
- No intermediate agents are involved
- Final output is returned unmodified
