# SessionStart Setup Example

This example demonstrates a SessionStart hook that initializes the development environment.

## Features

- Detects Node.js projects and activates NVM
- Detects Python projects and activates virtualenv
- Persists environment variables using `CLAUDE_ENV_FILE`
- Adds node_modules/.bin to PATH
- Sets default environment variables (NODE_ENV, etc.)
- Provides git context information

## Configuration

Add to `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/setup.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

## Testing

```bash
# Test the hook locally
python3 ../../../scripts/test-hook-io.py setup.sh SessionStart
```

## How It Works

1. Hook receives SessionStart input with source (startup/resume/etc.)
2. Detects project type (Node.js, Python, etc.)
3. Activates appropriate environment (NVM, virtualenv)
4. Writes export statements to `$CLAUDE_ENV_FILE`
5. Environment variables persist for all subsequent bash commands
6. Outputs setup summary as context

## Output Example

```
🚀 Initializing session (source: startup)
📦 Node.js project detected
  Using Node version from .nvmrc
  Node v20.10.0 activated
  Added node_modules/.bin to PATH

📂 Project: my-project
🌿 Branch: feature/new-feature
📝 Uncommitted changes: 3 files
✅ Environment initialized
```

## Environment Variables Persisted

The hook writes to `$CLAUDE_ENV_FILE` (only available in SessionStart hooks):

```bash
export NVM_DIR="/home/user/.nvm"
export NVM_BIN="/home/user/.nvm/versions/node/v20.10.0/bin"
export PATH="/home/user/.nvm/versions/node/v20.10.0/bin:$PATH"
export PATH="/home/user/project/node_modules/.bin:$PATH"
export NODE_ENV=development
export PYTHONDONTWRITEBYTECODE=1
```

These variables are available to all subsequent bash commands Claude executes during the session.

## Use Cases

SessionStart hooks are ideal for:
- **Environment activation**: Load Node versions, Python virtualenvs
- **PATH configuration**: Add project-specific bins to PATH
- **Default variables**: Set NODE_ENV, PYTHONDONTWRITEBYTECODE, etc.
- **Tool initialization**: Start databases, services, etc.
- **Context loading**: Provide project information to Claude

## Advanced: Capturing All Environment Changes

The script uses this pattern to capture all environment changes from NVM:

```bash
# Before changes
ENV_BEFORE=$(export -p | sort)

# Make changes
source ~/.nvm/nvm.sh
nvm use

# After changes
ENV_AFTER=$(export -p | sort)

# Persist differences
comm -13 <(echo "$ENV_BEFORE") <(echo "$ENV_AFTER") >> "$CLAUDE_ENV_FILE"
```

This automatically captures all new variables and PATH modifications without manually specifying each one.
