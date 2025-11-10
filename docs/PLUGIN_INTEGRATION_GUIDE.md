# Plugin Integration Guide

Complete step-by-step guide for integrating external repositories as Claude Code plugins with automated build and deployment workflows.

## Table of Contents

1. [Quick Reference](#quick-reference)
2. [Overview](#overview)
3. [Prerequisites](#prerequisites)
4. [Phase 1: Repository Analysis](#phase-1-repository-analysis)
5. [Phase 2: Build Script Creation](#phase-2-build-script-creation)
6. [Phase 3: Makefile Integration](#phase-3-makefile-integration)
7. [Phase 4: Marketplace Registration](#phase-4-marketplace-registration)
8. [Phase 5: Validation & Testing](#phase-5-validation--testing)
9. [Troubleshooting](#troubleshooting)
10. [Examples](#examples)

---

## Quick Reference

**Checklist for Plugin Integration:**

- [ ] Analyze repository structure (agents, commands, skills, hooks)
- [ ] Create build script in `scripts/build-{plugin-name}-plugin.sh`
- [ ] Add Makefile targets (sync, build, validate, clean, upgrade, all)
- [ ] Register plugin in `.claude-plugin/marketplace.json`
- [ ] Create `plugin.json` with required fields
- [ ] Configure hooks if needed
- [ ] Validate plugin structure
- [ ] Test installation locally

---

## Overview

### What This Guide Covers

This guide shows how to integrate an existing GitHub repository as a Claude Code plugin with:

- Automated download and extraction
- Repeatable build process via Makefile
- Version management and upgrades
- Validation and quality checks
- Marketplace registration

### When to Use This Guide

Use this guide when you want to:

- Integrate a third-party repository as a plugin
- Create repeatable build automation
- Maintain version-controlled plugin integration
- Share plugins via marketplace

---

## Prerequisites

### Required Tools

```bash
# Check if tools are installed
which wget tar rsync git make

# Install if missing (Ubuntu/Debian)
sudo apt-get install wget tar rsync git make

# Install if missing (macOS)
brew install wget gnu-tar rsync git make
```

### Required Knowledge

- Basic bash scripting
- Makefile syntax
- Git operations
- JSON structure
- Claude Code plugin schema

---

## Phase 1: Repository Analysis

### Step 1.1: Investigate Repository Structure

Download and extract a release to examine structure:

```bash
# Example with Personal AI Infrastructure
VERSION="0.6.0"
wget "https://github.com/danielmiessler/Personal_AI_Infrastructure/archive/refs/tags/v${VERSION}.tar.gz"
tar -xzf "v${VERSION}.tar.gz"
cd "Personal_AI_Infrastructure-${VERSION}"

# List directory structure
tree -L 3 .claude/
```

### Step 1.2: Identify Components

Look for Claude Code components:

| Component | Location | Description |
|-----------|----------|-------------|
| **Agents** | `agents/` or `.claude/agents/` | Specialized subagents (*.md) |
| **Commands** | `commands/` or `.claude/commands/` | Slash commands (*.md) |
| **Skills** | `skills/` or `.claude/skills/` | Agent skills (SKILL.md) |
| **Hooks** | `hooks/` or `.claude/hooks/` | Event handlers (*.ts, hooks.json) |
| **MCP Servers** | `.mcp.json` | MCP server configurations |
| **Documentation** | `docs/` or `documentation/` | Plugin documentation |

### Step 1.3: Document Findings

Create a mapping document:

```markdown
## Repository Analysis: [Plugin Name]

**Version**: [version]
**Source**: [GitHub URL]

### Components Found:
- Agents: [count] files in [path]
- Commands: [count] files in [path]
- Skills: [count] directories in [path]
- Hooks: [count] files in [path]
- MCP Servers: [Yes/No]

### Special Considerations:
- [Any custom structure notes]
- [Dependencies or requirements]
- [Files to exclude]
```

---

## Phase 2: Build Script Creation

### Step 2.1: Create Script File

Create `scripts/build-{plugin-name}-plugin.sh`:

```bash
#!/bin/bash
set -euo pipefail

# Build [Plugin Name] plugin from upstream release
# Usage: ./scripts/build-{plugin-name}-plugin.sh [VERSION]

VERSION=${1:-[DEFAULT_VERSION]}
PLUGIN_DIR="plugins/{plugin-name}"
TMP_DIR="/tmp/{plugin-name}-build-$$"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=============================================="
echo "Building [Plugin Name] Plugin"
echo "Version: ${VERSION}"
echo "=============================================="
echo ""

# Create temp directory
mkdir -p "${TMP_DIR}"
cd "${TMP_DIR}"

# Download release
echo "[1/8] Downloading [Plugin Name] v${VERSION}..."
wget -q "[GITHUB_URL]/archive/refs/tags/v${VERSION}.tar.gz" \
  -O plugin.tar.gz || {
  echo "ERROR: Failed to download v${VERSION}"
  echo "Check if version exists: [RELEASES_URL]"
  exit 1
}

# Extract
echo "[2/8] Extracting archive..."
tar -xzf plugin.tar.gz

SOURCE_DIR="${TMP_DIR}/[REPO_NAME]-${VERSION}/[SOURCE_PATH]"
if [ ! -d "${SOURCE_DIR}" ]; then
  echo "ERROR: Source directory not found: ${SOURCE_DIR}"
  exit 1
fi

# Create plugin structure
echo "[3/8] Creating plugin directory structure..."
cd "${REPO_ROOT}"
mkdir -p "${PLUGIN_DIR}/.claude-plugin"

# Copy components
echo "[4/8] Copying plugin components..."
rsync -av \
  --exclude='settings.json' \
  --exclude='setup.sh' \
  "${SOURCE_DIR}/" "${PLUGIN_DIR}/"

# Create hooks.json if needed
echo "[5/8] Creating hooks configuration..."
# [Add hooks.json creation if repository has hooks]

# Count components
AGENTS_COUNT=$(find "${PLUGIN_DIR}/agents" -name "*.md" 2>/dev/null | wc -l)
COMMANDS_COUNT=$(find "${PLUGIN_DIR}/commands" -name "*.md" 2>/dev/null | wc -l)
SKILLS_COUNT=$(find "${PLUGIN_DIR}/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
HOOKS_COUNT=$(find "${PLUGIN_DIR}/hooks" -name "*.ts" 2>/dev/null | wc -l)

# Create plugin.json
echo "[6/8] Creating plugin manifest..."
cat > "${PLUGIN_DIR}/.claude-plugin/plugin.json" <<JSONEOF
{
  "name": "{plugin-name}",
  "version": "${VERSION}",
  "description": "[Plugin description]",
  "author": {
    "name": "[Author Name]",
    "url": "[Author URL]"
  },
  "homepage": "[Homepage URL]",
  "repository": "[Repository URL]",
  "license": "[License]",
  "keywords": [
    "[keyword1]",
    "[keyword2]"
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
echo "Hooks: ${HOOKS_COUNT}"
echo ""
echo "Next Steps:"
echo "  1. Validate: make validate-{plugin-name}"
echo "  2. Install: claude plugin install ${PLUGIN_DIR}"
echo ""
```

### Step 2.2: Make Script Executable

```bash
chmod +x scripts/build-{plugin-name}-plugin.sh
```

### Step 2.3: Test Build Script

```bash
./scripts/build-{plugin-name}-plugin.sh
```

---

## Phase 3: Makefile Integration

### Step 3.1: Add Version Variable

Add to top of Makefile:

```makefile
# [Plugin Name] version
PLUGIN_VERSION ?= [DEFAULT_VERSION]
```

### Step 3.2: Update .PHONY Declaration

```makefile
.PHONY: sync-{plugin-name} build-{plugin-name}-plugin validate-{plugin-name} clean-{plugin-name} upgrade-{plugin-name} {plugin-name}-all
```

### Step 3.3: Add Help Text

```makefile
@echo "[Plugin Name]:"
@echo "  make sync-{plugin-name}           - Download release (v$(PLUGIN_VERSION))"
@echo "  make build-{plugin-name}-plugin   - Build plugin from downloaded source"
@echo "  make validate-{plugin-name}       - Validate plugin"
@echo "  make clean-{plugin-name}          - Clean plugin components"
@echo "  make upgrade-{plugin-name}        - Upgrade to new version (interactive)"
@echo "  make {plugin-name}-all            - Complete workflow: clean → build → validate → lint"
@echo ""
```

### Step 3.4: Add Targets

```makefile
# ============================================
# [Plugin Name] Targets
# ============================================

# Download release
sync-{plugin-name}:
	@echo "Downloading [Plugin Name] v$(PLUGIN_VERSION)..."
	@mkdir -p /tmp
	@cd /tmp && \
		wget -q "[GITHUB_URL]/archive/refs/tags/v$(PLUGIN_VERSION).tar.gz" \
		-O {plugin-name}-$(PLUGIN_VERSION).tar.gz && \
		tar -xzf {plugin-name}-$(PLUGIN_VERSION).tar.gz && \
		rm {plugin-name}-$(PLUGIN_VERSION).tar.gz
	@echo "✓ [Plugin Name] v$(PLUGIN_VERSION) downloaded to /tmp/[Repo-Name]-$(PLUGIN_VERSION)"

# Build plugin from downloaded source
build-{plugin-name}-plugin:
	@./scripts/build-{plugin-name}-plugin.sh $(PLUGIN_VERSION)

# Validate plugin
validate-{plugin-name}:
	@claude plugin validate plugins/{plugin-name}

# Clean plugin components
clean-{plugin-name}:
	@echo "Cleaning [Plugin Name] components..."
	@rm -rf plugins/{plugin-name}/agents/
	@rm -rf plugins/{plugin-name}/commands/
	@rm -rf plugins/{plugin-name}/skills/
	@rm -rf plugins/{plugin-name}/hooks/
	@rm -rf plugins/{plugin-name}/documentation/
	@rm -f plugins/{plugin-name}/.mcp.json
	@echo "✓ [Plugin Name] cleaned"

# Upgrade to new version (interactive)
upgrade-{plugin-name}:
	@echo "Current version: $(PLUGIN_VERSION)"
	@read -p "Enter new version: " NEW_VERSION; \
	if [ -z "$$NEW_VERSION" ]; then \
		echo "✗ No version provided"; \
		exit 1; \
	fi; \
	echo "Upgrading to v$$NEW_VERSION..."; \
	$(MAKE) build-{plugin-name}-plugin PLUGIN_VERSION=$$NEW_VERSION && \
	$(MAKE) validate-{plugin-name} && \
	echo "✓ [Plugin Name] upgraded to v$$NEW_VERSION"

# Complete workflow: clean → build → validate → lint
{plugin-name}-all:
	@echo "=================================================="
	@echo "[Plugin Name] Complete Workflow"
	@echo "Version: $(PLUGIN_VERSION)"
	@echo "=================================================="
	@echo ""
	@echo "[1/4] Cleaning..."
	@$(MAKE) clean-{plugin-name}
	@echo ""
	@echo "[2/4] Building..."
	@$(MAKE) build-{plugin-name}-plugin
	@echo ""
	@echo "[3/4] Validating plugin..."
	@$(MAKE) validate-{plugin-name}
	@echo ""
	@echo "[4/4] Validating marketplace..."
	@$(MAKE) lint
	@echo ""
	@echo "=================================================="
	@echo "✓ Complete workflow finished successfully!"
	@echo "=================================================="
```

---

## Phase 4: Marketplace Registration

### Step 4.1: Add Plugin Entry

Edit `.claude-plugin/marketplace.json`:

```json
{
  "name": "{plugin-name}",
  "description": "[Brief description of plugin functionality and features]",
  "version": "[VERSION]",
  "author": {
    "name": "[Author Name]",
    "url": "[Author URL]"
  },
  "source": "./plugins/{plugin-name}",
  "category": "[framework|productivity|tools|security]",
  "keywords": ["[keyword1]", "[keyword2]", "[keyword3]"],
  "license": "[License]",
  "homepage": "[Homepage URL]"
}
```

### Step 4.2: Plugin.json Schema Requirements

Required fields according to official Claude Code schema:

```json
{
  "name": "plugin-name",              // Required: kebab-case, no spaces
  "version": "1.0.0",                 // Recommended: semantic version
  "description": "...",               // Recommended: brief explanation
  "author": {                         // Recommended
    "name": "Author Name",
    "email": "author@example.com",    // Optional
    "url": "https://author.com"       // Optional
  },
  "homepage": "https://...",          // Recommended: documentation URL
  "repository": "https://github...",  // Recommended: source code URL
  "license": "MIT",                   // Recommended: license identifier
  "keywords": ["tag1", "tag2"],       // Recommended: discovery tags
  "hooks": "./hooks/hooks.json",      // Optional: if hooks exist
  "mcpServers": "./.mcp.json"         // Optional: if MCP servers exist
}
```

**Important Notes:**

- **DO NOT** declare `commands`, `agents`, or `skills` fields unless using custom paths
- Default directories (`commands/`, `agents/`, `skills/`) are auto-discovered
- Only declare component paths for additional/custom locations
- Paths must be relative and start with `./`

---

## Phase 5: Validation & Testing

### Step 5.1: Validate Plugin Structure

```bash
# Validate individual plugin
make validate-{plugin-name}

# Validate entire marketplace
make validate
```

### Step 5.2: Test Local Installation

```bash
# Install plugin locally
claude plugin install plugins/{plugin-name}

# List installed plugins
claude plugin list

# Test plugin functionality
# [Plugin-specific test commands]
```

### Step 5.3: Verify Components

```bash
# Check component counts
echo "Agents: $(ls -1 plugins/{plugin-name}/agents/*.md 2>/dev/null | wc -l)"
echo "Commands: $(ls -1 plugins/{plugin-name}/commands/*.md 2>/dev/null | wc -l)"
echo "Skills: $(ls -d plugins/{plugin-name}/skills/*/ 2>/dev/null | wc -l)"
echo "Hooks: $(ls -1 plugins/{plugin-name}/hooks/*.ts 2>/dev/null | wc -l)"
```

### Step 5.4: Complete Workflow Test

```bash
# Run complete workflow
make {plugin-name}-all

# Verify output
# - All steps should complete successfully
# - Validation should pass
# - No errors in console output
```

---

## Troubleshooting

### Common Issues

#### Issue: Plugin validation fails with "must end with .md"

**Cause**: Incorrect path declaration in plugin.json

**Solution**: Remove explicit `commands`, `agents`, `skills` declarations. These directories are auto-discovered.

```json
// ❌ WRONG
{
  "commands": "./commands/",
  "agents": "./agents/"
}

// ✅ CORRECT - omit these fields
{
  "hooks": "./hooks/hooks.json",
  "mcpServers": "./.mcp.json"
}
```

#### Issue: Hooks not executing

**Cause**: Hooks scripts not executable or incorrect path

**Solution**:
```bash
# Make hooks executable
chmod +x plugins/{plugin-name}/hooks/*.ts

# Verify hooks.json uses ${CLAUDE_PLUGIN_ROOT}
cat plugins/{plugin-name}/hooks/hooks.json
```

#### Issue: MCP servers not loading

**Cause**: Missing or incorrect .mcp.json configuration

**Solution**: Verify .mcp.json exists and uses correct paths:
```json
{
  "mcpServers": {
    "server-name": {
      "command": "${CLAUDE_PLUGIN_ROOT}/path/to/server"
    }
  }
}
```

#### Issue: Components not found after installation

**Cause**: Incorrect directory structure or rsync exclusions

**Solution**: Check rsync command in build script:
```bash
# Verify components were copied
ls -la plugins/{plugin-name}/

# Adjust rsync exclusions if needed
rsync -av --exclude='unwanted-file' source/ dest/
```

#### Issue: Version conflicts during upgrade

**Cause**: Old plugin files not cleaned properly

**Solution**:
```bash
# Clean completely before rebuild
make clean-{plugin-name}
make build-{plugin-name}-plugin
```

---

## Examples

### Example 1: SuperClaude Framework

**Repository**: https://github.com/SuperClaude-Org/SuperClaude_Framework

**Structure**:
```
SuperClaude_Framework/
└── SuperClaude/
    ├── Commands/      → commands/
    ├── Agents/        → agents/
    └── Core/          → core/
```

**Key Features**:
- Commands converted to slash commands
- Agents as specialized subagents
- Core behavioral rules
- Custom MCP servers configuration

**Files**:
- `scripts/build-superclaude-plugin.sh`
- Makefile targets: `superclaude-all`, etc.

### Example 2: Personal AI Infrastructure (PAI)

**Repository**: https://github.com/danielmiessler/Personal_AI_Infrastructure

**Structure**:
```
Personal_AI_Infrastructure/
└── .claude/
    ├── agents/        → agents/
    ├── commands/      → commands/
    ├── skills/        → skills/
    ├── hooks/         → hooks/
    └── .mcp.json      → .mcp.json
```

**Key Features**:
- 8 specialized agents
- 5 research commands
- 7 skills (including Fabric patterns)
- 10 TypeScript hooks
- Complete MCP server setup

**Special Handling**:
- Created hooks.json from settings.json configuration
- Excluded voice-server components
- Used ${CLAUDE_PLUGIN_ROOT} for hook paths

**Files**:
- `scripts/build-pai-plugin.sh`
- Makefile targets: `pai-all`, etc.

---

## Best Practices

### 1. Version Management

- Use semantic versioning (MAJOR.MINOR.PATCH)
- Tag releases in source repository
- Document breaking changes
- Test upgrades before committing

### 2. Script Robustness

- Always use `set -euo pipefail`
- Check for required tools
- Validate downloads with checksums
- Clean up temporary files
- Provide clear error messages

### 3. Documentation

- Document plugin-specific requirements
- Include usage examples
- List all available commands/agents
- Note API key requirements
- Provide troubleshooting guide

### 4. Testing

- Test with multiple versions
- Verify all components load
- Check hook execution
- Validate MCP server connections
- Test upgrade path

### 5. Maintenance

- Monitor upstream releases
- Update regularly
- Deprecate old versions
- Maintain backward compatibility
- Document migration paths

---

## References

- [Claude Code Plugin Documentation](https://docs.claude.com/en/docs/claude-code/plugins)
- [Plugin Reference Schema](https://docs.claude.com/en/docs/claude-code/plugins-reference)
- [Plugin Marketplaces](https://docs.claude.com/en/docs/claude-code/plugin-marketplaces)
- [SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework)
- [Personal AI Infrastructure](https://github.com/danielmiessler/Personal_AI_Infrastructure)

---

## Changelog

- **2025-01-10**: Initial version based on SuperClaude and PAI integrations
