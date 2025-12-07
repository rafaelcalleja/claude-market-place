# Skill Activation Hooks

This directory contains three different hook implementations for improving Claude Code skill activation rates.

## Research Background

Based on rigorous testing with **200+ prompts** across different development scenarios by [Scott Spence](https://scottspence.com).

### Original Sources

- **Blog Post**: [How to Make Claude Code Skills Activate Reliably](https://scottspence.com/posts/how-to-make-claude-code-skills-activate-reliably)
- **GitHub Repository**: [spences10/svelte-claude-skills](https://github.com/spences10/svelte-claude-skills)
- **Reddit Discussion**: [Claude Code skills activate 20% of the time. Here's how I got to 84%.](https://www.reddit.com/r/ClaudeCode/comments/1oywsa1/claude_code_skills_activate_20_of_the_time_heres/)

---

## Hook Comparison

| Hook | Success Rate | Dependencies | Cost |
|------|-------------|--------------|------|
| **skill-forced-eval-hook.sh** | **84%** | None | $0 |
| skill-llm-eval-hook.sh | 80% | ANTHROPIC_API_KEY, jq, curl | ~$0.0004/prompt |
| skill-simple-instruction-hook.sh | 20% | None | $0 |

---

## Available Hooks

### 1. skill-forced-eval-hook.sh (DEFAULT)

**Success Rate: 84%** - Recommended for production use.

Creates a **three-step commitment mechanism**:
1. **EVALUATE**: Claude must state YES/NO with reasoning for each skill
2. **ACTIVATE**: Immediately call `Skill()` for all YES skills
3. **IMPLEMENT**: Only proceed after activation

**Why it works**:
- Accountability through written commitment
- Mandatory language ("CRITICAL", "WORTHLESS") creates psychological pressure
- Visible sequence makes skipping obvious

### 2. skill-llm-eval-hook.sh

**Success Rate: 80%** - Uses Claude Haiku API for semantic matching.

**Requirements**:
```bash
export ANTHROPIC_API_KEY=your-key-here
# Also requires: jq, curl
```

**Cost**: ~$0.0004 per evaluation (0.04 cents)

**Trade-offs**:
- Smarter semantic matching (not just keywords)
- Can completely fail if API is down
- External dependency on Anthropic API

### 3. skill-simple-instruction-hook.sh

**Success Rate: 20%** - Baseline, not recommended.

Simple passive suggestion with no accountability mechanism. Included for comparison and testing purposes only.

---

## Switching Hooks

To use a different hook, edit `hooks.json`:

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

---

## Key Insights

### Why Forced Eval Wins

1. **Commitment Mechanism** - Claude writes YES/NO BEFORE implementing. Once written, it's committed to that decision.

2. **Explicit Accountability** - The phrase "The evaluation (Step 1) is WORTHLESS unless you ACTIVATE (Step 2)" creates psychological pressure to follow through.

3. **Sequenced Steps** - Steps 1→2→3 create a clear workflow where skipping is visible.

4. **No External Dependencies** - LLM eval can fail if API is down, no key set, or if Haiku makes a wrong classification decision.

### Testing Methodology

The original research used:
- 200+ test prompts
- 5 common SvelteKit development scenarios
- SQLite database for metrics tracking
- Pass rate, latency, and cost analysis

---

## License

Based on work by Scott Spence. See original repositories for license details.
