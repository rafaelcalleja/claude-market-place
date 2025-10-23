# Custom Hooks Plugin

Custom UserPromptSubmit hook that adds an AskUserQuestion reminder to all user prompts.

## Overview

This plugin automatically appends a helpful reminder to every user prompt submission, encouraging the use of the `AskUserQuestion` tool when Claude has doubts or needs clarification.

## Features

- **UserPromptSubmit Hook**: Automatically triggered when the user submits a prompt
- **Helpful Reminder**: Adds "Si tienes dudas usa la tool AskUserQuestion" to the context
- **Non-intrusive**: Uses exit code 0 to add the reminder as context without blocking the prompt

## Installation

This plugin is part of the claude-market-place. To install:

```bash
# From the marketplace root
make install
```

Or install manually:

```bash
cd plugins/custom-hooks
claude plugin install .
```

## How It Works

The plugin uses a `UserPromptSubmit` hook that:

1. Receives the user's prompt via stdin as JSON
2. Outputs a reminder message to stdout
3. Returns exit code 0 to add the message as context

The hook script is located at `scripts/add_question_reminder.py`.

## Hook Configuration

The hook is configured in `hooks/hooks.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/add_question_reminder.py"
          }
        ]
      }
    ]
  }
}
```

## Script Details

The Python script (`scripts/add_question_reminder.py`):

- Reads JSON input from stdin
- Extracts the prompt (optional validation)
- Outputs the reminder message
- Handles errors gracefully with proper exit codes

## Use Cases

- **Improved Interaction**: Reminds Claude to ask questions instead of making assumptions
- **Better Clarification**: Encourages use of structured questioning through AskUserQuestion tool
- **Reduced Errors**: Helps prevent misunderstandings by promoting clarification

## Requirements

- Python 3.x
- Claude Code CLI

## License

MIT

## Author

Rafael Calleja
