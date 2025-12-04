# UserPromptSubmit Enricher Example

This example demonstrates a UserPromptSubmit hook that adds contextual information and validates prompts.

## Features

- Adds timestamp to every prompt
- Injects git context (branch, last commit, uncommitted changes)
- Adds environment information (Node/Python versions)
- Blocks prompts containing sensitive patterns
- Uses plain text output (automatically added to context)

## Configuration

Add to `.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/enricher.py",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

## Testing

```bash
# Test with normal prompt
python3 ../../../scripts/test-hook-io.py enricher.py UserPromptSubmit

# Test with prompt containing sensitive pattern (will block)
echo '{"session_id":"test","transcript_path":"/tmp/t","cwd":"/home/user","permission_mode":"default","hook_event_name":"UserPromptSubmit","prompt":"My API key is abc123"}' | python3 enricher.py
```

## How It Works

1. Hook receives UserPromptSubmit input with user's prompt
2. Checks for sensitive patterns (password, api_key, token, etc.)
3. If sensitive: Returns JSON with `decision: "block"`
4. If safe: Outputs context as plain text (exit 0)
5. Plain text stdout is automatically added to conversation context

## Output Examples

**Normal prompt (context added):**
```
**Current Time**: 2025-01-15 10:30:45

**Git Context**:
- Branch: main
- Last commit: a1b2c3d - Add new feature
- Uncommitted changes: 3 files

**Environment**:
- Node: v20.10.0
- Python: Python 3.11.6
```

**Prompt with sensitive content (blocked):**
```json
{
  "decision": "block",
  "reason": "Your prompt may contain sensitive information ('api_key'). Please rephrase without including actual credentials."
}
```

## Why This Pattern

UserPromptSubmit hooks are ideal for:
- **Context injection**: Add information Claude doesn't have (time, git state)
- **Security validation**: Block prompts with sensitive data
- **Prompt enhancement**: Enrich prompts with project-specific context
- **Logging**: Track all user inputs (not shown in this example)

The plain text output pattern is simpler than JSON for straightforward context injection.
