# Workflow Weaver

**Interactive Skill Builder for Claude Code**

## Overview

Workflow Weaver is a meta-skill that enables recording workflows into reusable skills. Claude monitors its own actions and asks users interactively which actions to include, creating self-documenting workflows in real-time.

## Key Innovation

Unlike traditional recording tools, Workflow Weaver:
- **Self-monitoring:** Claude tracks its OWN actions
- **Interactive curation:** User chooses what to include via AskUserQuestion
- **No hooks needed:** Pure skill-based approach, no external scripts
- **Context-aware:** Claude has full conversation context
- **Smart generation:** Creates well-formatted, reusable SKILL.md

## How It Works

```
User: "start recording: fix-auth-bug"
      ↓
Claude creates: .claude/skills-in-progress/fix-auth-bug/
                - building.json (empty)
                - references/ (empty)
      ↓
Claude works normally, but after EACH action:
      ↓
Claude: "I just fetched OAuth docs. Include?"
User: "Both" (add as step + save reference)
      ↓
building.json updated, reference saved
      ↓
... continues for entire workflow ...
      ↓
User: "stop recording"
      ↓
Claude generates complete SKILL.md
Moves to .claude/skills/fix-auth-bug/
      ↓
✅ Reusable skill created!
```

## Components

### 1. State Management (building.json)

```json
{
  "skill_name": "example",
  "status": "recording",
  "steps": [
    {
      "step_id": 1,
      "type": "webfetch",
      "action": "Fetch API documentation",
      "details": {...}
    }
  ],
  "references": [...]
}
```

### 2. Interactive Questions

After each action:
- "Add as step" → Include in workflow
- "Save as reference" → Save content to references/
- "Both" → Step + reference
- "Skip" → Ignore

### 3. Generated SKILL.md

Complete, executable skill with:
- Frontmatter (name, description, tools)
- Prerequisites
- Numbered steps with details
- References section
- Usage examples
- Notes

## Comparison to ThoughtStream Recorder

| Feature | ThoughtStream | Workflow Weaver |
|---------|---------------|-----------------|
| **Approach** | Silent + distillation | Interactive + real-time |
| **User input** | None during, one at end | After each action |
| **Format** | JSONL event stream | JSON state + SKILL.md |
| **Reasoning** | Captured automatically | Optional per step |
| **Best for** | Observing patterns | Building tutorials |
| **Friction** | Zero during work | Moderate (questions) |
| **Control** | Low (AI decides) | High (user decides) |

## Monitored Actions

- **WebFetch / WebSearch** → Captures web content
- **Read** → Local file operations
- **Bash** → Command execution
- **Edit** → File modifications
- **Write** → File creation
- **Grep / Glob** → Search operations

## Example Output

```markdown
---
name: deploy-to-aws
description: "Deploy application to AWS using CLI and verify deployment"
allowed-tools: [bash, read]
---

# Deploy to AWS

Automated deployment workflow for AWS environments.

## Steps

### 1. Fetch Deployment Documentation

Reference AWS CLI deployment guide

**Action:** webfetch
**Reference:** [aws-cli-docs.md](references/aws-cli-docs.md)

### 2. Read Configuration File

Load production configuration

**Action:** read
**Details:**
- File: config/production.yml

### 3. Execute Deployment Command

Deploy using AWS CLI

**Action:** bash
**Details:**
- Command: `aws deploy create-deployment --application-name myapp`

## References

- **aws-cli-docs.md** - AWS CLI deployment documentation
- **production-config.yml** - Production configuration

## Usage

1. Ensure AWS CLI is configured
2. Review production.yml settings
3. Run deployment command
4. Verify deployment status
```

## Commands

| Command | Purpose |
|---------|---------|
| `start recording: [name]` | Begin recording |
| `pause recording` | Temporarily stop monitoring |
| `resume recording` | Continue monitoring |
| `show current skill` | Preview progress |
| `stop recording` | Generate SKILL.md |

## Generation Process

This prompt was created using **Fabric AI + Sequential Thinking**:

### Process Flow

```
1. User describes idea (dynamic skill builder)
   ↓
2. Analyze with Sequential Thinking (12 steps)
   ↓
3. Design data structures (building.json schema)
   ↓
4. Create draft prompt with full specification
   ↓
5. Fabric AI: improve_prompt + cot strategy
   ↓
6. Fabric AI: analyze_prose + reflexion strategy
   ↓
7. Identified gaps: incomplete self-monitoring section
   ↓
8. Final version with complete implementation
```

### Fabric AI Analysis

**Draft Version:**
- Clarity: B (Clean but incomplete)
- Prose: C (Standard)
- Issue: Self-Monitoring Protocol section incomplete

**Final Version:**
- Complete self-monitoring specification
- Detailed AskUserQuestion format
- Full error handling
- Edge case coverage
- Production-ready

## Use Cases

1. **Tutorial Creation** - Record complex workflows into shareable skills
2. **Team Onboarding** - Capture tribal knowledge as executable skills
3. **Workflow Documentation** - Self-documenting processes
4. **Best Practices** - Codify proven workflows
5. **Debugging Recipes** - Record successful debugging sessions

## Advantages Over Hooks

| Aspect | Hooks | Skill-Based |
|--------|-------|-------------|
| **Setup** | Requires claude.json config | Just SKILL.md |
| **Context** | Limited to stdin | Full conversation |
| **Reasoning** | External bash scripts | Claude's intelligence |
| **Flexibility** | Fixed code | Adaptive instructions |
| **Complexity** | High (bash + jq + hooks) | Low (markdown) |
| **Maintenance** | Multiple script files | Single SKILL.md |

## Limitations

- **Requires user attention:** Questions after each action
- **Not silent:** Cannot observe without interruption
- **Manual curation:** User must decide each action
- **Single recording:** No concurrent recordings

**For silent recording, see:** ThoughtStream Recorder (Enfoque 5)

## Installation

Use `prompt.md` to generate the skill with Claude Code:

```bash
# Copy prompt content and ask Claude:
"Generate the skill-builder skill using this specification: [paste prompt.md]"
```

Claude will create complete SKILL.md at `.claude/skills/skill-builder/SKILL.md`

## Future Enhancements

- **Smart batching:** Group similar actions automatically
- **Template detection:** Recognize common workflow patterns
- **Diff-based recording:** Only record changes, not reads
- **Parametrization:** Auto-detect variables to extract
- **Version control:** Track skill iterations
- **Merge capabilities:** Combine multiple recordings

---

**Name Origin:** "Workflow Weaver" - weaves individual actions into cohesive, reusable skills

**Approach:** Enfoque 1 (Self-Monitoring Interactive)

**Generated:** 2025-12-02

**Method:** Sequential Thinking + Fabric AI (improve_prompt + reflexion)
