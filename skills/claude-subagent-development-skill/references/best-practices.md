# Subagent Development Best Practices

Advanced patterns, strategies, and recommendations for creating production-ready Claude Code subagents.

## Design Principles

### 1. Single Responsibility

Each subagent should have one clear purpose.

**Good** - Focused:
```yaml
name: test-runner
description: Runs tests and fixes failures
tools: Bash, Read, Edit
```

**Bad** - Too broad:
```yaml
name: dev-helper
description: Helps with development tasks
tools: null  # everything
```

**Why**: Focused subagents are easier to maintain, test, and improve.

### 2. Principle of Least Privilege

Grant minimum necessary tools and permissions.

**Good** - Minimal:
```yaml
name: code-analyzer
description: Analyzes code structure
tools: Read, Grep, Glob
permissionMode: default
```

**Bad** - Excessive:
```yaml
name: code-analyzer
description: Analyzes code structure
tools: null  # all tools
permissionMode: bypassPermissions
```

**Why**: Reduces security risks and prevents unintended side effects.

### 3. Progressive Disclosure

Keep system prompts focused, reference detailed docs when needed.

**Good** - Concise with references:
```markdown
## Analysis Process

1. Read target files
2. Apply heuristics (see analysis-patterns.md)
3. Report findings

For detailed patterns, see:
- references/security-patterns.md
- references/performance-patterns.md
```

**Bad** - Everything inline:
```markdown
## Analysis Process

[5000 words of detailed patterns inline...]
```

**Why**: Keeps context focused, loads details only when needed.

## Description Best Practices

### Use Specific Triggers

Include exact phrases users would say.

**Excellent**:
```yaml
description: PDF processing expert. Use when user asks to "process PDF", "fill PDF form", "extract PDF text", "merge PDFs", or mentions .pdf files. Handles PDF editing, form filling, text extraction.
```

**Good**:
```yaml
description: Security auditor for vulnerability scanning. Use for security reviews, penetration testing, OWASP checks.
```

**Poor**:
```yaml
description: Helps with PDFs
```

### Emphatic Language

Use emphasis strategically for proactive invocation.

**Strong**:
```yaml
description: Test automation expert. Use PROACTIVELY after code changes to run tests. MUST BE USED when tests fail. Automatically runs test suites.
```

**Moderate**:
```yaml
description: Code reviewer. Use after code changes for quality checks.
```

**Weak**:
```yaml
description: Reviews code when asked
```

### Include Domain Indicators

Mention file types, technologies, operations.

**Rich context**:
```yaml
description: Frontend developer specializing in React, TypeScript, and Tailwind CSS. Use when working with .tsx, .jsx, .ts files, building UI components, or implementing designs. Handles React hooks, state management, responsive design.
```

**Minimal context**:
```yaml
description: Frontend development helper
```

## Tool Selection Strategies

### Read-Only Analysis

For analysis without modifications:

```yaml
tools: Read, Grep, Glob
permissionMode: plan  # or default
```

**Use cases**:
- Code structure analysis
- Codebase exploration
- Pattern detection
- Metrics collection

### Safe Modifications

For code changes without shell access:

```yaml
tools: Read, Edit, Write
permissionMode: acceptEdits
```

**Use cases**:
- Code formatting
- Refactoring
- Import organization
- Code generation

### Development Workflows

For complete development tasks:

```yaml
tools: Read, Edit, Write, Bash, TodoWrite
permissionMode: default
```

**Use cases**:
- Feature implementation
- Bug fixing
- Test development
- Git operations

### Specialized Tools

Include only necessary specialized tools:

```yaml
# PDF work
tools: Bash, Read, Write  # For PDF CLI tools

# Web research
tools: Read, WebSearch, WebFetch

# Data analysis
tools: Read, Bash  # For SQL, data tools

# Notebook editing
tools: Read, NotebookEdit
```

## Model Selection Strategies

### Cost-Optimized Workflow

Use tiered models for cost efficiency:

```yaml
# Phase 1: Quick exploration (haiku)
name: quick-search
model: haiku
tools: Read, Grep, Glob

# Phase 2: Analysis (sonnet)
name: analyzer
model: sonnet
tools: Read, Bash

# Phase 3: Critical review (opus)
name: final-reviewer
model: opus
tools: Read
```

### Capability-Optimized Workflow

Match model to task complexity:

```yaml
# Simple: File finding (haiku)
name: file-finder
model: haiku
description: Quick file location

# Medium: Code review (sonnet)
name: code-reviewer
model: sonnet
description: Quality analysis

# Complex: Architecture (opus)
name: architect
model: opus
description: System design decisions
```

### User-Aligned Workflow

Match main conversation's capability:

```yaml
name: pair-programmer
model: inherit
description: Assists with development
```

**Why**: Ensures consistent capability level with user's choice.

## Permission Mode Patterns

### Graduated Trust Model

Start restrictive, increase automation carefully:

```yaml
# Level 1: Full user control
permissionMode: default
description: Initial implementation, user reviews all changes

# Level 2: Auto-approve safe operations
permissionMode: acceptEdits
description: Trusted for file edits, user reviews destructive ops

# Level 3: Full automation (only for proven workflows)
permissionMode: bypassPermissions
description: Completely trusted, fully automated
```

### Context-Appropriate Permissions

Match permissions to context:

```yaml
# User-facing: Require approval
name: assistant
permissionMode: default

# Background tasks: Auto-approve
name: formatter
permissionMode: acceptEdits

# CI/CD: Full automation
name: ci-agent
permissionMode: bypassPermissions
```

## System Prompt Patterns

### Clear Structure Template

```markdown
---
name: subagent-name
description: Specific triggers and use cases
tools: Minimal tool list
model: appropriate-model
permissionMode: default
---

# Role Name

Brief introduction to subagent's purpose (1-2 sentences).

## When Invoked

Immediate actions to take:
1. First step
2. Second step
3. Third step

## Methodology

Core approach:
- Key principle 1
- Key principle 2
- Key principle 3

## Constraints

What to avoid:
- Constraint 1
- Constraint 2

## Output Format

How to present results:
- Structure
- Format
- Examples

## Examples

[Concrete examples of good outputs]
```

### Checklists Pattern

```markdown
## Review Checklist

### Critical Issues
- [ ] Security vulnerabilities
- [ ] Data loss risks
- [ ] Breaking changes

### Quality Concerns
- [ ] Code readability
- [ ] Error handling
- [ ] Test coverage

### Style Issues
- [ ] Naming conventions
- [ ] Documentation
- [ ] Formatting
```

### Decision Trees Pattern

```markdown
## Debugging Strategy

### If Error Message Present
1. Extract error message
2. Identify error location
3. Check recent changes

### If Test Failure
1. Identify failing test
2. Determine expected vs actual
3. Analyze test intent

### If Performance Issue
1. Profile critical paths
2. Identify bottlenecks
3. Measure improvements
```

## Team Collaboration Patterns

### Shared Project Subagents

Store in `.claude/agents/` for team:

```yaml
# .claude/agents/code-reviewer.md
name: code-reviewer
description: Team code review standards
```

**Benefits**:
- Consistent quality checks
- Shared best practices
- Version controlled
- Team improvements

### Personal User Subagents

Store in `~/.claude/agents/` for individual:

```yaml
# ~/.claude/agents/my-workflow.md
name: my-workflow
description: Personal development workflow
```

**Benefits**:
- Individual preferences
- Experimental configs
- Personal tools
- Not imposed on team

### Plugin Subagents

Distribute via plugins for organization:

```
my-plugin/
└── agents/
    ├── security-auditor.md
    └── compliance-checker.md
```

**Benefits**:
- Organization-wide standards
- Centralized updates
- Easy distribution
- Versioned releases

## Testing Strategies

### Test Description Matching

Verify description triggers correctly:

```python
def test_description_matching():
    """Test if descriptions match expected queries."""
    test_cases = [
        ("review my code", "code-reviewer"),
        ("fix this error", "debugger"),
        ("run the tests", "test-runner"),
    ]

    for query, expected_agent in test_cases:
        # Verify agent triggers
        assert matches_agent(query, expected_agent)
```

### Test Tool Usage

Verify subagent uses only allowed tools:

```python
def test_tool_restrictions():
    """Test tool access restrictions."""
    agent = load_subagent("code-analyzer")

    assert "Read" in agent.tools
    assert "Grep" in agent.tools
    assert "Bash" not in agent.tools  # Should not have shell
```

### Test Permission Modes

Verify permission behavior:

```python
def test_permission_modes():
    """Test permission mode behavior."""
    # Default: prompts for destructive ops
    default_agent = load_subagent("reviewer")
    assert default_agent.permission_mode == "default"

    # AcceptEdits: auto-approve edits
    formatter = load_subagent("formatter")
    assert formatter.permission_mode == "acceptEdits"
```

### Integration Testing

Test full workflows:

```bash
# Test subagent creation
./scripts/create-subagent.sh test-agent project

# Test validation
./scripts/validate-subagent.sh .claude/agents/test-agent.md

# Test invocation
claude "Use test-agent to analyze this file"
```

## Debugging Patterns

### Subagent Not Loading

**Check**:
1. File location correct
2. YAML frontmatter valid
3. Required fields present
4. Name pattern matches

**Debug**:
```bash
# List loaded subagents
/agents

# Check file syntax
yamllint .claude/agents/your-agent.md

# Validate configuration
./scripts/validate-subagent.sh .claude/agents/your-agent.md
```

### Subagent Not Triggering

**Improve description**:

Before:
```yaml
description: Code helper
```

After:
```yaml
description: Code quality reviewer. Use PROACTIVELY when code changes are made, reviewing pull requests, or checking code quality. Analyzes security, performance, style.
```

**Test matching**:
```
User query: "Review my changes"
Expected: code-reviewer triggers
Actual: generic agent used

Solution: Add "review changes" to description
```

### Tool Permission Errors

**Check configuration**:

```yaml
# If seeing permission errors for Bash:
tools: Read, Edit, Write  # Missing Bash

# Fix:
tools: Read, Edit, Write, Bash
```

**Adjust permission mode**:

```yaml
# If too many prompts:
permissionMode: default  # Change to acceptEdits

# If fully trusted:
permissionMode: acceptEdits  # Change to bypassPermissions
```

## Performance Optimization

### Context Management

Keep system prompts lean:

**Before** (5000 words):
```markdown
[Everything inline, bloated context]
```

**After** (1500 words):
```markdown
Core concepts here.

See references/:
- detailed-patterns.md
- advanced-techniques.md
```

### Model Selection

Use appropriate models:

**Expensive** (unnecessary opus):
```yaml
name: file-finder
model: opus  # Overkill for simple task
```

**Optimized** (appropriate haiku):
```yaml
name: file-finder
model: haiku  # Fast and sufficient
```

### Tool Restrictions

Limit to essentials:

**Wasteful** (all tools):
```yaml
name: code-analyzer
tools: null  # Inherits all, most unused
```

**Efficient** (minimal):
```yaml
name: code-analyzer
tools: Read, Grep, Glob  # Only what's needed
```

## Security Best Practices

### Input Validation

Validate in system prompt:

```markdown
## Input Validation

Before processing:
1. Verify file paths don't contain `..`
2. Check file extensions match expectations
3. Validate input size limits
4. Sanitize user-provided strings
```

### Sensitive Data Handling

```markdown
## Security Constraints

NEVER:
- Log sensitive data (passwords, keys, tokens)
- Include secrets in output
- Expose internal paths
- Share credentials

ALWAYS:
- Redact sensitive information
- Use environment variables for secrets
- Validate all external input
```

### Tool Restrictions

Limit dangerous combinations:

```yaml
# Bad: Full access + full automation
tools: null
permissionMode: bypassPermissions

# Good: Limited tools + automation
tools: Read, Edit, Write
permissionMode: acceptEdits

# Better: Limited tools + user approval
tools: Read, Edit, Write
permissionMode: default
```

## Maintenance Patterns

### Version Documentation

Track changes in system prompt:

```markdown
## Version History

### v2.1.0 (2024-03-15)
- Added security vulnerability checks
- Improved error messages
- Updated tool permissions

### v2.0.0 (2024-02-01)
- Breaking: Changed output format
- Added performance analysis
- Removed deprecated checks
```

### Deprecation Strategy

Phase out old subagents:

```yaml
# Old (deprecated)
name: legacy-reviewer
description: DEPRECATED - Use code-reviewer instead

# New (current)
name: code-reviewer
description: Modern code review with security checks
```

### Monitoring Usage

Track effectiveness:

```markdown
## Usage Metrics

Track:
- Invocation frequency
- Success rate
- User feedback
- Error patterns

Improve based on:
- Common failures
- User complaints
- Performance issues
```

## Advanced Patterns

### Conditional Tool Access

```markdown
## Tool Usage Guidelines

Use Read:
- Always safe for file access

Use Edit/Write:
- Only for formatting, refactoring
- Never for unreviewed changes

Use Bash:
- Git operations only
- Validate commands before execution
```

### Multi-Phase Workflows

```yaml
# Phase 1: Analysis
name: analyzer
tools: Read, Grep, Glob
model: haiku

# Phase 2: Planning
name: planner
tools: Read, TodoWrite
model: sonnet

# Phase 3: Implementation
name: implementer
tools: Read, Edit, Write
model: sonnet
```

### Skill Composition

```yaml
name: full-stack-developer
description: Full-stack web development
skills: frontend-patterns, backend-patterns, database-schemas
tools: Read, Edit, Write, Bash
model: sonnet
```

### Context Preservation

```markdown
## Context Management

Preserve between invocations:
- Key decisions made
- Patterns discovered
- Files analyzed

Track in structured format:
```json
{
  "files_reviewed": [...],
  "issues_found": [...],
  "recommendations": [...]
}
```
```

## Quality Checklist

Before deploying a subagent:

**Configuration**:
- [ ] Name follows pattern `^[a-z0-9-]+$`
- [ ] Description includes specific triggers
- [ ] Tools minimal but sufficient
- [ ] Model appropriate for complexity
- [ ] Permission mode suitable for automation

**System Prompt**:
- [ ] Clear role definition
- [ ] Step-by-step procedures
- [ ] Concrete examples
- [ ] Constraints documented
- [ ] Output format specified

**Security**:
- [ ] Principle of least privilege applied
- [ ] No unnecessary bypass permissions
- [ ] Input validation included
- [ ] Sensitive data handling addressed

**Testing**:
- [ ] Triggers on expected queries
- [ ] Uses correct tools
- [ ] Produces quality output
- [ ] Handles edge cases

**Documentation**:
- [ ] Purpose clear
- [ ] Usage examples provided
- [ ] Limitations documented
- [ ] Version tracked

## Common Pitfalls

### Pitfall: Overly Generic

**Problem**:
```yaml
description: General development helper
```

**Solution**:
```yaml
description: Python test automation specialist. Use PROACTIVELY when pytest tests fail or when running test suites. Fixes test failures while preserving test intent.
```

### Pitfall: Tool Overload

**Problem**:
```yaml
tools: null  # All tools for simple task
```

**Solution**:
```yaml
tools: Read, Grep, Glob  # Only what's needed
```

### Pitfall: Permission Mismatch

**Problem**:
```yaml
tools: Bash
permissionMode: plan  # plan blocks Bash
```

**Solution**:
```yaml
tools: Bash
permissionMode: default  # or acceptEdits
```

### Pitfall: Model Misalignment

**Problem**:
```yaml
name: simple-formatter
model: opus  # Expensive for simple task
```

**Solution**:
```yaml
name: simple-formatter
model: haiku  # Fast and sufficient
```

### Pitfall: Bloated Prompts

**Problem**:
```markdown
[8000 words in system prompt]
```

**Solution**:
```markdown
[Core concepts: 1500 words]

See references/ for details:
- patterns.md
- advanced.md
```

## Success Metrics

Track these indicators:

**Usage**:
- Invocation frequency
- Match rate (triggers vs. manual)
- User satisfaction

**Quality**:
- Task completion rate
- Error frequency
- Output quality ratings

**Efficiency**:
- Average execution time
- Token usage
- Cost per invocation

**Maintenance**:
- Update frequency
- Bug reports
- Feature requests

## Continuous Improvement

### Feedback Loop

1. **Deploy** subagent
2. **Monitor** usage and errors
3. **Collect** user feedback
4. **Analyze** patterns
5. **Improve** configuration
6. **Repeat**

### Iteration Process

```yaml
# v1.0: Initial release
name: code-reviewer
tools: Read, Bash

# v1.1: Add editing after feedback
tools: Read, Edit, Bash

# v2.0: Optimize model after usage data
model: haiku  # Changed from sonnet for speed

# v2.1: Add skills after discovering patterns
skills: security-patterns
```

### Documentation Updates

Keep current:
- Update examples with real usage
- Document discovered edge cases
- Add FAQ section
- Share team learnings

## Summary

**Core Principles**:
1. Single responsibility
2. Least privilege
3. Progressive disclosure
4. Clear triggers
5. Appropriate tooling

**Key Practices**:
- Strong, specific descriptions
- Minimal tool permissions
- Right model for task
- Proper permission modes
- Structured prompts

**Quality Assurance**:
- Validate configurations
- Test trigger matching
- Verify tool usage
- Monitor performance
- Iterate based on feedback

**Security Focus**:
- Minimize permissions
- Validate inputs
- Protect sensitive data
- Document constraints
- Review regularly

Follow these practices to create maintainable, secure, and effective Claude Code subagents that serve your team well.
