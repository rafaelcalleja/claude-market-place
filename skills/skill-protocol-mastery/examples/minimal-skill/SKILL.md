---
name: commit-message-generator
description: This skill should be used when the user asks to "generate commit message", "write commit message", "create git commit", or mentions analyzing staged changes for commits.
version: 1.0.0
---

# Commit Message Generator

Generate clear, descriptive commit messages from git diffs.

## Workflow

1. Run `git diff --staged` to see changes
2. Analyze the modifications
3. Generate commit message with:
   - Summary under 50 characters
   - Detailed description
   - Affected components

## Message Format

```
type(scope): brief description

Detailed explanation of changes.
- Change 1
- Change 2
```

## Types

| Type | Description |
|------|-------------|
| feat | New feature |
| fix | Bug fix |
| docs | Documentation |
| style | Formatting |
| refactor | Code restructuring |
| test | Adding tests |
| chore | Maintenance |

## Best Practices

- Use present tense ("Add feature" not "Added feature")
- Explain what and why, not how
- Reference issues when applicable
