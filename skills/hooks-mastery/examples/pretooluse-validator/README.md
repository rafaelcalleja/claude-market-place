# PreToolUse Validator Example

This example demonstrates a PreToolUse hook that validates bash commands before execution.

## Features

- Blocks dangerous commands (rm -rf, dd, mkfs, etc.)
- Suggests better alternatives (rg instead of grep)
- Uses JSON output for structured control
- Provides clear feedback to Claude and user

## Configuration

Add to `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/validator.py",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

## Testing

Test locally without running Claude Code:

```bash
# Test with safe command
python3 ../../../scripts/test-hook-io.py validator.py PreToolUse --command "echo 'hello'"

# Test with dangerous command
python3 ../../../scripts/test-hook-io.py validator.py PreToolUse --command "rm -rf /"

# Test with improvable command
python3 ../../../scripts/test-hook-io.py validator.py PreToolUse --command "grep pattern file.txt"
```

## How It Works

1. Hook receives PreToolUse input with bash command
2. Validates command against dangerous patterns
3. If dangerous: Exits with code 2 (blocks execution)
4. If safe with suggestions: Returns JSON with `allow` + `systemMessage`
5. If safe: Returns JSON with `allow`

## Output Examples

**Dangerous command blocked:**
```
Exit Code: 2
Stderr: ❌ Dangerous command blocked:
  • Recursive force delete from root
```

**Safe command with suggestions:**
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "Command validated with suggestions"
  },
  "systemMessage": "Suggestions: Consider using 'rg' (ripgrep) for better performance"
}
```

**Safe command:**
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow"
  }
}
```
