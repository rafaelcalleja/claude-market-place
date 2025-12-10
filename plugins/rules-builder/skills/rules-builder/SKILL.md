---
name: rules-builder
description: Use when the user wants to create, edit, or manage Claude Code rules in .claude/rules/. Provides guided elicitation to configure path-specific rules with proper YAML frontmatter and glob patterns.
---

# Rules Builder

Interactive skill for creating and editing Claude Code rules with guided elicitation.

## When to Use

- User wants to create a new rule file
- User wants to edit an existing rule
- User mentions `.claude/rules/`
- User asks about path-specific rules or glob patterns
- User wants to organize project instructions

## Workflow: Create New Rule

### Step 1: Determine Rule Scope

Use `AskUserQuestion` to ask:

**Question**: "What type of rule do you want to create?"

| Option | Description |
|--------|-------------|
| Global rule | Applies to all files in the project |
| Path-specific rule | Only applies to files matching a pattern |

### Step 2: If Path-Specific, Determine Pattern

Use `AskUserQuestion` to ask:

**Question**: "What files should this rule apply to?"

| Option | Pattern | Description |
|--------|---------|-------------|
| TypeScript files | `**/*.ts` | All .ts files |
| React/TSX files | `**/*.{ts,tsx}` | TypeScript and React |
| Frontend code | `src/**/*.{ts,tsx,css}` | All frontend sources |
| Backend/API | `src/api/**/*.ts` | API endpoints only |
| Tests | `**/*.{test,spec}.ts` | Test files only |
| Custom pattern | (ask for input) | User specifies |

If "Custom pattern", ask user to provide the glob pattern and validate it.

### Step 3: Determine Rule Category

Use `AskUserQuestion` to ask:

**Question**: "What category of rules will this contain?"

| Option | Suggested filename |
|--------|-------------------|
| Code style | `code-style.md` |
| Testing conventions | `testing.md` |
| Security requirements | `security.md` |
| API development | `api.md` |
| Documentation | `docs.md` |
| Performance | `performance.md` |
| Custom | (ask for name) |

### Step 4: Determine Location

Use `AskUserQuestion` to ask:

**Question**: "Where should this rule be created?"

| Option | Path |
|--------|------|
| Project root rules | `.claude/rules/` |
| Frontend subdirectory | `.claude/rules/frontend/` |
| Backend subdirectory | `.claude/rules/backend/` |
| Custom location | (ask for path) |

### Step 5: Generate Rule File

1. Create the directory if it doesn't exist
2. Generate the file with proper frontmatter:

```yaml
---
paths: [selected pattern or omit if global]
---

# [Rule Title]

[Guide user to add their specific rules here]
```

3. Validate frontmatter against schema: `${CLAUDE_PLUGIN_ROOT}/skills/rules-builder/schemas/rule-frontmatter.schema.json`

### Step 6: Suggest Initial Content

Based on the category, suggest starter content:

**For code-style.md:**
```markdown
# Code Style Rules

- Use consistent indentation (2 spaces)
- Follow naming conventions: camelCase for variables, PascalCase for types
- Maximum line length: 100 characters
```

**For testing.md:**
```markdown
# Testing Conventions

- Write tests for all new features
- Use descriptive test names
- Follow AAA pattern: Arrange, Act, Assert
```

**For security.md:**
```markdown
# Security Requirements

- Never commit secrets or API keys
- Validate all user input
- Use parameterized queries for database operations
```

## Workflow: Edit Existing Rule

### Step 1: List Available Rules

Read `.claude/rules/` directory and present options:

```bash
find .claude/rules -name "*.md" -type f
```

Use `AskUserQuestion` to let user select which rule to edit.

### Step 2: Show Current Content

Read the selected file and display:
- Current frontmatter (paths, etc.)
- Current rule content

### Step 3: Determine Edit Type

Use `AskUserQuestion`:

**Question**: "What do you want to change?"

| Option | Action |
|--------|--------|
| Change path scope | Modify the `paths` frontmatter |
| Add more rules | Append new content |
| Reorganize | Restructure the file |
| Delete rule | Remove the file |

### Step 4: Apply Changes

Make the requested changes and validate.

## Validation

Before saving any rule file, validate the frontmatter:

1. Read the JSON schema from `${CLAUDE_PLUGIN_ROOT}/skills/rules-builder/schemas/rule-frontmatter.schema.json`
2. Parse the YAML frontmatter
3. Validate against schema
4. Report any errors to user

### Common Validation Errors

| Error | Fix |
|-------|-----|
| Invalid glob pattern | Check pattern syntax, see references/glob-patterns.md |
| Unknown frontmatter field | Only `paths`, `description`, `priority`, `enabled` allowed |
| Invalid paths type | Must be string or array of strings |

## References

- **Glob patterns guide**: `${CLAUDE_PLUGIN_ROOT}/skills/rules-builder/references/glob-patterns.md`
- **Frontmatter schema**: `${CLAUDE_PLUGIN_ROOT}/skills/rules-builder/schemas/rule-frontmatter.schema.json`

## Examples

**Example 1: Create API-specific rules**
```
User: "I want to create rules for my API endpoints"
-> Ask about path scope -> Select "Backend/API"
-> Ask about category -> Select "API development"
-> Create .claude/rules/api.md with paths: src/api/**/*.ts
```

**Example 2: Edit existing testing rules**
```
User: "Update my testing rules to also apply to integration tests"
-> List rules, user selects testing.md
-> Show current paths: **/*.test.ts
-> User wants to change scope
-> Update to: **/*.{test,spec,integration}.ts
```

**Example 3: Create global code style**
```
User: "Add code style rules for the whole project"
-> Ask about scope -> Select "Global rule"
-> No paths frontmatter needed
-> Create .claude/rules/code-style.md
```
