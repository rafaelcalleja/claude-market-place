# Claude Code Hooks Protocol Specification v1.0

## 1. Introduction

### 1.1 Overview
The Claude Code Hooks Protocol defines a standardized interface for extending and controlling Claude Code's behavior through event-driven automation. Hooks execute external commands or LLM-based evaluations at specific lifecycle points, enabling validation, modification, and context injection.

### 1.2 Protocol Goals
- **Extensibility**: Allow external tools to integrate with Claude Code workflow
- **Control**: Enable validation and modification of tool executions
- **Context Enhancement**: Support dynamic context injection at runtime
- **Security**: Provide mechanisms for validation and access control
- **Observability**: Enable monitoring and logging of Claude Code operations

### 1.3 Terminology
- **Hook**: An executable command or prompt that responds to a specific event
- **Hook Event**: A lifecycle point where hooks can be triggered
- **Matcher**: A pattern that determines when a hook should execute
- **Hook Command**: A bash script or executable invoked by the hook system
- **Hook Prompt**: An LLM evaluation query for intelligent decision-making
- **Hook Input**: JSON data passed to hooks via stdin
- **Hook Output**: Response from hooks via stdout/stderr and exit codes

## 2. Architecture

### 2.1 Execution Model
```
┌─────────────────┐
│  Claude Code    │
│   Main Process  │
└────────┬────────┘
         │
         ├─── Event Occurs (e.g., PreToolUse)
         │
         ├─── Match Hooks Against Event
         │
         ├─── Execute Matching Hooks (Parallel)
         │    │
         │    ├─── Hook Process 1 (stdin: JSON, stdout/stderr: response)
         │    ├─── Hook Process 2 (stdin: JSON, stdout/stderr: response)
         │    └─── Hook Process N (stdin: JSON, stdout/stderr: response)
         │
         ├─── Collect Hook Responses
         │
         ├─── Process Decisions (allow/deny/block/approve)
         │
         └─── Continue or Halt Execution
```

### 2.2 Hook Types

#### 2.2.1 Command Hooks
Execute bash commands or scripts with JSON input via stdin.

**Properties:**
- `type`: `"command"` (required)
- `command`: String containing the command to execute (required)
- `timeout`: Number of seconds before timeout (optional, default: 60)

#### 2.2.2 Prompt-Based Hooks
Send context to an LLM (Haiku) for intelligent evaluation.

**Properties:**
- `type`: `"prompt"` (required)
- `prompt`: String containing the evaluation prompt (required)
- `timeout`: Number of seconds before timeout (optional, default: 30)

**Prompt Placeholders:**
- `$ARGUMENTS`: Replaced with hook input JSON
- If `$ARGUMENTS` not present, JSON is appended to prompt

### 2.3 Hook Scopes
Hooks can be configured at three levels:
1. **User Scope**: `~/.claude/settings.json`
2. **Project Scope**: `.claude/settings.json`
3. **Local Scope**: `.claude/settings.local.json`
4. **Plugin Scope**: Plugin's `hooks/hooks.json`
5. **Enterprise Scope**: System-level managed settings

**Precedence**: Local > Plugin > Project > User > Enterprise

### 2.4 Configuration Structure

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<pattern>",
        "hooks": [
          {
            "type": "command|prompt",
            "command": "<bash-command>",
            "prompt": "<llm-prompt>",
            "timeout": <seconds>
          }
        ]
      }
    ]
  }
}
```

## 3. Hook Events

### 3.1 Event Lifecycle

```
SessionStart → [UserPromptSubmit → PreToolUse → ToolExecution → PostToolUse]* → Stop → SessionEnd
                                        ↓
                                 PermissionRequest
                                        ↓
                                   Notification
```

### 3.2 Event Definitions

#### 3.2.1 PreToolUse
**Timing**: After Claude generates tool parameters, before tool execution
**Purpose**: Validate, modify, or block tool calls
**Supports Matcher**: Yes
**Common Matchers**: `Task`, `Bash`, `Glob`, `Grep`, `Read`, `Edit`, `Write`, `WebFetch`, `WebSearch`, `mcp__*`

#### 3.2.2 PermissionRequest
**Timing**: When user is shown a permission dialog
**Purpose**: Auto-approve or deny permissions
**Supports Matcher**: Yes (same as PreToolUse)

#### 3.2.3 PostToolUse
**Timing**: Immediately after tool completes successfully
**Purpose**: Validate results, trigger follow-up actions
**Supports Matcher**: Yes (same as PreToolUse)

#### 3.2.4 Notification
**Timing**: When Claude Code sends notifications
**Purpose**: External alerting, logging
**Supports Matcher**: Yes
**Common Matchers**: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`

#### 3.2.5 UserPromptSubmit
**Timing**: When user submits a prompt, before Claude processes it
**Purpose**: Add context, validate, or block prompts
**Supports Matcher**: No

#### 3.2.6 Stop
**Timing**: When main Claude Code agent finishes responding
**Purpose**: Determine if Claude should continue working
**Supports Matcher**: No
**Note**: Does not run on user interrupt

#### 3.2.7 SubagentStop
**Timing**: When a subagent (Task tool call) finishes responding
**Purpose**: Determine if subagent should continue
**Supports Matcher**: No

#### 3.2.8 PreCompact
**Timing**: Before compact operation begins
**Purpose**: Pre-compact validation, logging
**Supports Matcher**: Yes
**Matchers**: `manual`, `auto`

#### 3.2.9 SessionStart
**Timing**: When Claude Code starts or resumes a session
**Purpose**: Load context, set environment, initialize state
**Supports Matcher**: Yes
**Matchers**: `startup`, `resume`, `clear`, `compact`
**Special**: Access to `CLAUDE_ENV_FILE` for persisting environment variables

#### 3.2.10 SessionEnd
**Timing**: When Claude Code session ends
**Purpose**: Cleanup, logging, state persistence
**Supports Matcher**: No

## 4. Communication Protocol

### 4.1 Input Format
All hooks receive JSON via **stdin**.

#### 4.1.1 Common Fields
Present in all hook inputs:

```typescript
{
  session_id: string          // Unique session identifier
  transcript_path: string     // Path to conversation JSONL file
  cwd: string                 // Current working directory
  permission_mode: "default" | "plan" | "acceptEdits" | "bypassPermissions"
  hook_event_name: string     // Name of the triggered event
}
```

#### 4.1.2 Event-Specific Input Schemas

**PreToolUse Input:**
```typescript
{
  ...commonFields,
  hook_event_name: "PreToolUse",
  tool_name: string,
  tool_input: object,         // Tool-specific parameters
  tool_use_id: string
}
```

**PermissionRequest Input:**
Same as PreToolUse (triggered when permission dialog shown)

**PostToolUse Input:**
```typescript
{
  ...commonFields,
  hook_event_name: "PostToolUse",
  tool_name: string,
  tool_input: object,
  tool_response: object,      // Tool execution result
  tool_use_id: string
}
```

**Notification Input:**
```typescript
{
  ...commonFields,
  hook_event_name: "Notification",
  message: string,
  notification_type: "permission_prompt" | "idle_prompt" | "auth_success" | "elicitation_dialog"
}
```

**UserPromptSubmit Input:**
```typescript
{
  ...commonFields,
  hook_event_name: "UserPromptSubmit",
  prompt: string
}
```

**Stop/SubagentStop Input:**
```typescript
{
  ...commonFields,
  hook_event_name: "Stop" | "SubagentStop",
  stop_hook_active: boolean   // True if already continuing from a stop hook
}
```

**PreCompact Input:**
```typescript
{
  ...commonFields,
  hook_event_name: "PreCompact",
  trigger: "manual" | "auto",
  custom_instructions: string
}
```

**SessionStart Input:**
```typescript
{
  ...commonFields,
  hook_event_name: "SessionStart",
  source: "startup" | "resume" | "clear" | "compact"
}
```

**SessionEnd Input:**
```typescript
{
  ...commonFields,
  hook_event_name: "SessionEnd",
  reason: "clear" | "logout" | "prompt_input_exit" | "other"
}
```

### 4.2 Output Protocol

Hooks communicate via two mutually-exclusive methods:

#### 4.2.1 Simple Protocol: Exit Codes

**Exit Code 0 - Success:**
- `stdout`: Shown to user in verbose mode (Ctrl+O)
- Exception: For `UserPromptSubmit` and `SessionStart`, stdout is added to context
- JSON in stdout is parsed for structured control

**Exit Code 2 - Blocking Error:**
- `stderr`: Used as error message, fed back to Claude
- Format: `[command]: {stderr}`
- JSON in stdout is **ignored**
- Behavior varies by event (see section 4.2.4)

**Other Exit Codes - Non-Blocking Error:**
- `stderr`: Shown to user in verbose mode
- Format: `Failed with non-blocking status code: {stderr}`
- Execution continues

#### 4.2.2 Advanced Protocol: JSON Output

Hooks can return structured JSON via **stdout** (only processed with exit code 0):

**Base JSON Structure:**
```typescript
{
  continue?: boolean,           // Default: true. If false, stops Claude
  stopReason?: string,          // Message when continue=false
  suppressOutput?: boolean,     // Default: false. Hide from transcript
  systemMessage?: string,       // Warning shown to user
  decision?: "approve" | "block" | "allow" | "deny",
  reason?: string,              // Explanation for decision
  hookSpecificOutput?: object   // Event-specific output
}
```

#### 4.2.3 Event-Specific JSON Outputs

**PreToolUse Output:**
```typescript
{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "allow" | "deny" | "ask",
    permissionDecisionReason?: string,
    updatedInput?: object       // Modified tool parameters
  }
}
```

**PermissionRequest Output:**
```typescript
{
  hookSpecificOutput: {
    hookEventName: "PermissionRequest",
    decision: {
      behavior: "allow" | "deny",
      updatedInput?: object,
      message?: string,         // For deny
      interrupt?: boolean       // Stop Claude
    }
  }
}
```

**PostToolUse Output:**
```typescript
{
  decision?: "block",           // Prompts Claude with reason
  reason?: string,
  hookSpecificOutput: {
    hookEventName: "PostToolUse",
    additionalContext?: string
  }
}
```

**UserPromptSubmit Output:**
```typescript
{
  decision?: "block",           // Prevents prompt processing
  reason?: string,              // Shown to user
  hookSpecificOutput: {
    hookEventName: "UserPromptSubmit",
    additionalContext?: string
  }
}
```

**Stop/SubagentStop Output:**
```typescript
{
  decision?: "block",           // Prevents stopping
  reason: string                // Required when blocking
}
```

**SessionStart Output:**
```typescript
{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext?: string
  }
}
```

**Prompt-Based Hook Response:**
```typescript
{
  decision: "approve" | "block",
  reason: string,
  continue?: boolean,
  stopReason?: string,
  systemMessage?: string
}
```

#### 4.2.4 Exit Code 2 Behavior Matrix

| Event              | Behavior                                           |
|--------------------|----------------------------------------------------|
| PreToolUse         | Blocks tool call, shows stderr to Claude          |
| PermissionRequest  | Denies permission, shows stderr to Claude         |
| PostToolUse        | Shows stderr to Claude (tool already executed)    |
| Notification       | Shows stderr to user only                         |
| UserPromptSubmit   | Blocks prompt, erases it, shows stderr to user    |
| Stop               | Blocks stoppage, shows stderr to Claude           |
| SubagentStop       | Blocks stoppage, shows stderr to subagent         |
| PreCompact         | Shows stderr to user only                         |
| SessionStart       | Shows stderr to user only                         |
| SessionEnd         | Shows stderr to user only                         |

## 5. Environment Variables

### 5.1 Standard Variables

**CLAUDE_PROJECT_DIR**
- **Availability**: All hooks
- **Value**: Absolute path to project root directory
- **Purpose**: Reference project-specific scripts and files

**CLAUDE_ENV_FILE**
- **Availability**: SessionStart hooks only
- **Value**: Path to file for persisting environment variables
- **Purpose**: Set variables available to all subsequent bash commands
- **Format**: Write export statements, one per line

**CLAUDE_CODE_REMOTE**
- **Availability**: All hooks
- **Value**: `"true"` if web environment, empty/unset if local CLI
- **Purpose**: Execute different logic based on execution context

**CLAUDE_PLUGIN_ROOT**
- **Availability**: Plugin hooks only
- **Value**: Absolute path to plugin directory
- **Purpose**: Reference plugin-specific files and scripts

### 5.2 Environment Variable Persistence

SessionStart hooks can persist variables by writing to `$CLAUDE_ENV_FILE`:

```bash
#!/bin/bash
if [ -n "$CLAUDE_ENV_FILE" ]; then
  echo 'export NODE_ENV=production' >> "$CLAUDE_ENV_FILE"
  echo 'export API_KEY=secret' >> "$CLAUDE_ENV_FILE"
fi
exit 0
```

For capturing all environment changes:

```bash
#!/bin/bash
ENV_BEFORE=$(export -p | sort)

# Modify environment
source ~/.nvm/nvm.sh
nvm use 20

if [ -n "$CLAUDE_ENV_FILE" ]; then
  ENV_AFTER=$(export -p | sort)
  comm -13 <(echo "$ENV_BEFORE") <(echo "$ENV_AFTER") >> "$CLAUDE_ENV_FILE"
fi
exit 0
```

## 6. Matcher Patterns

### 6.1 Matcher Syntax

**Exact Match:**
```json
"matcher": "Write"
```
Matches only the Write tool.

**Regex Match:**
```json
"matcher": "Edit|Write"
"matcher": "Notebook.*"
```
Supports full regex syntax.

**Match All:**
```json
"matcher": "*"
"matcher": ""
```
Empty string or asterisk matches all tools.

### 6.2 MCP Tool Matching

MCP tools follow pattern: `mcp__<server>__<tool>`

**Examples:**
```json
"matcher": "mcp__memory__.*"           // All memory server tools
"matcher": "mcp__.*__write.*"          // All write operations across servers
"matcher": "mcp__github__search_repositories"  // Specific tool
```

### 6.3 Event-Specific Matchers

**PreCompact:**
- `manual`: Invoked from `/compact`
- `auto`: Auto-compact due to full context

**SessionStart:**
- `startup`: New session start
- `resume`: Resume via `--resume`, `--continue`, `/resume`
- `clear`: After `/clear` command
- `compact`: After compact operation

**Notification:**
- `permission_prompt`: Permission requests
- `idle_prompt`: Idle waiting (60+ seconds)
- `auth_success`: Authentication success
- `elicitation_dialog`: MCP tool elicitation

## 7. Execution Model

### 7.1 Hook Discovery
1. Load hooks from all scopes (user, project, local, plugin, enterprise)
2. Merge hooks by precedence (local > plugin > project > user > enterprise)
3. Deduplicate identical hook commands

### 7.2 Hook Matching
1. Event occurs in Claude Code
2. For matcher-based events: Match event against configured matchers
3. Collect all matching hooks

### 7.3 Hook Execution
1. Execute all matching hooks **in parallel**
2. Each hook receives JSON input via stdin
3. Enforce timeout (default: 60s for command, 30s for prompt)
4. Collect stdout, stderr, and exit codes

### 7.4 Response Processing
1. Parse exit codes and stdout JSON
2. If any hook returns `continue: false`, stop execution
3. For PreToolUse: Process permission decisions (allow/deny/ask)
4. For PostToolUse/Stop: Process block decisions
5. For UserPromptSubmit/SessionStart: Inject context from stdout

### 7.5 Timeout Behavior
- Individual hook timeout does not affect other hooks
- Timed-out hooks are logged but don't block execution
- Default timeouts: 60s (command), 30s (prompt)
- Configurable per hook via `timeout` field

## 8. Security Model

### 8.1 Execution Sandbox
- Hooks execute with Claude Code's user permissions
- No sandboxing or privilege isolation
- Full filesystem and network access

### 8.2 Configuration Safety
1. Hook configurations captured at startup
2. Snapshot used throughout session
3. External modifications trigger warning
4. Changes require review via `/hooks` menu

### 8.3 Security Best Practices

**Input Validation:**
```python
# Validate all inputs
if not isinstance(tool_input.get('file_path'), str):
    sys.exit(2)

# Sanitize paths
if '..' in file_path or file_path.startswith('/'):
    print("Path traversal detected", file=sys.stderr)
    sys.exit(2)
```

**Shell Safety:**
```bash
# Always quote variables
command="$CLAUDE_PROJECT_DIR/script.sh"

# Avoid eval, use arrays
declare -a args=("$arg1" "$arg2")
"${args[@]}"
```

**Sensitive Data:**
```python
# Skip sensitive files
sensitive_patterns = ['.env', '.git/', 'id_rsa', '*.pem']
if any(pattern in file_path for pattern in sensitive_patterns):
    sys.exit(2)
```

## 9. Performance Characteristics

### 9.1 Latency
- **Command hooks**: Local execution, typically <100ms
- **Prompt hooks**: API call to Haiku, typically 500ms-2s
- **Parallel execution**: All hooks run simultaneously

### 9.2 Resource Usage
- Each hook spawns separate process
- Memory: Minimal (JSON parsing + process overhead)
- CPU: Depends on hook implementation
- Network: Only for prompt-based hooks

### 9.3 Optimization
- Hooks deduplicated automatically
- Identical commands run only once
- Timeout prevents runaway processes
- Parallel execution maximizes throughput

## 10. Appendix

### 10.1 Complete Hook Event Reference

| Event             | Matcher | Timing                          | Input Context              | Output Purpose          |
|-------------------|---------|---------------------------------|----------------------------|-------------------------|
| PreToolUse        | Yes     | Before tool execution           | tool_name, tool_input      | Allow/Deny/Modify       |
| PermissionRequest | Yes     | Permission dialog shown         | tool_name, tool_input      | Allow/Deny              |
| PostToolUse       | Yes     | After tool execution            | tool_response              | Validate/Add context    |
| Notification      | Yes     | Notification sent               | message, type              | Log/Alert               |
| UserPromptSubmit  | No      | Before prompt processing        | prompt                     | Add context/Block       |
| Stop              | No      | Agent finished responding       | stop_hook_active           | Continue/Stop           |
| SubagentStop      | No      | Subagent finished               | stop_hook_active           | Continue/Stop           |
| PreCompact        | Yes     | Before compact                  | trigger, instructions      | Validate/Log            |
| SessionStart      | Yes     | Session start/resume            | source                     | Initialize/Add context  |
| SessionEnd        | No      | Session end                     | reason                     | Cleanup/Log             |

### 10.2 Exit Code Reference

| Code | Meaning            | stdout Handling         | stderr Handling              | Execution Continues |
|------|--------------------|-------------------------|------------------------------|---------------------|
| 0    | Success            | Parsed as JSON or text  | Ignored                      | Yes                 |
| 2    | Blocking error     | Ignored                 | Fed to Claude/User           | Depends on event    |
| 1    | Non-blocking error | Ignored                 | Logged to verbose mode       | Yes                 |
| 3+   | Non-blocking error | Ignored                 | Logged to verbose mode       | Yes                 |

---

**Specification Version**: 1.0
**Last Updated**: 2025
**Status**: Stable
