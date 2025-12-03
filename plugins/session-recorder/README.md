# Session Recorder Plugin

Records all Claude Code session interactions using a hybrid approach combining automated hooks and self-reporting.

## Features

- **Automated Recording**: Hooks automatically capture user messages and tool calls
- **Self-Reporting**: Claude explicitly logs summaries of completed work
- **Structured Logs**: JSON format with timestamps, UUIDs, and metadata
- **Session Management**: Automatic session initialization and finalization

## Installation

### From Marketplace

```bash
claude plugin install session-recorder
```

### Manual Installation

Copy the plugin to your Claude Code plugins directory:

```bash
cp -r plugins/session-recorder ~/.claude/plugins/
```

## Usage

Once installed, the plugin automatically:

1. **SessionStart**: Creates a new session log file
2. **UserPromptSubmit**: Records each user message
3. **PostToolUse**: Records tool calls and results
4. **SessionEnd**: Finalizes the session with end timestamp

### Self-Reporting

Claude is instructed (via the skill) to periodically self-report using:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/skills/session-recorder/scripts/add_assistant_response.sh \
  --summary "Created configuration file" \
  --actions "Modified package.json, ran npm install" \
  --tools "Write,Bash"
```

## Log Structure

Logs are stored in `.claude/session_logs/session_YYYY-MM-DD.json`:

```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440000",
  "start_timestamp": "2025-12-02T10:30:00Z",
  "end_timestamp": "2025-12-02T11:45:00Z",
  "project_path": "/path/to/project",
  "interactions": [
    {
      "interaction_id": "uuid",
      "timestamp": "2025-12-02T10:30:15Z",
      "type": "user_message",
      "content": "Help me create a new API endpoint",
      "metadata": {}
    },
    {
      "interaction_id": "uuid",
      "timestamp": "2025-12-02T10:30:45Z",
      "type": "tool_call",
      "content": {
        "tool": "Write",
        "arguments": {"file_path": "/src/api.ts"}
      },
      "metadata": {}
    }
  ]
}
```

## Dependencies

- `jq` - JSON processing
- `uuidgen` - UUID generation (usually pre-installed on Linux/macOS)

### Installing Dependencies

**Ubuntu/Debian:**
```bash
sudo apt-get install jq uuid-runtime
```

**macOS:**
```bash
brew install jq
# uuidgen is pre-installed
```

**Arch Linux:**
```bash
sudo pacman -S jq util-linux
```

## Configuration

No configuration required. The plugin automatically creates the log directory and manages session files.

### Log Location

Logs are stored relative to `CLAUDE_PROJECT_DIR`:
```
$CLAUDE_PROJECT_DIR/.claude/session_logs/session_YYYY-MM-DD.json
```

## Troubleshooting

### Logs Not Being Created

1. Check if `jq` is installed: `which jq`
2. Check permissions on `.claude/` directory
3. Run with debug mode: `claude --debug`

### Missing Tool Results

PostToolUse hooks run after tool completion. If tool fails, no result is recorded.

### Session Spanning Midnight

A new session file is created at midnight. Interactions continue in the new file.

## License

MIT
