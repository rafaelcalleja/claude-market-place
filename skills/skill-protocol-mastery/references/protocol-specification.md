# Agent Skill Protocol Specification

Complete technical specification for the Agent Skill Protocol.

## Protocol Architecture

### Component Overview

```
AI Agent Runtime
  → Skill Discovery System (scans directories, parses metadata)
    → Skill Activation Engine (matches requests to skills)
      → Skill Execution Context (loads content, applies permissions)
        → Tool Permission System (validates access)
```

### Data Flow

```
User Request
  → Skill Discovery (match description to request)
    → Skill Selection (best match based on relevance)
      → Skill Loading (read SKILL.md)
        → Tool Permission Setup (apply allowed-tools)
          → Content Processing (inject into context)
            → Progressive Loading (load referenced files)
              → Skill Execution (follow instructions)
```

## Discovery Mechanism

### Directory Precedence

Skills are discovered in order of precedence:

1. **Project-level** (highest): `.claude/skills/*/SKILL.md`
2. **User-level** (medium): `~/.claude/skills/*/SKILL.md`
3. **Plugin-level** (lowest): `<plugin-root>/skills/*/SKILL.md`

### Discovery Algorithm

```
FUNCTION discoverSkills():
  skills = []

  FOR EACH scope IN [project, user, plugin]:
    skillDirs = findDirectories(scope.path + "/*/")

    FOR EACH dir IN skillDirs:
      skillFile = dir + "/SKILL.md"

      IF exists(skillFile):
        metadata = parseMetadata(skillFile)

        IF isValid(metadata):
          skill = {
            name: metadata.name,
            description: metadata.description,
            path: skillFile,
            scope: scope.name
          }

          IF NOT hasDuplicate(skills, skill.name):
            skills.append(skill)
          ELSE IF scope.priority > getDuplicate.scope.priority:
            replaceDuplicate(skills, skill)

  RETURN skills
```

## Metadata Schema

### Required Fields

#### name

- **Type**: string
- **Pattern**: `^[a-z0-9-]+$`
- **Length**: 1-64 characters
- **Restrictions**: No XML tags, no reserved words ("anthropic", "claude")

#### description

- **Type**: string
- **Length**: 1-1024 characters
- **Format**: Third-person, specific triggers
- **Must include**: What skill does AND when to use it

### Optional Fields

#### allowed-tools

- **Type**: string (comma-separated) or array
- **Valid values**: Read, Write, Edit, Bash, Glob, Grep, Task, WebFetch, WebSearch, TodoWrite, AskUserQuestion, Skill, SlashCommand, etc.
- **Behavior**: When specified, agent can ONLY use these tools without permission

#### version

- **Type**: string
- **Pattern**: Semantic versioning (e.g., "1.0.0")

## Activation Model

### Activation Criteria

A skill activates when:
1. User request contains keywords from description
2. Semantic similarity exceeds threshold
3. Context suggests skill applicability

### Selection Strategy

When multiple skills match:
1. **Explicit mention**: Skills mentioned by name have highest priority
2. **Relevance score**: Ranked by semantic similarity
3. **Recency**: Recently used skills get slight boost
4. **Scope**: Project skills preferred over user skills

## Tool Permission Model

### Default Mode (no allowed-tools)

- Agent follows standard permission model
- Tool usage requires user approval based on settings
- No special restrictions

### Restricted Mode (allowed-tools specified)

- Agent can ONLY use listed tools
- Listed tools do NOT require approval
- Unlisted tools are unavailable
- Attempting unlisted tools results in error

### Permission Enforcement

```
FUNCTION checkToolPermission(toolName, activeSkill):
  IF activeSkill.allowedTools IS NULL:
    RETURN standardPermissionCheck(toolName)
  ELSE:
    IF toolName IN activeSkill.allowedTools:
      RETURN ALLOW
    ELSE:
      RETURN DENY
```

## Progressive Disclosure

### Loading Strategy

1. **Detection**: Monitor for file references in Markdown links, inline code, code blocks
2. **Resolution**: Resolve paths relative to skill directory
3. **Validation**: Check file exists
4. **Loading**: Read and inject into context
5. **Caching**: Cache for future references

### File Content Format

When loading referenced files:

```
--- Content from {filepath} ---

{file content}

--- End of {filepath} ---
```

### Context Budget

- Track total tokens used by skill content
- Warn when exceeding threshold (~10,000 tokens)
- Provide mechanisms to compact or summarize

## Lifecycle States

```
Discovered → Registered → Activated → Loaded → Executing → Completed
```

### State Transitions

| From | To | Trigger |
|------|-----|---------|
| Discovery | Registration | Metadata validated |
| Registration | Activation | User request matches |
| Activation | Loading | Content injection |
| Loading | Executing | Agent reads instructions |
| Executing | Completed | Task finishes |

## File Format Specification

### SKILL.md Structure

```
---
{YAML frontmatter}
---

{Markdown content}
```

### YAML Grammar

```yaml
frontmatter ::= "---" newline
                field_list
                "---" newline

required_field ::= name_field | description_field
optional_field ::= allowed_tools_field | version_field

name_field ::= "name:" space string newline
description_field ::= "description:" space string newline
allowed_tools_field ::= "allowed-tools:" space tool_list newline
```

### Markdown Content

Follow CommonMark specification with extensions:
- File references: `[text](path)`
- Code blocks with language identifiers
- GitHub-flavored markdown tables

## Naming Conventions

### Skill Names

- **Pattern**: `^[a-z0-9-]+$`
- **Case**: All lowercase
- **Separators**: Hyphens only
- **Length**: 1-64 characters

**Recommended**: Gerund form (verb + -ing)
- `processing-pdfs`
- `analyzing-spreadsheets`
- `managing-databases`

### File Names

- Markdown: kebab-case (`reference-guide.md`)
- Python: snake_case (`process_data.py`)
- JavaScript: camelCase (`processData.js`)

## Security Considerations

### Principle of Least Privilege

- Grant only necessary tools
- Use allowed-tools to restrict capabilities
- Document security implications

### Dangerous Combinations

Be cautious with:
- `Bash` + `Write`: Can create and execute scripts
- `WebFetch` + `Bash`: Can download and execute remote code
- `Edit` + `Bash`: Can modify and execute scripts

### Input Validation

Skills should validate:
- File paths (prevent directory traversal)
- User inputs (prevent injection)
- External data (sanitize before processing)

### Secrets Management

Skills MUST NOT:
- Contain hardcoded credentials
- Commit API keys or tokens
- Store passwords in files

Skills SHOULD:
- Use environment variables
- Document required credentials
- Provide example configurations
