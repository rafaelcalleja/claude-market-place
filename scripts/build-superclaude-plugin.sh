#!/bin/bash
set -euo pipefail

# Build SuperClaude Framework plugin from upstream release
# Usage: ./scripts/build-superclaude-plugin.sh [VERSION]

VERSION=${1:-4.1.5}
PLUGIN_DIR="plugins/superclaude-framework"
TMP_DIR="/tmp/superclaude-build-$$"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=============================================="
echo "Building SuperClaude Framework Plugin"
echo "Version: ${VERSION}"
echo "=============================================="
echo ""

# Create temp directory
mkdir -p "${TMP_DIR}"
cd "${TMP_DIR}"

# Download release
echo "[1/8] Downloading SuperClaude Framework v${VERSION}..."
wget -q "https://github.com/SuperClaude-Org/SuperClaude_Framework/archive/refs/tags/v${VERSION}.tar.gz" \
  -O superclaude.tar.gz || {
  echo "ERROR: Failed to download SuperClaude Framework v${VERSION}"
  echo "Check if version exists: https://github.com/SuperClaude-Org/SuperClaude_Framework/releases"
  exit 1
}

# Extract
echo "[2/8] Extracting archive..."
tar -xzf superclaude.tar.gz

SOURCE_DIR="${TMP_DIR}/SuperClaude_Framework-${VERSION}/SuperClaude"
if [ ! -d "${SOURCE_DIR}" ]; then
  echo "ERROR: Source directory not found: ${SOURCE_DIR}"
  exit 1
fi

# Create plugin structure
echo "[3/10] Creating plugin directory structure..."
cd "${REPO_ROOT}"
mkdir -p "${PLUGIN_DIR}"/{.claude-plugin,commands/core-loading,agents,core,hooks,scripts,docs}

# Copy all commands (flat structure, no subdirectories)
echo "[4/10] Copying commands..."
cp "${SOURCE_DIR}"/Commands/*.md "${PLUGIN_DIR}/commands/" 2>/dev/null || true

# Copy core-loading command templates
echo "[5/10] Installing core-loading commands..."
cp "${REPO_ROOT}/templates/superclaude/"*.md "${PLUGIN_DIR}/commands/core-loading/"

# Copy agents
echo "[6/10] Copying agent files..."
cp "${SOURCE_DIR}"/Agents/*.md "${PLUGIN_DIR}/agents/" 2>/dev/null || true

# Copy core configs
echo "[7/10] Copying core configuration files..."
cp "${SOURCE_DIR}"/Core/*.md "${PLUGIN_DIR}/core/"

# Consolidate MCP configs
echo "[8/10] Consolidating MCP server configurations..."
cat > "${PLUGIN_DIR}/.mcp.json" <<'MCPEOF'
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": [
        "-y",
        "@upstash/context7-mcp@latest"
      ]
    },
    "magic": {
      "type": "stdio",
      "command": "npx",
      "args": [
        "@21st-dev/magic"
      ],
      "env": {
        "TWENTYFIRST_API_KEY": ""
      }
    },
    "morphllm-fast-apply": {
      "command": "npx",
      "args": [
        "@morph-llm/morph-fast-apply",
        "/home/"
      ],
      "env": {
        "MORPH_API_KEY": "",
        "ALL_TOOLS": "true"
      }
    },
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest"
      ]
    },
    "sequential-thinking": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-sequential-thinking"
      ]
    },
    "serena-docker": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-v", "${PWD}:/workspace",
        "--workdir", "/workspace",
        "python:3.11-slim",
        "bash", "-c",
        "pip install uv && uv tool install serena-ai && uv tool run serena-ai start-mcp-server --context ide-assistant --project /workspace"
      ]
    },
    "serena": {
      "command": "uvx",
      "args": [
        "--from",
        "git+https://github.com/oraios/serena",
        "serena",
        "start-mcp-server",
        "--context",
        "ide-assistant"
      ]
    },
    "tavily": {
      "command": "npx",
      "args": [
        "-y",
        "mcp-remote",
        "https://mcp.tavily.com/mcp/?tavilyApiKey=${TAVILY_API_KEY}"
      ],
      "env": {
        "TAVILY_API_KEY": "${TAVILY_API_KEY}"
      }
    }
  }
}
MCPEOF

# Create hooks configuration
echo "[9/10] Creating hooks and initialization scripts..."
cat > "${PLUGIN_DIR}/hooks/hooks.json" <<'HOOKSEOF'
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/plugin-initializer.sh \"${CLAUDE_PLUGIN_ROOT}\"",
            "timeout": 15
          }
        ]
      }
    ]
  }
}
HOOKSEOF

# Create plugin initializer script
cat > "${PLUGIN_DIR}/scripts/plugin-initializer.sh" <<'INITEOF'
#!/bin/bash

# Script: plugin-initializer.sh
# Purpose: Expand ${CLAUDE_PLUGIN_ROOT} variables in markdown files
# Usage: plugin-initializer.sh <PLUGIN_ROOT_PATH>
#
# This is a workaround for Claude Code slash commands not resolving
# ${CLAUDE_PLUGIN_ROOT} variables, while hooks do resolve them.

set -euo pipefail

# Receive CLAUDE_PLUGIN_ROOT as argument
PLUGIN_ROOT="$1"

# Marker file to check if already initialized
INITIALIZED_FLAG="${PLUGIN_ROOT}/.initialized"
PLUGIN_JSON="${PLUGIN_ROOT}/.claude-plugin/plugin.json"

# Get current plugin version from plugin.json
if [ -f "$PLUGIN_JSON" ]; then
    CURRENT_VERSION=$(grep -Po '"version":\s*"\K[^"]+' "$PLUGIN_JSON" 2>/dev/null || echo "unknown")
else
    CURRENT_VERSION="unknown"
fi

# Check if already initialized with same version
REINITIALIZING=false
if [ -f "$INITIALIZED_FLAG" ]; then
    INITIALIZED_VERSION=$(grep -Po 'Plugin version:\s*\K.*' "$INITIALIZED_FLAG" 2>/dev/null || echo "unknown")

    if [ "$INITIALIZED_VERSION" = "$CURRENT_VERSION" ]; then
        # Same version, skip initialization
        exit 0
    fi

    # Different version detected, will re-initialize
    REINITIALIZING=true
fi

# Verify plugin root directory exists
if [ ! -d "$PLUGIN_ROOT" ]; then
    echo "Error: Plugin root does not exist: $PLUGIN_ROOT" >&2
    exit 1
fi

# Function to expand variables in markdown files
expand_variables() {
    local file="$1"
    local plugin_root="$2"

    # Create temporary backup
    cp "$file" "${file}.bak"

    # Expand both ${CLAUDE_PLUGIN_ROOT} and $CLAUDE_PLUGIN_ROOT
    sed -i "s|\${CLAUDE_PLUGIN_ROOT}|${plugin_root}|g" "$file"
    sed -i "s|\$CLAUDE_PLUGIN_ROOT\([^}]\)|${plugin_root}\1|g" "$file"

    # Remove backup if successful
    rm -f "${file}.bak"
}

# Counter for processed files
COUNT=0

# Process .md files in agents/ directory
if [ -d "${PLUGIN_ROOT}/agents" ]; then
    while IFS= read -r -d '' md_file; do
        expand_variables "$md_file" "$PLUGIN_ROOT"
        COUNT=$((COUNT + 1))
    done < <(find "${PLUGIN_ROOT}/agents" -type f -name "*.md" -print0)
fi

# Process .md files in commands/ directory
if [ -d "${PLUGIN_ROOT}/commands" ]; then
    while IFS= read -r -d '' md_file; do
        expand_variables "$md_file" "$PLUGIN_ROOT"
        COUNT=$((COUNT + 1))
    done < <(find "${PLUGIN_ROOT}/commands" -type f -name "*.md" -print0)
fi

# Create marker file with metadata
cat > "$INITIALIZED_FLAG" << EOF
Initialized at: $(date -Iseconds)
Files processed: $COUNT
Plugin root: $PLUGIN_ROOT
Plugin version: $CURRENT_VERSION
EOF

# Output JSON with systemMessage for SessionStart hooks
# This ensures the message is shown to the user
if [ "$REINITIALIZING" = true ]; then
    MESSAGE="✓ Re-initialized superclaude-framework v$CURRENT_VERSION ($COUNT files updated). Restart Claude Code to load changes."
else
    MESSAGE="✓ Initialized superclaude-framework plugin v$CURRENT_VERSION ($COUNT files processed). Restart Claude Code to load changes."
fi

cat << EOF
{
  "systemMessage": "$MESSAGE"
}
EOF

exit 0
INITEOF

# Make script executable
chmod +x "${PLUGIN_DIR}/scripts/plugin-initializer.sh"

# Create plugin.json
echo "[10/10] Creating plugin manifest..."
cat > "${PLUGIN_DIR}/.claude-plugin/plugin.json" <<JSONEOF
{
  "name": "superclaude-framework",
  "version": "${VERSION}",
  "description": "SuperClaude Framework - Complete suite of behavioral rules, specialized agents, and productivity commands for enhanced Claude Code development",
  "author": {
    "name": "SuperClaude Team",
    "url": "https://github.com/SuperClaude-Org"
  },
  "homepage": "https://github.com/SuperClaude-Org/SuperClaude_Framework",
  "repository": "https://github.com/SuperClaude-Org/SuperClaude_Framework",
  "keywords": [
    "framework",
    "automation",
    "agents",
    "commands",
    "productivity",
    "behavioral-rules",
    "mcp-servers",
    "development-tools"
  ],
  "hooks": "./hooks/hooks.json",
  "mcpServers": "./.mcp.json"
}
JSONEOF

# Cleanup
rm -rf "${TMP_DIR}"

# Summary
echo ""
echo "=============================================="
echo "Build Complete!"
echo "=============================================="
echo ""
echo "Plugin Location: ${PLUGIN_DIR}"
echo "Commands: $(find "${PLUGIN_DIR}/commands" -name "*.md" | wc -l)"
echo "Agents: $(find "${PLUGIN_DIR}/agents" -name "*.md" | wc -l)"
echo "Core Configs: $(find "${PLUGIN_DIR}/core" -name "*.md" | wc -l)"
echo "MCP Servers: 8"
echo ""
echo "Next Steps:"
echo "  1. Validate: make validate-superclaude"
echo "  2. Install: claude plugin install ${PLUGIN_DIR}"
echo "  3. Test: /sc:help"
echo ""
