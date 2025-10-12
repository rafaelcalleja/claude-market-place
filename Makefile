.PHONY: help validate lint clean install test format

# Default target
help:
	@echo "Claude Code Plugin Marketplace - Available Commands"
	@echo ""
	@echo "  make validate    - Validate marketplace.json and plugin manifests"
	@echo "  make lint        - Alias for validate"
	@echo "  make install     - Install marketplace locally for testing"
	@echo "  make format      - Format all JSON files"
	@echo "  make test        - Run validation tests on all plugins"
	@echo "  make clean       - Clean temporary files"
	@echo "  make check-deps  - Check for required tools"
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
