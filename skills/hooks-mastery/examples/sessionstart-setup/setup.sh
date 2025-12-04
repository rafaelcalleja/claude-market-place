#!/bin/bash
# SessionStart Hook: Environment Setup
# Initializes development environment and persists variables

set -e

# Parse input
input=$(cat)
source=$(echo "$input" | jq -r '.source')
cwd=$(echo "$input" | jq -r '.cwd')

echo "🚀 Initializing session (source: $source)"

# Detect and setup Node.js environment
if [ -f "$cwd/package.json" ]; then
    echo "📦 Node.js project detected"

    # Load NVM if available
    if [ -f "$HOME/.nvm/nvm.sh" ]; then
        # Capture environment before
        ENV_BEFORE=$(export -p | sort)

        source "$HOME/.nvm/nvm.sh"

        # Check for .nvmrc
        if [ -f "$cwd/.nvmrc" ]; then
            echo "  Using Node version from .nvmrc"
            nvm use
        else
            echo "  Using default Node version"
            nvm use default
        fi

        # Persist environment changes
        if [ -n "$CLAUDE_ENV_FILE" ]; then
            ENV_AFTER=$(export -p | sort)
            comm -13 <(echo "$ENV_BEFORE") <(echo "$ENV_AFTER") >> "$CLAUDE_ENV_FILE"
        fi

        echo "  Node $(node --version) activated"
    fi

    # Add node_modules/.bin to PATH
    if [ -d "$cwd/node_modules/.bin" ] && [ -n "$CLAUDE_ENV_FILE" ]; then
        echo "export PATH=\"$cwd/node_modules/.bin:\$PATH\"" >> "$CLAUDE_ENV_FILE"
        echo "  Added node_modules/.bin to PATH"
    fi
fi

# Detect and setup Python environment
if [ -f "$cwd/requirements.txt" ] || [ -f "$cwd/pyproject.toml" ]; then
    echo "🐍 Python project detected"

    # Check for virtual environment
    if [ -d "$cwd/venv" ]; then
        if [ -n "$CLAUDE_ENV_FILE" ]; then
            echo "export VIRTUAL_ENV=\"$cwd/venv\"" >> "$CLAUDE_ENV_FILE"
            echo "export PATH=\"$cwd/venv/bin:\$PATH\"" >> "$CLAUDE_ENV_FILE"
            echo "  Activated virtual environment"
        fi
    elif [ -d "$cwd/.venv" ]; then
        if [ -n "$CLAUDE_ENV_FILE" ]; then
            echo "export VIRTUAL_ENV=\"$cwd/.venv\"" >> "$CLAUDE_ENV_FILE"
            echo "export PATH=\"$cwd/.venv/bin:\$PATH\"" >> "$CLAUDE_ENV_FILE"
            echo "  Activated virtual environment"
        fi
    fi
fi

# Set environment mode
if [ -n "$CLAUDE_ENV_FILE" ]; then
    # Default to development mode
    echo "export NODE_ENV=development" >> "$CLAUDE_ENV_FILE"
    echo "export PYTHONDONTWRITEBYTECODE=1" >> "$CLAUDE_ENV_FILE"
fi

# Add git information as context
if [ -d "$cwd/.git" ]; then
    echo ""
    echo "📂 Project: $(basename "$cwd")"
    echo "🌿 Branch: $(git -C "$cwd" branch --show-current 2>/dev/null || echo 'unknown')"

    # Count uncommitted changes
    changes=$(git -C "$cwd" status --porcelain 2>/dev/null | wc -l)
    if [ "$changes" -gt 0 ]; then
        echo "📝 Uncommitted changes: $changes files"
    fi
fi

echo "✅ Environment initialized"

exit 0
