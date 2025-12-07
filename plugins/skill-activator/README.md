# skill-activator

Increase Claude Code skill activation rates from **20% to 84%** using forced evaluation hooks.

## The Problem

Claude Code skills don't activate autonomously as intended. Simple instruction hooks achieve only ~20% success rates, making skill activation unreliable.

## The Solution

This plugin provides **three tested hook approaches** based on rigorous research with 200+ prompts:

| Hook | Success Rate | Status |
|------|-------------|--------|
| **Forced Eval** | **84%** | DEFAULT |
| LLM Eval | 80% | Alternative |
| Simple Instruction | 20% | Baseline |

## Installation

Enable this plugin in your Claude Code configuration or marketplace.

## How It Works

The **forced eval hook** (default) creates a three-step commitment mechanism:

1. **EVALUATE** - Claude must explicitly state YES/NO for each skill with reasoning
2. **ACTIVATE** - Immediately call `Skill()` tool for all YES skills
3. **IMPLEMENT** - Only proceed after activation is complete

This accountability mechanism prevents Claude from skipping skill activation.

## Switching Hooks

To use a different hook strategy, edit `hooks/hooks.json` and change the command path:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/skill-llm-eval-hook.sh"
          }
        ]
      }
    ]
  }
}
```

## Requirements

- **Forced Eval**: No dependencies (recommended)
- **LLM Eval**: Requires `ANTHROPIC_API_KEY`, `jq`, and `curl`

## Credits

Based on research by [Scott Spence](https://scottspence.com/posts/how-to-make-claude-code-skills-activate-reliably).

See `hooks/README.md` for detailed documentation and original sources.
