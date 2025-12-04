# Claude Code Subagent Protocol Specification

**Version:** 1.0
**Status:** Draft
**Last Updated:** 2025-12-03

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [File Format Specification](#file-format-specification)
4. [Configuration Schema](#configuration-schema)
5. [Tool Access Control](#tool-access-control)
6. [Model Selection](#model-selection)
7. [Permission Modes](#permission-modes)
8. [Skills Integration](#skills-integration)
9. [Subagent Lifecycle](#subagent-lifecycle)
10. [Discovery and Invocation](#discovery-and-invocation)
11. [Context Management](#context-management)
12. [Resumable Subagents](#resumable-subagents)
13. [Built-in Subagents](#built-in-subagents)
14. [Plugin Subagents](#plugin-subagents)
15. [CLI-based Configuration](#cli-based-configuration)
16. [Scope and Precedence](#scope-and-precedence)
17. [Security Considerations](#security-considerations)
18. [Best Practices](#best-practices)
19. [Error Handling](#error-handling)
20. [Examples](#examples)

---

## Overview

The Claude Code Subagent Protocol defines how specialized AI assistants (subagents) are configured, invoked, and managed within Claude Code. Subagents enable task delegation with isolated contexts, custom tool permissions, and specialized system prompts.

### Purpose

Subagents serve to:
- **Isolate context**: Each subagent operates in its own context window
- **Specialize behavior**: Custom system prompts for specific domains
- **Control permissions**: Granular tool access per subagent
- **Preserve main context**: Prevent pollution of the main conversation
- **Enable reusability**: Share subagents across projects and teams

### Key Concepts

- **Subagent**: A specialized AI assistant with specific configuration
- **Matcher**: Pattern used for automatic subagent selection
- **Context Window**: Isolated conversation history for the subagent
- **Scope**: Level of availability (project, user, CLI)
- **Precedence**: Priority order when multiple subagents exist

---

## Architecture

### System Components

```
┌─────────────────────────────────────────────────────────┐
│                    Main Claude Agent                     │
│  ┌───────────────────────────────────────────────────┐  │
│  │              Main Context Window                   │  │
│  │  - User conversations                              │  │
│  │  - High-level objectives                           │  │
│  │  - Subagent delegation decisions                   │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                           │
                           │ delegates task
                           ▼
┌─────────────────────────────────────────────────────────┐
│                      Subagent                            │
│  ┌───────────────────────────────────────────────────┐  │
│  │           Subagent Context Window                  │  │
│  │  - Task-specific prompt                            │  │
│  │  - Specialized system prompt                       │  │
│  │  - Task execution history                          │  │
│  │  - Limited tool access                             │  │
│  └───────────────────────────────────────────────────┘  │
│                                                           │
│  Configuration:                                           │
│  - name: "code-reviewer"                                  │
│  - tools: ["Read", "Grep", "Glob"]                        │
│  - model: "sonnet"                                        │
│  - permissionMode: "default"                              │
└─────────────────────────────────────────────────────────┘
```

### Data Flow

```
1. User Request → Main Agent
2. Main Agent analyzes task
3. Main Agent matches subagent based on description
4. Main Agent invokes subagent via Task tool
5. Subagent executes in isolated context
6. Subagent returns results
7. Main Agent integrates results
8. Main Agent responds to user
```

---

## File Format Specification

### File Structure

Subagents are defined as Markdown files with YAML frontmatter:

```
┌─────────────────────────────────────┐
│ .claude/agents/subagent-name.md     │  (Project scope)
│ ~/.claude/agents/subagent-name.md   │  (User scope)
└─────────────────────────────────────┘
```

### File Format

```markdown
---
name: subagent-identifier
description: When and how to use this subagent
tools: Tool1, Tool2, Tool3
model: sonnet
permissionMode: default
skills: skill1, skill2
---

# Subagent System Prompt

Your subagent's instructions in Markdown format.

## Section 1

Detailed instructions...

## Section 2

More instructions...
```

### YAML Frontmatter Rules

1. **Delimiters**: Must start with `---` on line 1 and close with `---`
2. **Syntax**: Valid YAML (no tabs, correct indentation)
3. **Encoding**: UTF-8
4. **Required fields**: `name`, `description`
5. **Optional fields**: `tools`, `model`, `permissionMode`, `skills`

### Content Rules

1. **Format**: Markdown following CommonMark specification
2. **Minimum length**: 50 characters recommended
3. **Structure**: Clear sections and instructions
4. **Tone**: Direct, actionable guidance

---

## Configuration Schema

### Field Definitions

#### `name` (required)

**Type**: `string`
**Pattern**: `^[a-z0-9-]+$`
**Length**: 1-100 characters
**Description**: Unique identifier for the subagent

**Rules**:
- Lowercase letters only
- Numbers allowed
- Hyphens for word separation
- No spaces, underscores, or special characters
- Must be unique within scope

**Examples**:
```yaml
name: code-reviewer
name: test-runner
name: data-scientist
name: debugger-2023
```

**Invalid**:
```yaml
name: Code_Reviewer  # uppercase and underscore
name: test runner    # space
name: my@agent       # special character
```

#### `description` (required)

**Type**: `string`
**Length**: 10-2000 characters
**Description**: Natural language description of when to use this subagent

**Rules**:
- Include WHAT the subagent does
- Include WHEN to use it
- Use specific, actionable language
- Mention key triggers or scenarios
- Be concise but descriptive

**Best practices**:
```yaml
# Good - specific and actionable
description: Expert code reviewer. Use proactively after code changes to review quality, security, and best practices. Checks for vulnerabilities, performance issues, and maintainability.

# Good - clear triggers
description: Debugging specialist for errors, test failures, and unexpected behavior. Use when encountering exceptions, failing tests, or unexpected program behavior.

# Poor - too vague
description: Helps with code

# Poor - missing when to use
description: Reviews code for quality
```

#### `tools` (optional)

**Type**: `string` or `null`
**Format**: Comma-separated list
**Default**: Inherits all tools from main thread

**Available tools**:
- `Task` - Delegate to subagents
- `Bash` - Execute shell commands
- `Glob` - File pattern matching
- `Grep` - Content search
- `Read` - Read files
- `Edit` - Edit files
- `Write` - Write files
- `NotebookEdit` - Edit Jupyter notebooks
- `WebFetch` - Fetch web content
- `WebSearch` - Search the web
- `BashOutput` - Read background shell output
- `KillShell` - Kill background shells
- `AskUserQuestion` - Ask user questions
- `TodoWrite` - Manage todo lists
- `Skill` - Invoke skills
- `SlashCommand` - Execute slash commands
- `EnterPlanMode` - Enter planning mode
- `ExitPlanMode` - Exit planning mode
- MCP tools: `mcp__<server>__<tool>`

**Rules**:
- Case-sensitive tool names
- Comma-separated (spaces optional after comma)
- Order doesn't matter
- Invalid tool names cause loading errors
- If omitted, inherits ALL tools including MCP

**Examples**:
```yaml
# Minimal read-only access
tools: Read, Grep, Glob

# Code modification
tools: Read, Edit, Write

# Full development workflow
tools: Read, Edit, Write, Bash, Grep, Glob

# Testing and execution
tools: Bash, Read, Edit, TodoWrite

# Inherit all tools (explicit null or omit field)
tools: null
```

#### `model` (optional)

**Type**: `string` or `null`
**Values**: `"sonnet"` | `"opus"` | `"haiku"` | `"inherit"`
**Default**: Uses configured subagent model (typically `sonnet`)

**Model characteristics**:

| Model   | Speed | Capability | Cost | Use Case |
|---------|-------|------------|------|----------|
| haiku   | Fast  | Good       | Low  | Quick searches, simple tasks |
| sonnet  | Medium| Excellent  | Medium | General purpose, complex reasoning |
| opus    | Slow  | Best       | High | Critical tasks requiring maximum capability |
| inherit | Varies| Matches main | Varies | Consistency with main conversation |

**Examples**:
```yaml
# Use fast model for quick searches
model: haiku

# Use powerful model for complex analysis
model: opus

# Match the main conversation's model
model: inherit

# Use default (typically sonnet)
model: null
```

#### `permissionMode` (optional)

**Type**: `string`
**Values**: `"default"` | `"acceptEdits"` | `"bypassPermissions"` | `"plan"` | `"ignore"`
**Default**: `"default"`

**Permission modes**:

| Mode | Behavior | Use Case |
|------|----------|----------|
| `default` | Normal permission flow | Standard operations |
| `acceptEdits` | Auto-approve edit operations | Trusted edit workflows |
| `bypassPermissions` | Skip all permission checks | Fully automated tasks |
| `plan` | Planning mode (read-only exploration) | Research and planning |
| `ignore` | Ignore permission requests | Background operations |

**Examples**:
```yaml
# Standard permission checks
permissionMode: default

# Auto-approve edits for trusted workflows
permissionMode: acceptEdits

# Fully automated subagent
permissionMode: bypassPermissions

# Research without modifications
permissionMode: plan
```

#### `skills` (optional)

**Type**: `string` or `null`
**Format**: Comma-separated list of skill names
**Default**: No skills auto-loaded

**Rules**:
- Skill names must match existing skills
- Skills loaded into subagent context automatically
- Multiple skills can be specified
- Order doesn't matter
- Invalid skill names logged as warnings

**Examples**:
```yaml
# Single skill
skills: pdf-processing

# Multiple skills
skills: code-review, security-analysis, performance-testing

# No skills (explicit null or omit field)
skills: null
```

#### `content` (required - implicit)

**Type**: `string`
**Format**: Markdown
**Location**: Below YAML frontmatter

**Rules**:
- Minimum 50 characters recommended
- Clear, structured instructions
- Specific guidance for the subagent's role
- Include approach, methodology, constraints

**Template**:
```markdown
---
name: subagent-name
description: Description here
---

# Subagent Name

Brief introduction of the subagent's role.

## When Invoked

1. Step-by-step initial actions
2. Context gathering
3. Task execution approach

## Methodology

- Key principle 1
- Key principle 2
- Key principle 3

## Constraints

- What to avoid
- Limitations
- Boundaries

## Output Format

How to present results back to the main agent.
```

---

## Tool Access Control

### Inheritance Model

```
Default Behavior (tools field omitted):
  ├─ Inherits ALL tools from main thread
  ├─ Includes built-in tools
  ├─ Includes MCP tools
  └─ Includes plugin tools

Explicit Configuration (tools field set):
  ├─ Only specified tools available
  ├─ No inheritance
  ├─ Can include MCP tools by name
  └─ Invalid tools cause errors
```

### MCP Tool Access

MCP tools can be granted to subagents:

```yaml
# Grant specific MCP tools
tools: Read, mcp__github__get_issue, mcp__database__query

# Grant all tools from an MCP server
tools: Read, mcp__github__*

# Inherit all MCP tools
tools: null
```

### Security Implications

**Principle of Least Privilege**:
- Grant only necessary tools
- Review tool permissions regularly
- Use read-only tools when possible
- Restrict destructive operations

**Tool Combinations**:
```yaml
# Read-only analysis
tools: Read, Grep, Glob

# Code review (read + bash for git)
tools: Read, Grep, Glob, Bash

# Safe modification (no shell access)
tools: Read, Edit, Write

# Full access (use cautiously)
tools: null  # inherits all
```

---

## Model Selection

### Selection Algorithm

```python
def select_model(subagent_config, main_agent_model, default_subagent_model):
    """
    Determine which model to use for a subagent.

    Priority:
    1. Explicit model in config
    2. 'inherit' uses main agent's model
    3. Default subagent model (typically sonnet)
    """
    if subagent_config.model == 'inherit':
        return main_agent_model
    elif subagent_config.model in ['sonnet', 'opus', 'haiku']:
        return subagent_config.model
    else:
        return default_subagent_model
```

### Model Selection Strategy

**Use Haiku when**:
- Simple, focused tasks
- Speed is critical
- Cost optimization needed
- Exploring large codebases (Explore subagent)

**Use Sonnet when**:
- Complex reasoning required
- General-purpose tasks
- Balanced speed and capability
- Most standard subagents

**Use Opus when**:
- Maximum capability needed
- Critical decision-making
- Complex multi-step workflows
- Highest quality outputs required

**Use Inherit when**:
- Consistency with main conversation
- User has selected specific model
- Capabilities must match main agent

---

## Permission Modes

### Mode Behaviors

#### `default`
- Standard permission flow
- User approves destructive operations
- Follows global permission settings
- Recommended for most subagents

#### `acceptEdits`
- Auto-approves Edit/Write operations
- Still requires approval for Bash, destructive ops
- Good for trusted code modification workflows
- Reduces permission prompts

#### `bypassPermissions`
- Skips ALL permission checks
- Fully automated execution
- Use only for completely trusted subagents
- Security risk if misused

#### `plan`
- Read-only exploration mode
- Cannot modify files or execute commands
- Used by Plan subagent
- Safe for research and planning

#### `ignore`
- Ignores permission requests
- Continues execution without waiting
- For background operations
- Use cautiously

### Permission Flow

```
Tool Call Request
       ↓
Check permissionMode
       ↓
┌──────┴──────┐
│  default    │ → Check user permissions → Prompt if needed
├─────────────┤
│ acceptEdits │ → Auto-approve edits → Prompt for others
├─────────────┤
│ bypass      │ → Allow all operations
├─────────────┤
│ plan        │ → Block write operations
├─────────────┤
│ ignore      │ → Ignore permission dialogs
└─────────────┘
```

---

## Skills Integration

### Auto-loading Skills

Skills specified in the `skills` field are automatically loaded into the subagent's context:

```yaml
---
name: pdf-processor
description: Process PDF files with advanced capabilities
skills: pdf-processing, form-filling
---

# PDF Processor

When this subagent starts, the pdf-processing and form-filling
skills are automatically available in context.
```

### Skill Resolution

1. **Skill lookup**: Skills searched in standard locations
   - `.claude/skills/` (project)
   - `~/.claude/skills/` (user)
   - Plugin skills

2. **Loading priority**: Project > User > Plugin

3. **Error handling**:
   - Missing skills logged as warnings
   - Subagent still loads
   - Skills may become available later

### Progressive Disclosure

Skills use progressive disclosure:
- Main `SKILL.md` loaded initially
- Additional files loaded on-demand
- Reduces context usage
- Maintains efficiency

---

## Subagent Lifecycle

### Creation

```
1. File created in agents/ directory
   ├─ .claude/agents/name.md (project)
   └─ ~/.claude/agents/name.md (user)

2. File parsed and validated
   ├─ YAML frontmatter validated
   ├─ Required fields checked
   ├─ Tool names verified
   └─ Model alias validated

3. Subagent registered
   ├─ Added to subagent registry
   ├─ Description indexed for matching
   └─ Available for invocation
```

### Loading

Subagents loaded when:
- Claude Code starts
- `/agents` command executed
- Session resumed
- Compact operation

Loading process:
1. Scan agent directories
2. Parse YAML frontmatter
3. Validate configuration
4. Register with main agent
5. Index descriptions

### Invocation

```
Automatic Invocation:
  1. User makes request
  2. Main agent analyzes task
  3. Description matching occurs
  4. Best subagent selected
  5. Task tool called with prompt

Explicit Invocation:
  1. User mentions subagent by name
  2. Main agent delegates directly
  3. Task tool called immediately

Resume Invocation:
  1. Reference previous agentId
  2. Load previous transcript
  3. Continue conversation
```

### Execution

```
1. Subagent receives:
   ├─ Task description/prompt
   ├─ Configuration (tools, model, etc.)
   ├─ Isolated context window
   └─ Skills (if configured)

2. Subagent executes:
   ├─ Reads system prompt
   ├─ Processes task
   ├─ Uses allowed tools
   └─ Generates response

3. Subagent returns:
   ├─ Final response
   ├─ Tool usage summary
   └─ Agent ID (for resume)
```

### Termination

Normal termination:
- Task completed
- Response generated
- Context saved to transcript
- Agent ID returned

Abnormal termination:
- User interrupt
- Timeout
- Error condition
- Permission denied

---

## Discovery and Invocation

### Automatic Discovery

Main agent uses description matching:

```python
def match_subagent(task_description, subagents):
    """
    Match task to best subagent based on description.

    Matching factors:
    - Keywords in description
    - Task type indicators
    - Context similarity
    - Explicit triggers ("use PROACTIVELY")
    """
    scores = []
    for subagent in subagents:
        score = calculate_similarity(task_description, subagent.description)
        scores.append((subagent, score))

    # Return highest scoring subagent
    return max(scores, key=lambda x: x[1])[0]
```

### Improving Discovery

**Strong triggers**:
```yaml
# Emphatic language
description: Use PROACTIVELY when code changes are made to run tests

# Specific scenarios
description: MUST BE USED when reviewing pull requests or code changes

# Clear conditions
description: Automatically use when encountering test failures or exceptions
```

**Keywords and phrases**:
- "use when"
- "use for"
- "proactively"
- "must be used"
- "automatically"
- Specific file types (.pdf, .xlsx)
- Specific operations (debug, review, test)

### Explicit Invocation

Users can explicitly request subagents:

```
> Use the code-reviewer subagent to check my changes
> Have the debugger subagent investigate this error
> Ask the data-scientist subagent to analyze this CSV
```

Main agent recognizes:
- Subagent names mentioned
- "use [name]" patterns
- "ask [name]" patterns
- "[name] subagent" phrases

---

## Context Management

### Isolated Contexts

Each subagent maintains separate context:

```
Main Agent Context:
  ├─ User conversation history
  ├─ High-level objectives
  ├─ Subagent delegation decisions
  └─ Integrated subagent results

Subagent Context (isolated):
  ├─ Task-specific prompt
  ├─ Subagent system prompt
  ├─ Tool usage during task
  └─ Task execution history
```

### Benefits of Isolation

1. **Prevents pollution**: Main context stays focused
2. **Enables specialization**: Task-specific optimization
3. **Improves efficiency**: Smaller, relevant contexts
4. **Allows parallelization**: Multiple subagents concurrently

### Context Handoff

```
Main → Subagent:
  ├─ Task description
  ├─ Relevant context snippet
  └─ Expected deliverables

Subagent → Main:
  ├─ Final response
  ├─ Key findings
  └─ Recommendations
```

### Transcript Storage

Subagent conversations stored separately:

```
~/.claude/projects/PROJECT_ID/
  ├─ SESSION_ID.jsonl              # Main conversation
  └─ agent-AGENT_ID.jsonl          # Subagent conversation
```

---

## Resumable Subagents

### Resume Mechanism

Subagents can be resumed to continue previous work:

```yaml
# Initial invocation generates agentId
{
  "description": "Analyze authentication module",
  "prompt": "Review the authentication code for security issues",
  "subagent_type": "code-reviewer"
}
# Returns: agentId = "abc123"

# Resume later with full context
{
  "description": "Continue analysis",
  "prompt": "Now check the authorization logic too",
  "subagent_type": "code-reviewer",
  "resume": "abc123"
}
```

### Resume Process

```
1. Resume request received
   ├─ agentId provided
   └─ Continue prompt given

2. Load previous transcript
   ├─ Read agent-{agentId}.jsonl
   ├─ Restore conversation history
   └─ Maintain context

3. Continue execution
   ├─ Process new prompt
   ├─ Access previous findings
   └─ Build on prior work

4. Update transcript
   ├─ Append to same file
   ├─ Maintain continuity
   └─ Keep agentId
```

### Use Cases

**Long-running research**:
```
Session 1: Initial codebase exploration
Session 2: Deep dive into specific modules
Session 3: Final recommendations
```

**Iterative refinement**:
```
Iteration 1: First draft of analysis
Iteration 2: Address feedback
Iteration 3: Final polished output
```

**Multi-step workflows**:
```
Step 1: Gather requirements
Step 2: Design solution
Step 3: Implementation plan
```

### Best Practices

- Track agentIds for important investigations
- Resume for related tasks, not unrelated ones
- Consider when context helps vs. starting fresh
- Clean up old transcripts periodically

---

## Built-in Subagents

### General-Purpose Subagent

**Purpose**: Complex, multi-step tasks requiring exploration and modification

**Configuration**:
```yaml
name: general-purpose
description: Capable agent for complex, multi-step tasks. Use when task requires both exploration and action.
tools: null  # All tools
model: sonnet
```

**Characteristics**:
- Full tool access
- Can read and write
- Complex reasoning
- Multi-step operations

### Plan Subagent

**Purpose**: Research and planning in plan mode

**Configuration**:
```yaml
name: plan
description: Planning and research specialist. Used automatically in plan mode.
tools: Read, Glob, Grep, Bash
model: sonnet
permissionMode: plan
```

**Characteristics**:
- Read-only operations
- Codebase exploration
- Information gathering
- Cannot modify files

### Explore Subagent

**Purpose**: Fast, lightweight codebase exploration

**Configuration**:
```yaml
name: explore
description: Fast codebase explorer. Use for searching and analyzing code without modifications.
tools: Glob, Grep, Read, Bash
model: haiku
permissionMode: plan
```

**Characteristics**:
- Strictly read-only
- Fast (uses Haiku)
- Pattern matching
- Content searching

**Thoroughness levels**:
- `quick`: Basic searches, fastest
- `medium`: Moderate exploration
- `very thorough`: Comprehensive analysis

---

## Plugin Subagents

### Plugin Architecture

Plugins can provide subagents:

```
plugin-directory/
  └─ agents/
      ├─ custom-agent-1.md
      └─ custom-agent-2.md
```

Or custom path in plugin manifest:

```json
{
  "name": "my-plugin",
  "agents": "custom-agents-dir"
}
```

### Integration

Plugin subagents:
- Appear in `/agents` interface
- Work like user-defined subagents
- Can be invoked automatically or explicitly
- Managed through plugin installation

### Priority

When names conflict:
1. Project-level subagents (highest)
2. User-level subagents
3. Plugin subagents
4. Built-in subagents (lowest)

---

## CLI-based Configuration

### JSON Format

```bash
claude --agents '{
  "code-reviewer": {
    "description": "Expert code reviewer. Use proactively after code changes.",
    "prompt": "You are a senior code reviewer...",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  }
}'
```

### Schema

```json
{
  "subagent-name": {
    "description": "string (required)",
    "prompt": "string (required)",
    "tools": ["string", "..."] or null,
    "model": "sonnet" | "opus" | "haiku" | "inherit",
    "permissionMode": "default" | "acceptEdits" | "bypassPermissions" | "plan" | "ignore",
    "skills": ["string", "..."] or null
  }
}
```

### Use Cases

- Quick testing
- Session-specific subagents
- Automation scripts
- Documentation examples
- CI/CD integrations

### Limitations

- Not persisted across sessions
- No file-based management
- Must be valid JSON
- Shell escaping required

---

## Scope and Precedence

### Scope Levels

```
┌─────────────────────────────────────┐
│  CLI-defined (--agents flag)        │  Lowest precedence
├─────────────────────────────────────┤
│  User-level (~/.claude/agents/)     │  Medium precedence
├─────────────────────────────────────┤
│  Project-level (.claude/agents/)    │  Highest precedence
└─────────────────────────────────────┘
```

### Precedence Rules

When subagents with same name exist:

1. **Project** subagent used (if exists)
2. **User** subagent used (if no project)
3. **CLI** subagent used (if no project/user)
4. **Built-in** subagent used (if no custom)

### Conflict Resolution

```python
def resolve_subagent(name, project_agents, user_agents, cli_agents, builtin_agents):
    """
    Resolve subagent by name with precedence.
    """
    if name in project_agents:
        return project_agents[name]
    elif name in user_agents:
        return user_agents[name]
    elif name in cli_agents:
        return cli_agents[name]
    elif name in builtin_agents:
        return builtin_agents[name]
    else:
        raise SubagentNotFoundError(name)
```

### Visibility

```bash
# View all subagents with precedence
/agents

# Shows:
# - Active subagent (when duplicates)
# - Source (project/user/plugin/built-in)
# - Configuration details
```

---

## Security Considerations

### Threat Model

**Risks**:
1. Malicious subagent configurations
2. Excessive tool permissions
3. Unintended automation
4. Context leakage
5. Resource exhaustion

### Mitigation Strategies

#### 1. Principle of Least Privilege

```yaml
# Good - minimal necessary tools
name: log-analyzer
tools: Read, Grep
permissionMode: default

# Bad - excessive permissions
name: log-analyzer
tools: null  # inherits all tools including Bash
permissionMode: bypassPermissions
```

#### 2. Code Review

- Review subagent files before use
- Especially from untrusted sources
- Check tool permissions
- Verify system prompts

#### 3. Permission Modes

```yaml
# Safe default
permissionMode: default

# Automatic but limited
permissionMode: acceptEdits

# Only for fully trusted
permissionMode: bypassPermissions
```

#### 4. Scope Isolation

- Project subagents only for team
- User subagents for personal use
- Be cautious with CLI subagents

#### 5. Tool Restrictions

```yaml
# Read-only operations
tools: Read, Grep, Glob

# No shell access
tools: Read, Edit, Write

# Explicit tool list (not null)
tools: Read, Bash
```

### Trust Boundaries

```
High Trust:
  ├─ Built-in subagents
  ├─ Project subagents (code-reviewed)
  └─ User subagents (created by you)

Medium Trust:
  ├─ Official plugin subagents
  └─ Verified marketplace plugins

Low Trust:
  ├─ Third-party plugins
  ├─ Community subagents
  └─ Untested configurations

Never Trust:
  ├─ Random internet configs
  ├─ Unreviewed complex prompts
  └─ BypassPermissions without review
```

---

## Best Practices

### 1. Design Focused Subagents

**Do**:
```yaml
name: test-runner
description: Run tests and fix failures. Use after code changes.
tools: Bash, Read, Edit
```

**Don't**:
```yaml
name: everything
description: Does everything you might need
tools: null
```

### 2. Write Detailed Prompts

**Do**:
```markdown
# Code Reviewer

You are a senior code reviewer ensuring quality and security.

## When Invoked
1. Run git diff to see changes
2. Focus on modified files only
3. Begin review immediately

## Review Checklist
- Code readability
- Function naming
- Error handling
- Security vulnerabilities
- Test coverage

## Output Format
Provide feedback in three categories:
- Critical issues (must fix)
- Warnings (should fix)
- Suggestions (consider improving)

Include specific examples for each issue.
```

**Don't**:
```markdown
Review code for quality.
```

### 3. Limit Tool Access

**Do**:
```yaml
# Read-only analysis
tools: Read, Grep, Glob

# Safe modification
tools: Read, Edit, Write

# Specific needs
tools: Read, Bash
```

**Don't**:
```yaml
# Excessive permissions
tools: null
permissionMode: bypassPermissions
```

### 4. Version Control

```bash
# Commit project subagents
git add .claude/agents/
git commit -m "Add code reviewer subagent"

# Share with team
git push
```

### 5. Use Descriptive Names

**Do**:
- `code-reviewer`
- `test-runner`
- `security-auditor`
- `performance-analyzer`

**Don't**:
- `agent1`
- `helper`
- `utility`
- `my-agent`

### 6. Optimize for Discovery

**Do**:
```yaml
description: Security audit specialist for code review. Use PROACTIVELY when reviewing code, checking for vulnerabilities, or analyzing security implications. Checks OWASP Top 10, injection attacks, authentication issues.
```

**Don't**:
```yaml
description: Helps with security stuff
```

### 7. Document Purpose

```markdown
---
name: api-tester
description: API testing specialist. Use when testing REST APIs or debugging HTTP requests.
---

# API Testing Specialist

## Purpose
This subagent specializes in testing REST APIs, validating responses,
and debugging HTTP request/response issues.

## Capabilities
- Send HTTP requests with various methods
- Validate response codes and bodies
- Test authentication flows
- Debug API issues

## Limitations
- Cannot test GraphQL APIs
- No websocket testing
- Requires curl or similar tools
```

### 8. Test Before Deployment

```bash
# Create test subagent
.claude/agents/test-agent.md

# Test invocation
> Use the test-agent to check if it works

# Verify behavior
# Check tool usage
# Review outputs

# Deploy when satisfied
git add .claude/agents/test-agent.md
git commit -m "Add tested subagent"
```

### 9. Maintain Clean Configurations

```yaml
# Good - clean and organized
---
name: data-analyzer
description: Analyze CSV and JSON data files. Use when working with datasets or data analysis tasks.
tools: Read, Bash
model: sonnet
---

# Bad - cluttered with comments
---
# This is my data analyzer
name: data-analyzer  # The name
description: Analyze CSV and JSON data files. Use when working with datasets or data analysis tasks.  # What it does
tools: Read, Bash  # Tools it can use
model: sonnet  # Which model
---
```

### 10. Monitor and Refine

- Track subagent usage
- Review effectiveness
- Gather team feedback
- Iterate on descriptions
- Update system prompts
- Adjust tool permissions

---

## Error Handling

### Validation Errors

**Invalid YAML**:
```
Error: Failed to parse subagent 'name.md'
Cause: Invalid YAML frontmatter
Line: 3
Fix: Check YAML syntax, ensure proper indentation
```

**Missing Required Fields**:
```
Error: Subagent 'name.md' missing required field
Field: description
Fix: Add description field to YAML frontmatter
```

**Invalid Tool Names**:
```
Warning: Unknown tool 'InvalidTool' in subagent 'name.md'
Effect: Subagent may fail when trying to use tool
Fix: Check tool name spelling, see available tools
```

### Runtime Errors

**Tool Not Available**:
```
Error: Subagent 'code-reviewer' attempted to use denied tool 'Bash'
Cause: Tool not in allowed tools list
Fix: Add Bash to tools field or remove tool usage
```

**Permission Denied**:
```
Error: Permission denied for tool 'Write'
Cause: Permission mode requires user approval
Fix: Approve permission or adjust permissionMode
```

**Model Not Available**:
```
Error: Model 'custom-model' not available
Cause: Invalid model alias
Fix: Use 'sonnet', 'opus', 'haiku', or 'inherit'
```

### Graceful Degradation

```python
def load_subagent(path):
    """
    Load subagent with error handling.
    """
    try:
        content = read_file(path)
        config = parse_yaml_frontmatter(content)
        validate_config(config)
        return Subagent(config)
    except YAMLError as e:
        log_error(f"Invalid YAML in {path}: {e}")
        return None
    except ValidationError as e:
        log_error(f"Invalid config in {path}: {e}")
        return None
    except Exception as e:
        log_error(f"Failed to load {path}: {e}")
        return None
```

---

## Examples

### Example 1: Code Reviewer

**File**: `.claude/agents/code-reviewer.md`

```markdown
---
name: code-reviewer
description: Expert code review specialist. Proactively reviews code for quality, security, and maintainability. Use immediately after writing or modifying code.
tools: Read, Grep, Glob, Bash
model: inherit
permissionMode: default
---

# Code Reviewer

You are a senior code reviewer ensuring high standards of code quality and security.

## When Invoked

1. Run `git diff --staged` to see recent changes
2. Focus on modified files
3. Begin review immediately without asking permission

## Review Checklist

### Code Quality
- Code is simple and readable
- Functions and variables are well-named
- No duplicated code
- Proper error handling
- Good test coverage

### Security
- No exposed secrets or API keys
- Input validation implemented
- SQL injection prevention
- XSS prevention
- CSRF protection

### Performance
- No obvious performance issues
- Appropriate data structures
- Efficient algorithms
- Resource cleanup

## Output Format

Provide feedback organized by priority:

### Critical Issues (Must Fix)
- Issue description
- Location (file:line)
- Why it's critical
- How to fix with code example

### Warnings (Should Fix)
- Issue description
- Impact assessment
- Recommended fix

### Suggestions (Consider Improving)
- Enhancement ideas
- Code quality improvements
- Best practice recommendations

## Example Output

**Critical Issues**

1. **SQL Injection Vulnerability** (users.py:45)
   - Using string concatenation for SQL query
   - Fix: Use parameterized queries
   ```python
   # Bad
   query = f"SELECT * FROM users WHERE id = {user_id}"

   # Good
   query = "SELECT * FROM users WHERE id = ?"
   cursor.execute(query, (user_id,))
   ```

**Warnings**

1. **Missing Error Handling** (api.py:120)
   - Network request without try/except
   - Could crash on connection failure
   - Add appropriate error handling

**Suggestions**

1. **Extract Magic Numbers** (config.py:15)
   - Timeout value hardcoded as 30
   - Consider using named constant
```

### Example 2: Test Runner

**File**: `.claude/agents/test-runner.md`

```markdown
---
name: test-runner
description: Test automation expert. Use proactively to run tests and fix failures when code changes are made.
tools: Bash, Read, Edit, TodoWrite
model: haiku
permissionMode: acceptEdits
skills: testing-best-practices
---

# Test Runner

You are a test automation expert specializing in running tests and fixing failures.

## When Invoked

When you see code changes, proactively:
1. Identify the appropriate test suite
2. Run the tests
3. If tests fail, analyze and fix them
4. Preserve the original test intent
5. Ensure all tests pass

## Test Identification

### By File Type
- Python: `pytest path/to/test_*.py`
- JavaScript: `npm test` or `jest path/to/*.test.js`
- Go: `go test ./...`
- Rust: `cargo test`

### By Convention
- Tests in `tests/` or `__tests__/` directories
- Files matching `test_*.py`, `*_test.go`, `*.test.js`
- Check for `package.json` scripts or `Makefile` targets

## Failure Analysis

When tests fail:

1. **Read the error message carefully**
   - What assertion failed?
   - What was expected vs actual?
   - Which test function?

2. **Check recent changes**
   - What code changed?
   - Does the test need updating?
   - Is the test revealing a real bug?

3. **Preserve test intent**
   - Don't just make tests pass
   - Ensure tests still validate behavior
   - Update tests only if behavior changed intentionally

## Fix Strategy

### Bug in Code
```python
# Test reveals actual bug
# Fix the implementation, not the test
def calculate_total(items):
    # Bug: missing tax calculation
    return sum(item.price for item in items)

# Fixed
def calculate_total(items):
    subtotal = sum(item.price for item in items)
    tax = subtotal * 0.08
    return subtotal + tax
```

### Test Needs Update
```python
# Behavior intentionally changed
# Update test to match new behavior
def test_email_format():
    # Old: email = format_email(user)
    # assert "@" in email

    # New: format changed to include display name
    email = format_email(user)
    assert "<" in email and ">" in email
    assert user.email in email
```

## Reporting

After running tests:

1. **Success**: Report number of tests passed
2. **Failure**:
   - Show failed test names
   - Explain the failures
   - Describe fixes applied
   - Confirm all tests now pass

## Example Workflow

```bash
# 1. Run tests
pytest tests/

# 2. If failures, analyze output
# 3. Fix issues
# 4. Re-run tests
pytest tests/

# 5. Confirm all pass
# ✓ 45 tests passed
```
```

### Example 3: Debugger

**File**: `~/.claude/agents/debugger.md`

```markdown
---
name: debugger
description: Debugging specialist for errors, test failures, and unexpected behavior. Use proactively when encountering exceptions, crashes, or unexpected program behavior.
tools: Read, Edit, Bash, Grep, Glob, TodoWrite
model: sonnet
permissionMode: acceptEdits
---

# Debugging Specialist

You are an expert debugger specializing in root cause analysis and systematic problem-solving.

## When Invoked

Use proactively when:
- Exceptions or errors occur
- Tests fail unexpectedly
- Program behavior doesn't match expectations
- Crashes or hangs happen
- Logic errors discovered

## Debugging Process

### 1. Capture Information

```bash
# Get error message and stack trace
# Note exact error message
# Identify error location (file:line)
# List affected functions in call stack
```

### 2. Reproduce

- Identify minimum steps to reproduce
- Isolate the specific input causing failure
- Determine if error is consistent or intermittent

### 3. Hypothesize

Generate potential root causes:
- Logic error in algorithm
- Incorrect assumptions
- Edge case not handled
- State corruption
- Race condition
- External dependency issue

### 4. Investigate

For each hypothesis:
- Read relevant code sections
- Add strategic debug logging
- Test hypothesis with specific inputs
- Eliminate or confirm

### 5. Fix

- Implement minimal fix
- Ensure fix addresses root cause, not symptoms
- Add tests to prevent regression
- Clean up debug logging

### 6. Verify

- Run tests
- Verify fix with original reproduction steps
- Check for side effects
- Confirm no new issues introduced

## Debugging Techniques

### Add Debug Logging

```python
# Strategic logging at key points
def process_data(data):
    print(f"DEBUG: Input data type: {type(data)}, length: {len(data)}")

    result = transform(data)
    print(f"DEBUG: After transform: {result}")

    validated = validate(result)
    print(f"DEBUG: Validation result: {validated}")

    return validated
```

### Binary Search

```python
# Comment out sections to isolate problem
def complex_function(x):
    step1 = process_step1(x)
    # step2 = process_step2(step1)  # COMMENTED
    # step3 = process_step3(step2)  # COMMENTED
    return step1  # Temporarily return early
```

### Inspect State

```python
# Check variable values at failure point
try:
    result = risky_operation(data)
except Exception as e:
    print(f"DEBUG: data = {data}")
    print(f"DEBUG: type(data) = {type(data)}")
    print(f"DEBUG: dir(data) = {dir(data)}")
    raise
```

### Check Assumptions

```python
# Validate assumptions explicitly
def calculate(a, b):
    assert isinstance(a, int), f"Expected int, got {type(a)}"
    assert isinstance(b, int), f"Expected int, got {type(b)}"
    assert b != 0, "Division by zero"
    return a / b
```

## Common Issues

### Off-by-One Errors

```python
# Wrong: excludes last element
for i in range(len(items) - 1):
    process(items[i])

# Correct
for i in range(len(items)):
    process(items[i])
```

### Mutable Default Arguments

```python
# Wrong: list shared across calls
def add_item(item, items=[]):
    items.append(item)
    return items

# Correct
def add_item(item, items=None):
    if items is None:
        items = []
    items.append(item)
    return items
```

### Shallow vs Deep Copy

```python
# Wrong: shallow copy
new_data = old_data.copy()
new_data[0]["value"] = 100  # Modifies old_data too!

# Correct: deep copy
import copy
new_data = copy.deepcopy(old_data)
```

## Output Format

### Root Cause

Clearly state the root cause:
- What is the actual problem?
- Why does it occur?
- What evidence supports this?

### Fix

Provide the specific fix:
- What code to change
- Exact changes to make
- Why this fixes the problem

### Testing

Explain how to verify:
- Reproduction steps
- Expected vs actual behavior
- Test cases to add

### Prevention

Recommend preventive measures:
- Code patterns to avoid
- Tests to add
- Validation to include

## Example Report

**Root Cause**

The error occurs in `users.py:45` because the code assumes `user.email`
is always a string, but it can be `None` for users who haven't verified
their email. When calling `.lower()` on `None`, Python raises
`AttributeError: 'NoneType' object has no attribute 'lower'`.

**Evidence**

Stack trace shows error at line 45:
```python
normalized_email = user.email.lower()  # Fails when email is None
```

Database query confirms some users have `email = NULL`.

**Fix**

Add null check before calling `.lower()`:

```python
# Before
normalized_email = user.email.lower()

# After
normalized_email = user.email.lower() if user.email else None
```

**Testing**

1. Create test user with `email = None`
2. Call `process_user(user)`
3. Should not raise exception
4. Should handle gracefully

**Prevention**

- Add database constraint requiring email or allowing explicit null
- Add type hints: `email: Optional[str]`
- Add validation in user creation
```

### Example 4: Data Scientist

**File**: `.claude/agents/data-scientist.md`

```markdown
---
name: data-scientist
description: Data analysis expert for SQL queries, BigQuery operations, and data insights. Use proactively for data analysis tasks, database queries, or statistical analysis.
tools: Bash, Read, Write
model: sonnet
---

# Data Scientist

You are a data scientist specializing in SQL, BigQuery analysis, and data-driven insights.

## When Invoked

Use for:
- SQL query writing and optimization
- BigQuery operations
- Data analysis and visualization
- Statistical analysis
- Data pipeline debugging
- Schema exploration

## Capabilities

### SQL Query Writing

Write efficient, readable SQL:

```sql
-- Good: Clear, optimized, documented
-- Get top 10 customers by revenue this month
SELECT
    c.customer_id,
    c.name,
    SUM(o.total) AS monthly_revenue
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_date >= DATE_TRUNC('month', CURRENT_DATE)
GROUP BY c.customer_id, c.name
ORDER BY monthly_revenue DESC
LIMIT 10;
```

### BigQuery CLI

Use `bq` command-line tool:

```bash
# Query with parameters
bq query --use_legacy_sql=false '
SELECT * FROM `project.dataset.table`
WHERE date >= @start_date
LIMIT 100
' --parameter=start_date:DATE:2024-01-01

# Export results
bq extract dataset.table gs://bucket/data.csv

# Show schema
bq show --schema dataset.table
```

### Data Analysis

Provide insights:

1. **Descriptive statistics**
   - Count, sum, average
   - Min, max, median
   - Standard deviation

2. **Trends**
   - Time-based patterns
   - Growth rates
   - Seasonality

3. **Segments**
   - Customer groups
   - Product categories
   - Geographic regions

4. **Anomalies**
   - Outliers
   - Unexpected patterns
   - Data quality issues

## Best Practices

### Query Optimization

```sql
-- Bad: SELECT *
SELECT * FROM large_table WHERE date = '2024-01-01';

-- Good: Select specific columns
SELECT id, name, amount
FROM large_table
WHERE date = '2024-01-01';

-- Bad: No filtering in subquery
SELECT AVG(revenue) FROM (SELECT * FROM sales);

-- Good: Filter early
SELECT AVG(revenue)
FROM (SELECT revenue FROM sales WHERE date >= '2024-01-01');
```

### Data Quality

Always check:
- Null values
- Duplicates
- Data types
- Value ranges
- Referential integrity

### Documentation

Include in analysis:
- Query purpose
- Data sources
- Assumptions
- Limitations
- Caveats

## Output Format

### Query Results

```
Query: Get top products by revenue

Results:
+------------+------------------+----------+
| product_id | product_name     | revenue  |
+------------+------------------+----------+
| 123        | Premium Widget   | $50,432  |
| 456        | Deluxe Gadget    | $43,211  |
| 789        | Standard Tool    | $38,901  |
+------------+------------------+----------+

Key Findings:
- Premium Widget leads by 16%
- Top 3 represent 65% of total revenue
- All in "Premium" category

Recommendations:
- Focus marketing on premium products
- Consider premium bundle offers
- Investigate lower-tier performance
```

### Schema Documentation

```
Table: customers
- customer_id (INTEGER, PRIMARY KEY)
- email (STRING, UNIQUE, NOT NULL)
- created_at (TIMESTAMP, NOT NULL)
- country (STRING)
- lifetime_value (FLOAT)

Relationships:
- 1:N with orders (customer_id)
- 1:N with support_tickets (customer_id)

Indexes:
- email (unique)
- country (non-unique)
- created_at (non-unique)
```

### Analysis Summary

```
Analysis: Customer Churn Rate

Period: Q1 2024
Sample Size: 10,432 customers

Findings:
1. Overall churn rate: 12.3%
2. Highest churn in first 30 days: 18.7%
3. Lowest churn after 6 months: 3.2%

Segments:
- Free tier: 22.1% churn
- Paid tier: 6.4% churn
- Enterprise: 1.2% churn

Root Causes:
- Onboarding friction (surveys)
- Feature complexity (support tickets)
- Pricing concerns (exit interviews)

Recommendations:
1. Improve onboarding for free users
2. Simplify feature discovery
3. Add mid-tier pricing option
```
```

---

## Conclusion

This specification defines the complete protocol for Claude Code subagents, including:

- File format and structure
- Configuration schema and validation
- Tool access control mechanisms
- Model selection strategies
- Permission mode behaviors
- Lifecycle management
- Discovery and invocation patterns
- Context isolation and management
- Security considerations
- Best practices and examples

Implementations should adhere to this specification to ensure consistent behavior across different environments and use cases.

---

## Appendix A: YAML Frontmatter Template

```yaml
---
# Required fields
name: subagent-identifier
description: Detailed description of when and how to use this subagent

# Optional fields
tools: Tool1, Tool2, Tool3  # or omit to inherit all
model: sonnet               # or opus, haiku, inherit
permissionMode: default     # or acceptEdits, bypassPermissions, plan, ignore
skills: skill1, skill2      # or omit if none
---
```

## Appendix B: Complete Example

See [Example 1: Code Reviewer](#example-1-code-reviewer) for a complete, production-ready subagent configuration.

## Appendix C: Tool Reference

Available tools (partial list):
- Task, Bash, Glob, Grep, Read, Edit, Write
- NotebookEdit, WebFetch, WebSearch
- BashOutput, KillShell
- AskUserQuestion, TodoWrite
- Skill, SlashCommand
- EnterPlanMode, ExitPlanMode
- MCP tools: `mcp__<server>__<tool>`

## Appendix D: Model Aliases

- `sonnet` - Claude Sonnet (balanced)
- `opus` - Claude Opus (most capable)
- `haiku` - Claude Haiku (fastest)
- `inherit` - Use main agent's model

## Appendix E: Permission Modes

- `default` - Standard permission flow
- `acceptEdits` - Auto-approve edits
- `bypassPermissions` - Skip all permissions
- `plan` - Read-only mode
- `ignore` - Ignore permission dialogs

---

**Document Version**: 1.0
**Protocol Version**: 1.0
**Last Updated**: 2025-12-03
**Authors**: Claude Code Team
**License**: Anthropic Documentation License
