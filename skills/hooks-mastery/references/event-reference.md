# Hook Events Reference

This document provides detailed specifications for each hook event, including input formats, output formats, use cases, and examples.

## PreToolUse

### Overview
Runs after Claude creates tool parameters and before processing the tool call.

**Supports Matcher**: Yes
**Can Block**: Yes
**Can Modify**: Yes

### Input Format

```typescript
{
  session_id: string,
  transcript_path: string,
  cwd: string,
  permission_mode: "default" | "plan" | "acceptEdits" | "bypassPermissions",
  hook_event_name: "PreToolUse",
  tool_name: string,           // Name of tool being called
  tool_input: object,          // Tool-specific parameters
  tool_use_id: string          // Unique identifier for this tool use
}
```

### Output Format

**Exit Code 2 (Block):**
```bash
echo "Validation failed: dangerous command" >&2
exit 2
```

**JSON Output (Allow with modification):**
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "Command validated and modified",
    "updatedInput": {
      "command": "modified-command"
    }
  }
}
```

**JSON Output (Ask user):**
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "ask",
    "permissionDecisionReason": "This command requires confirmation"
  }
}
```

### Common Matchers
- `Bash` - Shell commands
- `Write` - File creation
- `Edit` - File modification
- `Read` - File reading
- `mcp__*` - MCP server tools

### Use Cases

1. **Command Validation**: Block dangerous bash commands
2. **Path Sanitization**: Prevent path traversal attacks
3. **Input Modification**: Add parameters or modify values
4. **Auto-approval**: Bypass permissions for safe operations

### Examples

**Bash Command Validator:**
```python
#!/usr/bin/env python3
import json, sys, re

input_data = json.load(sys.stdin)

if input_data.get('tool_name') != 'Bash':
    sys.exit(0)

command = input_data['tool_input']['command']

# Block dangerous patterns
dangerous = [r'\brm\s+-rf\b', r'\b>/dev/sd', r'dd\s+if=']
for pattern in dangerous:
    if re.search(pattern, command):
        print(f"Dangerous command blocked: {pattern}", file=sys.stderr)
        sys.exit(2)

# Allow safe commands
output = {
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "allow"
    }
}
print(json.dumps(output))
sys.exit(0)
```

## PermissionRequest

### Overview
Runs when the user is shown a permission dialog.

**Supports Matcher**: Yes
**Can Block**: Yes (deny)
**Can Modify**: Yes

### Input Format
Same as PreToolUse - triggered when permission dialog appears.

### Output Format

**Allow with modification:**
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": {
      "behavior": "allow",
      "updatedInput": {
        "command": "npm run lint"
      }
    }
  }
}
```

**Deny with message:**
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": {
      "behavior": "deny",
      "message": "This operation is not allowed in production",
      "interrupt": true
    }
  }
}
```

### Use Cases

1. **Auto-approve safe operations**: Allow read-only commands automatically
2. **Block restricted operations**: Deny write access to certain paths
3. **Modify dangerous operations**: Change parameters before approval

## PostToolUse

### Overview
Runs immediately after a tool completes successfully.

**Supports Matcher**: Yes
**Can Block**: Yes (provides feedback)
**Can Modify**: No (tool already executed)

### Input Format

```typescript
{
  session_id: string,
  transcript_path: string,
  cwd: string,
  permission_mode: string,
  hook_event_name: "PostToolUse",
  tool_name: string,
  tool_input: object,          // Original input
  tool_response: object,       // Tool execution result
  tool_use_id: string
}
```

### Output Format

**Validation with feedback:**
```json
{
  "decision": "block",
  "reason": "File formatting failed. Run prettier before continuing.",
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "ESLint found 3 errors in the modified file"
  }
}
```

### Common Matchers
- `Write` - After file creation
- `Edit` - After file modification
- `Bash` - After command execution

### Use Cases

1. **Code Formatting**: Run prettier/eslint after edits
2. **Validation**: Check file syntax after creation
3. **Notifications**: Alert on file changes
4. **Logging**: Track all tool executions

### Examples

**Auto-formatter:**
```bash
#!/bin/bash

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name')
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [[ "$tool_name" =~ ^(Write|Edit)$ ]] && [[ "$file_path" =~ \.ts$ ]]; then
    npx prettier --write "$file_path" 2>/dev/null
fi

exit 0
```

## Notification

### Overview
Runs when Claude Code sends notifications.

**Supports Matcher**: Yes
**Can Block**: No
**Can Modify**: No

### Input Format

```typescript
{
  session_id: string,
  transcript_path: string,
  cwd: string,
  permission_mode: string,
  hook_event_name: "Notification",
  message: string,
  notification_type: "permission_prompt" | "idle_prompt" | "auth_success" | "elicitation_dialog"
}
```

### Common Matchers
- `permission_prompt` - Permission requests
- `idle_prompt` - Idle waiting notifications
- `auth_success` - Authentication success
- `elicitation_dialog` - MCP tool elicitation

### Use Cases

1. **Desktop Notifications**: Alert when input needed
2. **Logging**: Track all notifications
3. **External Alerts**: Send to Slack, email, etc.

### Examples

**Desktop Alert:**
```bash
#!/bin/bash

input=$(cat)
message=$(echo "$input" | jq -r '.message')
type=$(echo "$input" | jq -r '.notification_type')

if [ "$type" = "idle_prompt" ]; then
    notify-send "Claude Code" "$message"
fi

exit 0
```

## UserPromptSubmit

### Overview
Runs when the user submits a prompt, before Claude processes it.

**Supports Matcher**: No
**Can Block**: Yes
**Can Modify**: No (but can add context)

### Input Format

```typescript
{
  session_id: string,
  transcript_path: string,
  cwd: string,
  permission_mode: string,
  hook_event_name: "UserPromptSubmit",
  prompt: string              // User's submitted prompt
}
```

### Output Format

**Add context (plain text):**
```bash
echo "Current time: $(date)"
echo "Git branch: $(git branch --show-current)"
exit 0
```

**Add context (JSON):**
```json
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "Current branch: main\nLast commit: abc123"
  }
}
```

**Block prompt:**
```json
{
  "decision": "block",
  "reason": "Prompt contains sensitive information. Please rephrase."
}
```

### Use Cases

1. **Context Injection**: Add current time, git status, environment info
2. **Prompt Validation**: Block prompts with sensitive data
3. **Logging**: Track all user prompts
4. **Enrichment**: Add project-specific context

### Examples

**Context Enricher:**
```python
#!/usr/bin/env python3
import json, sys, datetime, subprocess

input_data = json.load(sys.stdin)

# Add git context
try:
    branch = subprocess.check_output(
        ['git', 'branch', '--show-current'],
        text=True, stderr=subprocess.DEVNULL
    ).strip()

    context = f"Current git branch: {branch}\n"
    context += f"Current time: {datetime.datetime.now()}\n"

    print(context)
except:
    pass

sys.exit(0)
```

## Stop / SubagentStop

### Overview
Runs when Claude (or a subagent) finishes responding.

**Supports Matcher**: No
**Can Block**: Yes (continues execution)
**Can Modify**: No

### Input Format

```typescript
{
  session_id: string,
  transcript_path: string,
  permission_mode: string,
  hook_event_name: "Stop" | "SubagentStop",
  stop_hook_active: boolean   // True if already continuing from a stop hook
}
```

### Output Format

**Allow stopping:**
```bash
exit 0
```

**Block stopping (continue execution):**
```json
{
  "decision": "block",
  "reason": "Tests have not been run yet. Please execute test suite."
}
```

### Use Cases

1. **Task Verification**: Ensure all tasks completed
2. **Test Enforcement**: Require tests to pass before stopping
3. **Checklist Validation**: Verify all items completed

### Examples

**Prompt-Based Evaluator:**
```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Review conversation: $ARGUMENTS\n\nCheck if:\n1. All requested tasks are complete\n2. Tests are passing\n3. No errors remain\n\nRespond: {\"decision\": \"approve\" or \"block\", \"reason\": \"explanation\"}"
          }
        ]
      }
    ]
  }
}
```

## PreCompact

### Overview
Runs before Claude Code compacts conversation history.

**Supports Matcher**: Yes (manual, auto)
**Can Block**: No
**Can Modify**: No

### Input Format

```typescript
{
  session_id: string,
  transcript_path: string,
  permission_mode: string,
  hook_event_name: "PreCompact",
  trigger: "manual" | "auto",
  custom_instructions: string  // From /compact command
}
```

### Matchers
- `manual` - User invoked `/compact`
- `auto` - Automatic compact due to full context

### Use Cases

1. **Logging**: Track when compacts occur
2. **Backup**: Save conversation before compact
3. **Metrics**: Count compact frequency

## SessionStart

### Overview
Runs when Claude Code starts or resumes a session.

**Supports Matcher**: Yes
**Can Block**: No
**Can Modify**: No (but can add context and environment)

### Input Format

```typescript
{
  session_id: string,
  transcript_path: string,
  permission_mode: string,
  hook_event_name: "SessionStart",
  source: "startup" | "resume" | "clear" | "compact"
}
```

### Matchers
- `startup` - New session
- `resume` - Resume via --resume, --continue, /resume
- `clear` - After /clear
- `compact` - After compact operation

### Special Environment Variable
**CLAUDE_ENV_FILE**: Write export statements to persist environment variables for all subsequent bash commands.

### Output Format

**Set environment variables:**
```bash
#!/bin/bash

if [ -n "$CLAUDE_ENV_FILE" ]; then
    echo 'export NODE_ENV=development' >> "$CLAUDE_ENV_FILE"
    echo 'export PATH="$PATH:./node_modules/.bin"' >> "$CLAUDE_ENV_FILE"
fi

echo "Session initialized with Node $(node --version)"
exit 0
```

**Capture all environment changes:**
```bash
#!/bin/bash

ENV_BEFORE=$(export -p | sort)

# Load NVM and set version
source ~/.nvm/nvm.sh
nvm use 20

if [ -n "$CLAUDE_ENV_FILE" ]; then
    ENV_AFTER=$(export -p | sort)
    comm -13 <(echo "$ENV_BEFORE") <(echo "$ENV_AFTER") >> "$CLAUDE_ENV_FILE"
fi

exit 0
```

### Use Cases

1. **Environment Setup**: Load Node version, activate virtualenv
2. **Context Loading**: Add project info, recent changes
3. **Dependency Check**: Verify required tools installed
4. **Configuration**: Set environment variables

## SessionEnd

### Overview
Runs when Claude Code session ends.

**Supports Matcher**: No
**Can Block**: No
**Can Modify**: No

### Input Format

```typescript
{
  session_id: string,
  transcript_path: string,
  cwd: string,
  permission_mode: string,
  hook_event_name: "SessionEnd",
  reason: "clear" | "logout" | "prompt_input_exit" | "other"
}
```

### Use Cases

1. **Cleanup**: Remove temporary files
2. **Logging**: Save session statistics
3. **Backup**: Archive conversation
4. **Reporting**: Send session summary

### Examples

**Session Logger:**
```python
#!/usr/bin/env python3
import json, sys, datetime

input_data = json.load(sys.stdin)

log_entry = {
    'session_id': input_data['session_id'],
    'ended_at': datetime.datetime.now().isoformat(),
    'reason': input_data['reason'],
    'transcript': input_data['transcript_path']
}

with open('/tmp/claude-sessions.log', 'a') as f:
    f.write(json.dumps(log_entry) + '\n')

sys.exit(0)
```

## Summary Matrix

| Event | Matcher | Block | Modify | Add Context | Special Features |
|-------|---------|-------|--------|-------------|------------------|
| PreToolUse | ✓ | ✓ | ✓ | - | Permission control |
| PermissionRequest | ✓ | ✓ | ✓ | - | Auto-approve/deny |
| PostToolUse | ✓ | ✓* | - | ✓ | *Feedback only |
| Notification | ✓ | - | - | - | External alerting |
| UserPromptSubmit | - | ✓ | - | ✓ | Prompt validation |
| Stop/SubagentStop | - | ✓ | - | - | Continue execution |
| PreCompact | ✓ | - | - | - | Compact tracking |
| SessionStart | ✓ | - | - | ✓ | Env persistence |
| SessionEnd | - | - | - | - | Cleanup |
