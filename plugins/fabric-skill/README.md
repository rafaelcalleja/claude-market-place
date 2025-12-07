# Fabric Skill Plugin

Native Fabric pattern execution for Claude Code. Run 227 AI patterns directly with your full model power and conversation context.

## Overview

This plugin provides the **Fabric skill** which enables Claude Code to execute Fabric patterns natively without spawning the CLI. Instead of calling `fabric -p pattern_name`, Claude reads the pattern markdown directly and applies it with:

- **Your subscription's full power** - Opus/Sonnet intelligence vs Fabric's default model
- **Full conversation context** - Patterns work with your entire session
- **No CLI overhead** - Faster execution, no process spawning
- **227 patterns** - All patterns included: analysis, creation, extraction, summarization, security

## Installation

Add this plugin to your Claude Code marketplace or install directly:

```bash
claude plugin install /path/to/fabric-skill
```

## Usage

The skill activates automatically when you ask Claude to use Fabric patterns:

```
"Extract wisdom from this transcript"
"Create a threat model for this API"
"Summarize this article"
"Apply the analyze_claims pattern to this text"
```

Claude will:
1. Read `tools/patterns/{pattern_name}/system.md`
2. Apply the pattern instructions to your content
3. Return structured output

## When to Use Fabric CLI

The CLI is only needed for:
- YouTube transcripts: `fabric -y "URL"`
- Update patterns: `fabric -U`
- List patterns: `fabric -l`

## Pattern Categories

| Category | Count | Examples |
|----------|-------|----------|
| `create_*` | 55 | create_prd, create_threat_model, create_mermaid |
| `extract_*` | 40 | extract_wisdom, extract_insights, extract_alpha |
| `analyze_*` | 33 | analyze_claims, analyze_malware, analyze_paper |
| `summarize*` | 14 | summarize, summarize_paper, summarize_meeting |
| Other | 85 | improve_writing, review_code, humanize |

## Requirements

- Claude Code CLI
- No additional dependencies (patterns bundled)

## License

MIT
