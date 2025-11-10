#!/bin/bash
set -euo pipefail

# Build Personal AI Infrastructure (PAI) plugin from upstream release or commit
# Usage: ./scripts/build-pai-plugin.sh [VERSION|COMMIT_SHA]
# Examples:
#   ./scripts/build-pai-plugin.sh 0.6.0              # Download tagged release v0.6.0
#   ./scripts/build-pai-plugin.sh 42a7aa754fa86f27   # Download specific commit

VERSION=${1:-0.6.0}
PLUGIN_DIR="plugins/personal-ai-infrastructure"
TMP_DIR="/tmp/pai-build-$$"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=============================================="
echo "Building Personal AI Infrastructure Plugin"
echo "Version/Commit: ${VERSION}"
echo "=============================================="
echo ""

# Create temp directory
mkdir -p "${TMP_DIR}"
cd "${TMP_DIR}"

# Determine if VERSION is a commit SHA (40 chars hex) or a version tag
if [[ ${VERSION} =~ ^[0-9a-f]{7,40}$ ]]; then
  # It's a commit SHA
  DOWNLOAD_URL="https://github.com/danielmiessler/Personal_AI_Infrastructure/archive/${VERSION}.tar.gz"
  EXTRACT_DIR="Personal_AI_Infrastructure-${VERSION}"
  echo "[1/8] Downloading PAI commit ${VERSION}..."
else
  # It's a version tag
  DOWNLOAD_URL="https://github.com/danielmiessler/Personal_AI_Infrastructure/archive/refs/tags/v${VERSION}.tar.gz"
  EXTRACT_DIR="Personal_AI_Infrastructure-${VERSION}"
  echo "[1/8] Downloading PAI release v${VERSION}..."
fi

wget -q "${DOWNLOAD_URL}" -O pai.tar.gz || {
  echo "ERROR: Failed to download PAI ${VERSION}"
  echo "Check if version/commit exists:"
  echo "  - Releases: https://github.com/danielmiessler/Personal_AI_Infrastructure/releases"
  echo "  - Commits: https://github.com/danielmiessler/Personal_AI_Infrastructure/commits"
  exit 1
}

# Extract
echo "[2/8] Extracting archive..."
tar -xzf pai.tar.gz

SOURCE_DIR="${TMP_DIR}/${EXTRACT_DIR}/.claude"
if [ ! -d "${SOURCE_DIR}" ]; then
  echo "ERROR: Source directory not found: ${SOURCE_DIR}"
  exit 1
fi

# Create plugin structure
echo "[3/8] Creating plugin directory structure..."
cd "${REPO_ROOT}"
mkdir -p "${PLUGIN_DIR}/.claude-plugin"

# Copy entire .claude directory contents
echo "[4/8] Copying PAI components..."
rsync -av --exclude='settings.json' --exclude='setup.sh' "${SOURCE_DIR}/" "${PLUGIN_DIR}/"

# Create hooks.json configuration (based on PAI settings.json)
echo "[5/8] Creating hooks configuration..."
cat > "${PLUGIN_DIR}/hooks/hooks.json" <<'HOOKSEOF'
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/capture-all-events.ts --event-type PreToolUse"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/capture-all-events.ts --event-type PostToolUse"
          }
        ]
      }
    ],
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/capture-session-summary.ts"
          },
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/capture-all-events.ts --event-type SessionEnd"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/update-tab-titles.ts"
          },
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/capture-all-events.ts --event-type UserPromptSubmit"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/load-core-context.ts"
          },
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/initialize-pai-session.ts"
          },
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/capture-all-events.ts --event-type SessionStart"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/stop-hook.ts"
          },
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/capture-all-events.ts --event-type Stop"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/subagent-stop-hook.ts"
          },
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/capture-all-events.ts --event-type SubagentStop"
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/context-compression-hook.ts"
          },
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/capture-all-events.ts --event-type PreCompact"
          }
        ]
      }
    ]
  }
}
HOOKSEOF

# Count components
AGENTS_COUNT=$(find "${PLUGIN_DIR}/agents" -name "*.md" 2>/dev/null | wc -l)
COMMANDS_COUNT=$(find "${PLUGIN_DIR}/commands" -name "*.md" 2>/dev/null | wc -l)
SKILLS_COUNT=$(find "${PLUGIN_DIR}/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
HOOKS_COUNT=$(find "${PLUGIN_DIR}/hooks" -name "*.ts" 2>/dev/null | wc -l)

# Create plugin.json
echo "[6/8] Creating plugin manifest..."
cat > "${PLUGIN_DIR}/.claude-plugin/plugin.json" <<JSONEOF
{
  "name": "personal-ai-infrastructure",
  "version": "${VERSION}",
  "description": "Personal AI Infrastructure (PAI) - Complete personal AI platform with skills, agents, research capabilities, and automation workflows",
  "author": {
    "name": "Daniel Miessler",
    "url": "https://danielmiessler.com"
  },
  "homepage": "https://github.com/danielmiessler/Personal_AI_Infrastructure",
  "repository": "https://github.com/danielmiessler/Personal_AI_Infrastructure",
  "license": "MIT",
  "keywords": [
    "personal-ai",
    "skills",
    "fabric",
    "research",
    "workflows",
    "agents",
    "automation",
    "productivity"
  ],
  "hooks": "./hooks/hooks.json",
  "mcpServers": "./.mcp.json"
}
JSONEOF

# Make hooks executable
echo "[7/8] Making hooks executable..."
chmod +x "${PLUGIN_DIR}"/hooks/*.ts 2>/dev/null || true

# Cleanup
echo "[8/8] Cleaning up..."
rm -rf "${TMP_DIR}"

# Summary
echo ""
echo "=============================================="
echo "Build Complete!"
echo "=============================================="
echo ""
echo "Plugin Location: ${PLUGIN_DIR}"
echo "Agents: ${AGENTS_COUNT}"
echo "Commands: ${COMMANDS_COUNT}"
echo "Skills: ${SKILLS_COUNT}"
echo "Hooks: ${HOOKS_COUNT} (configured in hooks.json)"
echo ""
echo "Next Steps:"
echo "  1. Validate: make validate-pai"
echo "  2. Install: claude plugin install ${PLUGIN_DIR}"
echo "  3. Configure API keys in .mcp.json if needed"
echo ""
