#!/bin/bash
set -euo pipefail

# Build ClaudeKit Skills plugin from upstream release
# Usage: ./scripts/build-claudekit-plugin.sh [VERSION|COMMIT_SHA]
# Examples:
#   ./scripts/build-claudekit-plugin.sh 1.0.0              # Download tagged release v1.0.0
#   ./scripts/build-claudekit-plugin.sh main               # Download main branch

VERSION=${1:-main}
PLUGIN_DIR="plugins/claudekit-skills"
TMP_DIR="/tmp/claudekit-build-$$"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=============================================="
echo "Building ClaudeKit Skills Plugin"
echo "Version/Branch: ${VERSION}"
echo "=============================================="
echo ""

# Create temp directory
mkdir -p "${TMP_DIR}"
cd "${TMP_DIR}"

# Determine if VERSION is a commit SHA, branch name, or version tag
if [[ ${VERSION} =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  # It's a version tag
  DOWNLOAD_URL="https://github.com/mrgoonie/claudekit-skills/archive/refs/tags/v${VERSION}.tar.gz"
  EXTRACT_DIR="claudekit-skills-${VERSION}"
  echo "[1/7] Downloading ClaudeKit Skills release v${VERSION}..."
elif [[ ${VERSION} =~ ^[0-9a-f]{7,40}$ ]]; then
  # It's a commit SHA
  DOWNLOAD_URL="https://github.com/mrgoonie/claudekit-skills/archive/${VERSION}.tar.gz"
  EXTRACT_DIR="claudekit-skills-${VERSION}"
  echo "[1/7] Downloading ClaudeKit Skills commit ${VERSION}..."
else
  # It's a branch name (main, develop, etc.)
  DOWNLOAD_URL="https://github.com/mrgoonie/claudekit-skills/archive/refs/heads/${VERSION}.tar.gz"
  EXTRACT_DIR="claudekit-skills-${VERSION}"
  echo "[1/7] Downloading ClaudeKit Skills branch ${VERSION}..."
fi

wget -q "${DOWNLOAD_URL}" -O claudekit.tar.gz || {
  echo "ERROR: Failed to download ClaudeKit Skills ${VERSION}"
  echo "Check if version/branch/commit exists:"
  echo "  - Releases: https://github.com/mrgoonie/claudekit-skills/releases"
  echo "  - Branches: https://github.com/mrgoonie/claudekit-skills/branches"
  echo "  - Commits: https://github.com/mrgoonie/claudekit-skills/commits"
  exit 1
}

# Extract
echo "[2/7] Extracting archive..."
tar -xzf claudekit.tar.gz

SOURCE_DIR="${TMP_DIR}/${EXTRACT_DIR}/.claude"
if [ ! -d "${SOURCE_DIR}" ]; then
  echo "ERROR: Source directory not found: ${SOURCE_DIR}"
  exit 1
fi

# Create plugin structure
echo "[3/7] Creating plugin directory structure..."
cd "${REPO_ROOT}"
mkdir -p "${PLUGIN_DIR}/.claude-plugin"

# Copy entire .claude directory (which contains /skills subdirectory)
echo "[4/7] Copying ClaudeKit Skills components..."
rsync -av --exclude='.gitignore' "${SOURCE_DIR}/" "${PLUGIN_DIR}/"

# Count components
SKILLS_COUNT=$(find "${PLUGIN_DIR}/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
COMMANDS_COUNT=$(find "${PLUGIN_DIR}/commands" -name "*.md" -type f 2>/dev/null | wc -l)
AGENTS_COUNT=$(find "${PLUGIN_DIR}/agents" -name "*.md" -type f 2>/dev/null | wc -l)

# Get list of skills for plugin manifest
echo "[5/9] Discovering skills..."
SKILLS_LIST=()
if [ -d "${PLUGIN_DIR}/skills" ]; then
  while IFS= read -r -d '' skill_dir; do
    skill_name=$(basename "$skill_dir")
    SKILLS_LIST+=("\"./skills/${skill_name}\"")
  done < <(find "${PLUGIN_DIR}/skills" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
fi

# Join skills array with commas
SKILLS_JSON=$(IFS=,; echo "${SKILLS_LIST[*]}")

# Create plugin.json with all components
echo "[6/9] Creating plugin manifest..."
cat > "${PLUGIN_DIR}/.claude-plugin/plugin.json" <<JSONEOF
{
  "name": "claudekit-skills",
  "version": "${VERSION}",
  "description": "ClaudeKit Skills - Comprehensive collection of specialized agent skills, commands, and agents for authentication, AI/ML, web development, cloud platforms, databases, debugging, documentation, problem-solving, and more",
  "author": {
    "name": "mrgoonie",
    "url": "https://github.com/mrgoonie"
  },
  "homepage": "https://github.com/mrgoonie/claudekit-skills",
  "repository": "https://github.com/mrgoonie/claudekit-skills",
  "license": "MIT",
  "keywords": [
    "skills",
    "agents",
    "commands",
    "authentication",
    "ai-ml",
    "web-development",
    "cloud-platforms",
    "databases",
    "debugging",
    "documentation",
    "problem-solving",
    "productivity",
    "git",
    "mcp"
  ],
  "skills": [
    ${SKILLS_JSON}
  ]
}
JSONEOF

# Create commands index if commands exist
if [ ${COMMANDS_COUNT} -gt 0 ]; then
  echo "[7/9] Indexing commands..."
  # Commands are already in place, just need to be referenced by Claude Code
fi

# Create agents index if agents exist
if [ ${AGENTS_COUNT} -gt 0 ]; then
  echo "[8/9] Indexing agents..."
  # Agents are already in place, just need to be referenced by Claude Code
fi

# Cleanup
echo "[9/9] Cleaning up..."
rm -rf "${TMP_DIR}"

# Summary
echo ""
echo "=============================================="
echo "Build Complete!"
echo "=============================================="
echo ""
echo "Plugin Location: ${PLUGIN_DIR}"
echo "Skills: ${SKILLS_COUNT}"
echo "Commands: ${COMMANDS_COUNT}"
echo "Agents: ${AGENTS_COUNT}"
echo ""
echo "Skill Categories:"
echo "  - Authentication & Security"
echo "  - AI & Agent Development"
echo "  - AI & Machine Learning"
echo "  - Web Development"
echo "  - Browser Automation & Testing"
echo "  - Cloud Platforms & DevOps"
echo "  - Databases"
echo "  - Development Tools"
echo "  - Documentation & Research"
echo "  - Code Quality & Review"
echo "  - Debugging & Quality"
echo "  - Document Processing"
echo "  - E-commerce & Platforms"
echo "  - Problem-Solving Frameworks"
echo "  - Advanced Reasoning"
echo "  - Meta Skills"
echo ""
echo ""
echo "Components:"
echo "  Commands:"
[ ${COMMANDS_COUNT} -gt 0 ] && find "${PLUGIN_DIR}/commands" -name "*.md" -type f | while read cmd; do
  echo "    - $(basename $(dirname $cmd))/$(basename $cmd .md)" | sed 's|^\./||'
done
echo "  Agents:"
[ ${AGENTS_COUNT} -gt 0 ] && find "${PLUGIN_DIR}/agents" -name "*.md" -type f | while read agent; do
  echo "    - $(basename $agent .md)"
done
echo ""
echo "Next Steps:"
echo "  1. Validate: make validate-claudekit"
echo "  2. Install: claude plugin install ${PLUGIN_DIR}"
echo "  3. Use commands: /use-mcp, /skill:create, /git:cm, /git:cp, /git:pr"
echo "  4. Use agents: Available via Task tool"
echo "  5. Browse skills: Available via skill selector"
echo ""
