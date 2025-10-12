# Auto-Formatter Plugin

Automatic code formatting hook that runs after file edits.

## Features

### Automatic Formatting
Automatically formats files after Write/Edit operations based on file type:

- **JavaScript/TypeScript** (.js, .jsx, .ts, .tsx) - Uses Prettier
- **Python** (.py) - Uses Black
- **Go** (.go) - Uses gofmt
- **Rust** (.rs) - Uses rustfmt
- **JSON** (.json) - Uses jq

### Safety Warnings
Shows warnings before potentially destructive operations:
- Warns before file deletion operations
- Provides session start notification

### Session Notifications
Displays a message when the plugin is loaded at session start.

## Hooks Included

### PostToolUse Hook
**Triggers:** After Write or Edit operations
**Action:** Runs the format-file.sh script to automatically format the modified file

### PreToolUse Hook
**Triggers:** Before Bash commands that delete files (rm)
**Action:** Displays a warning notification

### SessionStart Hook
**Triggers:** When a Claude Code session starts
**Action:** Displays a welcome notification

## Installation

```bash
# Add the marketplace
/plugin marketplace add /path/to/example-marketplace

# Install the plugin
/plugin install auto-formatter@example-marketplace
```

## Requirements

For formatting to work, you need the appropriate formatter installed:

```bash
# JavaScript/TypeScript
npm install -g prettier

# Python
pip install black

# Go (usually included with Go installation)
go install golang.org/x/tools/cmd/gofmt@latest

# Rust (usually included with Rust installation)
rustup component add rustfmt

# JSON
# jq - install via your package manager (apt, brew, etc.)
```

## Configuration

The plugin uses hooks defined in `hooks/hooks.json`. You can customize:

- Which tools trigger formatting
- File type patterns to format
- Notification messages
- Additional hook triggers

## How It Works

1. You use Claude Code to write or edit a file
2. After the Write/Edit operation completes, the PostToolUse hook triggers
3. The format-file.sh script runs, detecting the file type
4. The appropriate formatter is applied (if available)
5. The file is saved with proper formatting

## Example Usage

When you ask Claude to create or edit a file:

```
Claude: I'll create a new JavaScript file...
[Uses Write tool to create app.js]
[Auto-formatter hook triggers]
[File is automatically formatted with Prettier]
Result: app.js created and formatted
```

## Customization

You can modify the formatting script at `scripts/format-file.sh` to:
- Add support for more file types
- Use different formatters
- Customize formatting options
- Add linting or validation

## License

MIT
