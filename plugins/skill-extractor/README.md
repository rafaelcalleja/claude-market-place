# Skill Extractor Plugin

Extract reusable skills from Claude Code conversations using Fabric AI patterns.

## Overview

Conversations with Claude Code contain valuable workflows, but they're buried in noise (trial & error, exploration, backtracking). This plugin extracts the **reusable essence** and converts it into well-structured skills.

## What It Does

```
Input:  2-hour debugging conversation (528KB, 139 lines)
Output: Clean 100-line skill capturing the essential workflow
```

**Removes:** Trial and error, dead ends, verbose explanations, social chat

**Keeps:** Commands that worked, key insights, decision patterns, references

## Installation

```bash
# Using Claude Code plugin system
claude plugin add skill-extractor

# Or manually
git clone https://github.com/claude-market-place/skill-extractor
cp -r skill-extractor ~/.claude/plugins/
```

### Dependencies

- **Fabric AI**: `go install github.com/danielmiessler/fabric@latest`
- **jq**: `apt install jq` or `brew install jq`

## Usage

### Interactive (with Claude)

```
"Extract a skill from my debugging session from today"
"Convert yesterday's feature implementation into a reusable skill"
"Create a skill from the conversation at [path]"
```

### Command Line

```bash
# Full extraction pipeline
bash scripts/extract_skill.sh ~/.claude/projects/myproject/session.jsonl /tmp/output

# Just parse conversation
bash scripts/parse_conversation.sh session.jsonl > conversation.txt
```

## How It Works

1. **Parse** - Convert JSONL conversation to readable text
2. **Extract** - Apply Fabric AI patterns in parallel:
   - `extract_wisdom` → Key insights
   - `extract_instructions` → Actionable steps
   - `extract_primary_problem` → Problem definition
   - `extract_primary_solution` → What actually worked
3. **Combine** - Merge extractions into SKILL.md template
4. **Refine** - Remove noise, polish for reuse

## Fabric Patterns Used

| Pattern | Extracts | Use For |
|---------|----------|---------|
| `extract_wisdom` | Insights, learnings | Key Insights section |
| `extract_instructions` | Step-by-step procedures | Steps section |
| `extract_primary_problem` | Core problem statement | Problem Pattern section |
| `extract_primary_solution` | What actually worked | Solution summary |

## Example

### Before (Conversation)
```
User: My app crashes on login
Claude: [checks logs, tries 3 things, finally finds it]
Claude: Fixed! Token wasn't validated
User: Thanks!
```

### After (Extracted Skill)
```markdown
---
name: fix-login-crash-token-validation
description: "Debug login crashes caused by missing JWT token validation"
---

# Fix Login Crash - Token Validation

## Problem Pattern
App crashes on login with null pointer in auth module.

## Steps
1. Check auth logs for null/token errors
2. Verify token expiration validation exists
3. Add validation if missing

## Key Insights
- Most login crashes = missing token expiration checks
- Always validate before use, not just at creation
```

## Plugin Structure

```
skill-extractor/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── extract-skill-from-conversation/
│       ├── SKILL.md              # Main skill instructions
│       ├── scripts/
│       │   ├── parse_conversation.sh
│       │   └── extract_skill.sh
│       ├── references/
│       │   ├── fabric_patterns.md
│       │   └── skill_template.md
│       └── examples/
│           └── example_extraction.md
└── README.md
```

## License

MIT
