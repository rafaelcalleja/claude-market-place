.PHONY: help validate lint clean install test format sync-superclaude upgrade-superclaude build-superclaude-plugin validate-superclaude clean-superclaude superclaude-all

# SuperClaude Framework version
SUPERCLAUDE_VERSION ?= 4.1.5

# Default target
help:
	@echo "Claude Code Plugin Marketplace - Available Commands"
	@echo ""
	@echo "General:"
	@echo "  make validate    - Validate marketplace.json and plugin manifests"
	@echo "  make lint        - Alias for validate"
	@echo "  make install     - Install marketplace locally for testing"
	@echo "  make format      - Format all JSON files"
	@echo "  make test        - Run validation tests on all plugins"
	@echo "  make clean       - Clean temporary files"
	@echo "  make check-deps  - Check for required tools"
	@echo ""
	@echo "SuperClaude Framework:"
	@echo "  make sync-superclaude           - Download SuperClaude release (v$(SUPERCLAUDE_VERSION))"
	@echo "  make build-superclaude-plugin   - Build SuperClaude plugin from downloaded source"
	@echo "  make validate-superclaude       - Validate SuperClaude plugin"
	@echo "  make clean-superclaude          - Clean SuperClaude plugin components"
	@echo "  make upgrade-superclaude        - Upgrade SuperClaude to new version (interactive)"
	@echo "  make superclaude-all            - Complete workflow: clean → build → validate → lint"
	@echo ""

# Validate marketplace and plugin configurations
validate:
	@echo "Validating marketplace configuration..."
	@claude plugin validate .
	@echo "✓ Validation complete"

# Alias for validate
lint: validate

# Install marketplace locally
install:
	@echo "Installing marketplace locally..."
	@claude plugin marketplace add $(shell pwd)
	@echo "✓ Marketplace installed"
	@echo ""
	@echo "To install plugins, run:"
	@echo "  /plugin install productivity-commands@example-marketplace"
	@echo "  /plugin install code-analysis-agents@example-marketplace"
	@echo "  /plugin install auto-formatter@example-marketplace"

# Format JSON files
format:
	@echo "Formatting JSON files..."
	@find . -name "*.json" -type f -exec sh -c 'jq --indent 2 . "{}" > "{}.tmp" && mv "{}.tmp" "{}"' \; 2>/dev/null || echo "jq not found, skipping format"
	@echo "✓ JSON files formatted"

# Test all plugin configurations
test: validate
	@echo "Testing plugin configurations..."
	@test -f .claude-plugin/marketplace.json || (echo "✗ marketplace.json not found" && exit 1)
	@test -f plugins/productivity-commands/.claude-plugin/plugin.json || (echo "✗ productivity-commands plugin.json not found" && exit 1)
	@test -f plugins/code-analysis-agents/.claude-plugin/plugin.json || (echo "✗ code-analysis-agents plugin.json not found" && exit 1)
	@test -f plugins/auto-formatter/.claude-plugin/plugin.json || (echo "✗ auto-formatter plugin.json not found" && exit 1)
	@echo "✓ All plugin manifests found"
	@echo "✓ All tests passed"

# Clean temporary and generated files
clean:
	@echo "Cleaning temporary files..."
	@find . -name "*.tmp" -type f -delete
	@find . -name ".DS_Store" -type f -delete
	@find . -name "*~" -type f -delete
	@echo "✓ Cleanup complete"

# Check for required dependencies
check-deps:
	@echo "Checking for required tools..."
	@command -v claude >/dev/null 2>&1 || (echo "✗ claude command not found" && exit 1)
	@echo "✓ claude: installed"
	@command -v jq >/dev/null 2>&1 && echo "✓ jq: installed (optional)" || echo "○ jq: not installed (optional - for JSON formatting)"
	@echo ""
	@echo "All required dependencies are available"

# Validate with debug output
validate-debug:
	@echo "Running validation with debug output..."
	@claude --debug plugin validate .

# Show plugin structure
structure:
	@echo "Plugin Marketplace Structure:"
	@tree -L 3 -I 'node_modules|__pycache__|*.pyc' . 2>/dev/null || find . -maxdepth 3 -type d | grep -v "/\." | sed 's|^\./||' | sed 's|[^/]*/| |g'

# ============================================
# SuperClaude Framework Targets
# ============================================

# Download SuperClaude Framework release
sync-superclaude:
	@echo "Downloading SuperClaude Framework v$(SUPERCLAUDE_VERSION)..."
	@mkdir -p /tmp
	@cd /tmp && \
		wget -q "https://github.com/SuperClaude-Org/SuperClaude_Framework/archive/refs/tags/v$(SUPERCLAUDE_VERSION).tar.gz" \
		-O superclaude-$(SUPERCLAUDE_VERSION).tar.gz && \
		tar -xzf superclaude-$(SUPERCLAUDE_VERSION).tar.gz && \
		rm superclaude-$(SUPERCLAUDE_VERSION).tar.gz
	@echo "✓ SuperClaude Framework v$(SUPERCLAUDE_VERSION) downloaded to /tmp/SuperClaude_Framework-$(SUPERCLAUDE_VERSION)"

# Build SuperClaude plugin from downloaded source
build-superclaude-plugin:
	@./scripts/build-superclaude-plugin.sh $(SUPERCLAUDE_VERSION)

# Validate SuperClaude plugin
validate-superclaude:
	@claude plugin validate plugins/superclaude-framework

# Clean SuperClaude plugin components
clean-superclaude:
	@echo "Cleaning SuperClaude components..."
	@rm -rf plugins/superclaude-framework/commands/
	@rm -rf plugins/superclaude-framework/agents/
	@rm -rf plugins/superclaude-framework/core/
	@rm -rf plugins/superclaude-framework/docs/
	@rm -f plugins/superclaude-framework/.mcp.json
	@echo "✓ SuperClaude cleaned"

# Upgrade SuperClaude to new version (interactive)
upgrade-superclaude:
	@echo "Current version: $(SUPERCLAUDE_VERSION)"
	@read -p "Enter new version: " NEW_VERSION; \
	if [ -z "$$NEW_VERSION" ]; then \
		echo "✗ No version provided"; \
		exit 1; \
	fi; \
	echo "Upgrading to v$$NEW_VERSION..."; \
	$(MAKE) build-superclaude-plugin SUPERCLAUDE_VERSION=$$NEW_VERSION && \
	$(MAKE) validate-superclaude && \
	echo "✓ SuperClaude Framework upgraded to v$$NEW_VERSION"

# Complete SuperClaude workflow: clean → build → validate → lint
superclaude-all:
	@echo "=================================================="
	@echo "SuperClaude Complete Workflow"
	@echo "Version: $(SUPERCLAUDE_VERSION)"
	@echo "=================================================="
	@echo ""
	@echo "[1/4] Cleaning..."
	@$(MAKE) clean-superclaude
	@echo ""
	@echo "[2/4] Building..."
	@$(MAKE) build-superclaude-plugin
	@echo ""
	@echo "[3/4] Validating plugin..."
	@$(MAKE) validate-superclaude
	@echo ""
	@echo "[4/4] Validating marketplace..."
	@$(MAKE) lint
	@echo ""
	@echo "=================================================="
	@echo "✓ Complete workflow finished successfully!"
	@echo "=================================================="
