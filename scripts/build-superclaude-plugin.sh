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
echo "[3/8] Creating plugin directory structure..."
cd "${REPO_ROOT}"
mkdir -p "${PLUGIN_DIR}"/{.claude-plugin,commands/core-loading,agents,core,docs}

# Copy all commands (flat structure, no subdirectories)
echo "[4/8] Copying commands..."
cp "${SOURCE_DIR}"/Commands/*.md "${PLUGIN_DIR}/commands/" 2>/dev/null || true

# Copy core-loading command templates
echo "[5/8] Installing core-loading commands..."
cp "${REPO_ROOT}/templates/superclaude/"*.md "${PLUGIN_DIR}/commands/core-loading/"

# Copy agents
echo "[6/8] Copying agent files..."
cp "${SOURCE_DIR}"/Agents/*.md "${PLUGIN_DIR}/agents/" 2>/dev/null || true

# Copy core configs
echo "[7/8] Copying core configuration files..."
cp "${SOURCE_DIR}"/Core/*.md "${PLUGIN_DIR}/core/"

# Consolidate MCP configs
echo "[8/8] Consolidating MCP server configurations..."
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

# Create plugin.json
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
