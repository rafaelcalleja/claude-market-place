---
name: code-analyzer
description: This skill should be used when the user asks to "analyze code", "review code quality", "check code structure", "find code patterns", or mentions code analysis without making changes.
allowed-tools: Read, Grep, Glob
version: 1.0.0
---

# Code Analyzer

Analyze code structure and patterns without making modifications.

## Capabilities

- Analyze code organization and architecture
- Find patterns and anti-patterns
- Check naming conventions
- Identify potential issues
- Review documentation quality

## Workflow

### Step 1: Discover Files

Use Glob to find relevant source files:

```bash
# Find all TypeScript files
*.ts, **/*.ts

# Find all Python files
*.py, **/*.py
```

### Step 2: Analyze Structure

Use Read to examine file contents and understand:
- Module organization
- Class hierarchies
- Function signatures
- Import patterns

### Step 3: Search Patterns

Use Grep to find specific patterns:
- Error handling patterns
- Logging practices
- API usage
- Configuration access

### Step 4: Report Findings

Provide analysis covering:
- Code organization
- Naming conventions
- Potential issues
- Improvement suggestions

## Analysis Checklist

- [ ] Code structure and organization
- [ ] Naming conventions followed
- [ ] Comment quality
- [ ] Potential bugs or issues
- [ ] Performance considerations
- [ ] Security concerns

## Additional Resources

### Reference Files

For detailed analysis patterns:
- **`references/patterns.md`** - Common code patterns to identify
- **`references/anti-patterns.md`** - Issues to flag
