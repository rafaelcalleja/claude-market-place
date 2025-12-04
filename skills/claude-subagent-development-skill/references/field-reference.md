# Subagent Field Reference

Complete reference for all subagent configuration fields with examples, constraints, and common mistakes.

## Required Fields

### name

**Type**: `string`
**Pattern**: `^[a-z0-9-]+$`
**Length**: 1-100 characters

**Purpose**: Unique identifier for the subagent within its scope.

**Rules**:
- Lowercase letters only (a-z)
- Numbers allowed (0-9)
- Hyphens for word separation
- No spaces, underscores, or special characters
- Must be unique within scope (project/user/plugin)

**Valid Examples**:
```yaml
name: code-reviewer
name: test-runner
name: data-scientist-2024
name: debugger-v2
name: security-auditor
```

**Invalid Examples**:
```yaml
name: Code_Reviewer  # Uppercase and underscore
name: test runner    # Space not allowed
name: my@agent       # Special character
name: DataScientist  # CamelCase not allowed
```

**Common Mistakes**:
- Using underscores instead of hyphens
- Including uppercase letters
- Starting with numbers (allowed but not recommended)
- Using generic names (agent1, helper, util)

**Best Practices**:
- Use descriptive, role-based names
- Include domain or specialization
- Keep under 30 characters for readability
- Use consistent naming convention across team

---

### description

**Type**: `string`
**Length**: 10-2000 characters

**Purpose**: Natural language description that determines when Claude invokes the subagent.

**Critical**: This field is the primary mechanism for automatic subagent discovery. Quality matters significantly.

**Required Elements**:
1. **What** the subagent does
2. **When** to use it
3. **Specific triggers** - phrases users would say
4. **Domain indicators** - file types, operations, scenarios

**Strong Description Template**:
```yaml
description: [Role/Specialty]. Use [WHEN_CONDITION] when [SCENARIOS]. [SPECIFIC_CAPABILITIES]. [KEY_TRIGGERS].
```

**Excellent Examples**:

```yaml
# Emphatic triggers + specific scenarios
description: Expert code reviewer. Use PROACTIVELY after code changes to review quality, security, and best practices. Checks for vulnerabilities, performance issues, code style violations, and test coverage.

# Clear conditions + domain indicators
description: Debugging specialist for errors, test failures, and unexpected behavior. Use when encountering exceptions, crashes, failing tests, or unexpected program behavior. Specializes in root cause analysis.

# Specific file types + operations
description: PDF processing specialist. Use when working with PDF files, filling forms, extracting text, merging documents, or converting PDFs. Handles .pdf files and PDF-related operations.

# Domain-specific + automation emphasis
description: Data analysis expert for SQL queries and BigQuery operations. Use PROACTIVELY for database queries, data analysis tasks, schema exploration, or BigQuery CLI operations. Works with SQL and data pipelines.
```

**Poor Examples**:

```yaml
# Too vague
description: Helps with code

# Missing when to use
description: Reviews code for quality and security

# No specific triggers
description: General purpose development assistant

# Generic and unhelpful
description: Subagent for various tasks
```

**Trigger Phrases**:

Include phrases users actually say:
- "review this code"
- "fix this error"
- "run the tests"
- "analyze this data"
- "debug this issue"
- "create a hook"
- "query the database"

**Emphatic Language**:

Use to increase priority:
- "Use PROACTIVELY"
- "MUST BE USED"
- "Automatically use"
- "Always use when"

**Common Mistakes**:
- Too short (under 50 characters)
- Too generic ("helps with X")
- Missing trigger scenarios
- No specific keywords
- Buried in long text without emphasis

**Best Practices**:
- Front-load most important triggers
- Include file extensions (.pdf, .sql, .py)
- Mention specific operations (review, debug, test, query)
- Use emphatic language strategically
- Include 3-5 specific scenarios
- Keep under 500 characters when possible

**Testing Your Description**:

Ask: "If a user said [X], would Claude match this subagent?"

Test phrases:
- "Can you review my changes?"
- "This test is failing"
- "How do I query this database?"
- "I need to process a PDF"

---

## Optional Fields

### tools

**Type**: `string | null`
**Format**: Comma-separated list
**Default**: `null` (inherits all tools)

**Purpose**: Restrict which tools the subagent can use.

**Inheritance Model**:
- `tools` omitted or `null` → Inherits ALL tools from main thread
- `tools` specified → Only those tools available
- No partial inheritance

**Available Tools**:
```
Task, Bash, Glob, Grep, Read, Edit, Write, NotebookEdit,
WebFetch, WebSearch, BashOutput, KillShell, AskUserQuestion,
TodoWrite, Skill, SlashCommand, EnterPlanMode, ExitPlanMode,
ListMcpResourcesTool, ReadMcpResourceTool
```

**MCP Tools**:
Format: `mcp__<server>__<tool>`

Examples:
```yaml
tools: Read, mcp__github__get_issue, mcp__database__query
```

**Common Patterns**:

```yaml
# Read-only analysis
tools: Read, Grep, Glob

# Safe code modification (no shell access)
tools: Read, Edit, Write

# Code review with git
tools: Read, Grep, Glob, Bash

# Full development workflow
tools: Read, Edit, Write, Bash, TodoWrite

# Testing and execution
tools: Bash, Read, Edit

# Inherit everything (explicit)
tools: null

# Data analysis with web search
tools: Read, Bash, WebSearch

# MCP integration
tools: Read, mcp__github__create_pr, mcp__slack__send_message
```

**Security Implications**:

**Low Risk** (read-only):
```yaml
tools: Read, Grep, Glob
```

**Medium Risk** (modifications):
```yaml
tools: Read, Edit, Write
```

**High Risk** (shell access):
```yaml
tools: Read, Edit, Write, Bash
```

**Critical Risk** (full access):
```yaml
tools: null  # or omitted
```

**Common Mistakes**:
- Granting `null` (all tools) unnecessarily
- Misspelling tool names (case-sensitive)
- Using wildcards (not supported: `Edit*`)
- Forgetting Bash for git operations
- Including tools never used

**Best Practices**:
- Grant minimum necessary tools
- Start restrictive, expand if needed
- Document why each tool is needed
- Review permissions regularly
- Use read-only when possible

**Tool Validation**:
```bash
# Check if tool names are valid
scripts/validate-subagent.sh --check-tools your-subagent.md
```

---

### model

**Type**: `string | null`
**Values**: `sonnet` | `opus` | `haiku` | `inherit`
**Default**: `null` (uses configured default, typically `sonnet`)

**Purpose**: Specify which AI model to use for this subagent.

**Model Characteristics**:

| Model | Speed | Capability | Cost | Context | Best For |
|-------|-------|------------|------|---------|----------|
| haiku | Fast | Good | Low | 200K | Quick searches, simple tasks, high volume |
| sonnet | Medium | Excellent | Medium | 200K | General purpose, complex reasoning |
| opus | Slow | Best | High | 200K | Critical decisions, maximum quality |
| inherit | Varies | Matches main | Varies | 200K | Consistency with main conversation |

**When to Use Each**:

**haiku**:
```yaml
# Fast codebase exploration
name: explorer
model: haiku
tools: Read, Grep, Glob

# High-volume simple operations
name: test-runner
model: haiku
tools: Bash, Read

# Quick validation checks
name: validator
model: haiku
tools: Read
```

**sonnet** (default):
```yaml
# General purpose development
name: code-reviewer
model: sonnet

# Complex reasoning required
name: debugger
model: sonnet

# Balanced workflows
name: refactorer
model: sonnet
```

**opus**:
```yaml
# Critical security analysis
name: security-auditor
model: opus

# Complex architectural decisions
name: architect
model: opus

# Maximum quality required
name: technical-writer
model: opus
```

**inherit**:
```yaml
# Match user's model choice
name: pair-programmer
model: inherit

# Consistent capability level
name: assistant
model: inherit
```

**Common Mistakes**:
- Using opus for simple tasks (unnecessary cost)
- Using haiku for complex reasoning (insufficient capability)
- Not considering cost implications
- Forgetting to specify when quality critical

**Best Practices**:
- Use haiku for read-only exploration
- Use sonnet as safe default
- Reserve opus for critical tasks
- Use inherit for user-facing assistants
- Document model choice reasoning

**Cost Optimization**:
```yaml
# Efficient: Use haiku for exploration
name: search-agent
model: haiku
description: Quick codebase searches

# Then sonnet for analysis
name: code-analyzer
model: sonnet
description: Detailed code analysis
```

---

### permissionMode

**Type**: `string`
**Values**: `default` | `acceptEdits` | `bypassPermissions` | `plan` | `ignore`
**Default**: `default`

**Purpose**: Control how the subagent handles permission requests.

**Mode Details**:

#### default

**Behavior**: Standard permission flow, user approves operations

**When to use**: Most subagents, especially user-facing

**Example**:
```yaml
name: code-reviewer
permissionMode: default
```

**User experience**:
- Prompted for destructive operations
- Can deny individual tool calls
- Maintains control

#### acceptEdits

**Behavior**: Auto-approve Edit/Write, prompt for others

**When to use**: Trusted code modification workflows

**Example**:
```yaml
name: formatter
permissionMode: acceptEdits
tools: Read, Edit, Write
```

**User experience**:
- File edits automatic
- Still prompted for Bash
- Reduced friction

#### bypassPermissions

**Behavior**: Skip ALL permission checks

**When to use**: Fully automated, trusted workflows ONLY

**Security**: HIGH RISK - use with extreme caution

**Example**:
```yaml
name: ci-automation
permissionMode: bypassPermissions
tools: Bash, Read, Edit, Write
```

**User experience**:
- Zero permission prompts
- Complete automation
- Requires absolute trust

**Warning**: Never use for:
- Untrusted code
- Experimental subagents
- User-provided configs
- External plugins

#### plan

**Behavior**: Read-only mode, blocks write operations

**When to use**: Research and planning only

**Example**:
```yaml
name: planner
permissionMode: plan
tools: Read, Grep, Glob, Bash
```

**User experience**:
- Safe exploration
- Cannot modify files
- Can still run read-only Bash

#### ignore

**Behavior**: Ignores permission dialogs, continues execution

**When to use**: Background operations

**Example**:
```yaml
name: monitor
permissionMode: ignore
```

**User experience**:
- No blocking on permissions
- Continues past dialogs
- Use for non-interactive contexts

**Permission Flow**:

```
Tool Call Request
       ↓
Check permissionMode
       ↓
┌──────────────┐
│  default     │ → Check permissions → Prompt if needed
├──────────────┤
│ acceptEdits  │ → Auto-approve Edit/Write → Prompt others
├──────────────┤
│ bypass       │ → Allow all operations
├──────────────┤
│ plan         │ → Block writes → Allow reads
├──────────────┤
│ ignore       │ → Ignore permission requests
└──────────────┘
```

**Common Mistakes**:
- Using `bypassPermissions` without understanding risks
- Not restricting tools with `bypassPermissions`
- Using `plan` mode with write tools
- Choosing wrong mode for automation level

**Best Practices**:
- Start with `default`, relax if needed
- Combine `acceptEdits` with tool restrictions
- Never use `bypassPermissions` for untrusted configs
- Use `plan` for read-only research
- Document permission mode choice

---

### skills

**Type**: `string | null`
**Format**: Comma-separated list of skill names
**Default**: `null` (no skills auto-loaded)

**Purpose**: Auto-load specific skills when subagent starts.

**How It Works**:
1. Subagent invoked
2. Skills loaded into subagent context
3. Skills available during execution
4. Progressive disclosure applies

**Skill Resolution**:

Search order:
1. `.claude/skills/` (project)
2. `~/.claude/skills/` (user)
3. Plugin skills

**Valid Examples**:
```yaml
# Single skill
skills: pdf-processing

# Multiple skills
skills: code-review, security-analysis

# Domain-specific skills
skills: sql-optimization, database-schema

# Company-specific
skills: acme-api, internal-tools
```

**Use Cases**:

```yaml
# PDF specialist with processing skill
name: pdf-expert
skills: pdf-processing
description: PDF editing, form filling, text extraction

# Security auditor with OWASP skill
name: security-auditor
skills: owasp-top-10, security-best-practices
description: Security vulnerability scanning

# Data analyst with SQL skills
name: data-analyst
skills: sql-patterns, bigquery-operations
description: Database querying and analysis
```

**Common Mistakes**:
- Referencing non-existent skills
- Loading too many skills (context bloat)
- Not using progressive disclosure
- Duplicating skill content in prompt

**Best Practices**:
- Load only essential skills
- Keep skill dependencies clear
- Document skill requirements
- Use progressive disclosure
- Test skill availability

**Error Handling**:

Missing skills logged as warnings:
```
Warning: Skill 'non-existent' not found for subagent 'my-agent'
```

Subagent still loads, skill unavailable.

---

## Field Combinations

### Read-Only Analyst

```yaml
name: code-analyst
description: Analyzes code structure and patterns
tools: Read, Grep, Glob
model: sonnet
permissionMode: default
```

**Use case**: Safe code analysis without modifications

---

### Automated Code Formatter

```yaml
name: formatter
description: Automatically formats code files
tools: Read, Edit, Write
model: haiku
permissionMode: acceptEdits
```

**Use case**: Trusted formatting workflow with minimal friction

---

### Security Auditor

```yaml
name: security-auditor
description: Security vulnerability analysis
tools: Read, Grep, Glob, Bash
model: opus
permissionMode: default
skills: owasp-top-10, security-patterns
```

**Use case**: Critical security analysis with maximum capability

---

### Fast Codebase Explorer

```yaml
name: explorer
description: Quick codebase navigation and search
tools: Read, Grep, Glob
model: haiku
permissionMode: plan
```

**Use case**: Read-only exploration, optimized for speed

---

### Fully Automated CI Agent

```yaml
name: ci-agent
description: Automated CI/CD operations
tools: Bash, Read, Edit, Write
model: sonnet
permissionMode: bypassPermissions
```

**Use case**: Trusted automation, requires absolute security

---

## Validation Rules

### Name Validation

```python
import re

def validate_name(name: str) -> bool:
    """Validate subagent name."""
    pattern = r'^[a-z0-9-]+$'
    return (
        bool(re.match(pattern, name)) and
        1 <= len(name) <= 100
    )
```

### Description Validation

```python
def validate_description(description: str) -> bool:
    """Validate description length."""
    return 10 <= len(description) <= 2000
```

### Model Validation

```python
def validate_model(model: str | None) -> bool:
    """Validate model alias."""
    if model is None:
        return True
    return model in ['sonnet', 'opus', 'haiku', 'inherit']
```

### Permission Mode Validation

```python
def validate_permission_mode(mode: str) -> bool:
    """Validate permission mode."""
    return mode in [
        'default',
        'acceptEdits',
        'bypassPermissions',
        'plan',
        'ignore'
    ]
```

---

## Common Patterns

### Pattern: Tiered Capability

Use multiple subagents with different models for cost optimization:

```yaml
# Fast exploration (haiku)
name: explorer
model: haiku
tools: Read, Grep, Glob

# Analysis (sonnet)
name: analyzer
model: sonnet
tools: Read, Bash

# Critical decisions (opus)
name: architect
model: opus
tools: Read, Bash
```

### Pattern: Progressive Permissions

Start restrictive, expand as needed:

```yaml
# Phase 1: Read-only review
name: reviewer-readonly
tools: Read, Grep, Glob
permissionMode: plan

# Phase 2: Suggested edits
name: reviewer-edit
tools: Read, Edit
permissionMode: acceptEdits

# Phase 3: Full automation
name: reviewer-auto
tools: Read, Edit, Write, Bash
permissionMode: bypassPermissions
```

### Pattern: Skill Specialization

Combine subagent with specific skills:

```yaml
name: pdf-specialist
description: PDF processing expert
tools: Bash, Read, Write
model: sonnet
skills: pdf-processing, form-filling
permissionMode: default
```

### Pattern: Domain Isolation

Separate concerns with focused subagents:

```yaml
# Testing
name: test-runner
tools: Bash, Read
description: Run and fix tests

# Code review
name: code-reviewer
tools: Read, Grep, Glob, Bash
description: Review code quality

# Debugging
name: debugger
tools: Read, Edit, Bash
description: Debug errors and failures
```

---

## Troubleshooting

### Field Not Recognized

**Symptom**: Warning about unknown field

**Solution**: Check field name spelling, case-sensitivity

**Valid fields**: name, description, tools, model, permissionMode, skills

### Invalid Name Pattern

**Symptom**: Subagent doesn't load

**Solution**: Ensure name matches `^[a-z0-9-]+$`

**Fix**:
```yaml
# Wrong
name: My_Agent

# Right
name: my-agent
```

### Description Too Short

**Symptom**: Poor discovery, subagent rarely triggers

**Solution**: Expand description with specific triggers

**Minimum**: 10 characters
**Recommended**: 100-500 characters

### Invalid Model Alias

**Symptom**: Subagent uses default instead of specified model

**Solution**: Use valid alias

**Valid**: sonnet, opus, haiku, inherit
**Invalid**: gpt-4, claude-3, custom-model

### Tool Name Misspelled

**Symptom**: Permission errors when using tool

**Solution**: Check exact tool name spelling (case-sensitive)

**Correct**: `Read, Edit, Write`
**Incorrect**: `read, edit, write`

---

## Quick Reference Card

```yaml
---
# Required
name: lowercase-with-hyphens           # Pattern: ^[a-z0-9-]+$
description: Specific triggers and use cases  # 10-2000 chars

# Optional
tools: Tool1, Tool2                    # Or omit for all tools
model: sonnet                          # sonnet|opus|haiku|inherit
permissionMode: default                # See mode reference
skills: skill1, skill2                 # Auto-load skills
---

Markdown system prompt content...
```

**Field Defaults**:
- `tools`: null (inherits all)
- `model`: null (uses default, typically sonnet)
- `permissionMode`: default
- `skills`: null (none loaded)

**Remember**:
- Name: lowercase, hyphens only
- Description: specific triggers matter
- Tools: minimize to essential
- Model: match task complexity
- Permissions: start restrictive
- Skills: load only needed
