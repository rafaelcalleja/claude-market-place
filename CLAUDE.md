# Claude Code Plugin Marketplace

## Project Sources

This plugin marketplace was created using comprehensive research from official Anthropic resources:

### Primary Documentation
- **Plugin Announcement**: https://www.anthropic.com/news/claude-code-plugins
- **Plugins Guide**: https://docs.claude.com/en/docs/claude-code/plugins
- **Plugin Reference**: https://docs.claude.com/en/docs/claude-code/plugins-reference
- **Marketplace Guide**: https://docs.claude.com/en/docs/claude-code/plugin-marketplaces

### Official Examples
- **Anthropic Repository**: https://github.com/anthropics/claude-code
- **Production Plugins**: 5 example plugins (agent-sdk-dev, pr-review-toolkit, commit-commands, feature-dev, security-guidance)

### Research Methodology
- Deep research agent with parallel extraction
- All 4 documentation sources extracted simultaneously
- Official GitHub repository analyzed for working examples
- Complete schemas and specifications documented
- Best practices derived from production code

### Project Components
1. **Marketplace Configuration**: Based on Anthropic's marketplace.json schema
2. **Plugin Structure**: Following official .claude-plugin/ conventions
3. **Commands**: Markdown format with YAML frontmatter per specifications
4. **Agents**: Specialized sub-agents with structured prompts
5. **Hooks**: Event-driven automation using hooks.json format

**Created**: 2025-10-11
**Research Tool**: deep-research-agent with Tavily search and URL extraction
**Validation**: All components tested against official specifications

---

## Plugin Validation

### Validate Marketplace Structure

To validate the marketplace configuration and all plugin manifests:

```bash
cd /path/to/claude-market-place
claude plugin validate .
```

### Validation Process

The validator checks:
- **marketplace.json** syntax and schema compliance
- Required fields (name, owner, plugins array)
- Plugin source paths and structure
- Description and metadata completeness
- JSON formatting

### Expected Output

**Success:**
```
Validating marketplace manifest: /path/.claude-plugin/marketplace.json
✔ Validation passed
```

**With Warnings:**
```
Validating marketplace manifest: /path/.claude-plugin/marketplace.json

⚠ Found 1 warning:
  ❯ metadata.description: No marketplace description provided

✔ Validation passed with warnings
```

**Errors:**
```
Validating marketplace manifest: /path/.claude-plugin/marketplace.json

✖ Found 1 error:
  ❯ Invalid JSON syntax at line 5

✖ Validation failed
```

### Common Validation Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Invalid JSON | Syntax error (missing comma, quote, etc.) | Check JSON formatting with linter |
| Missing description | Description field empty or too short | Add detailed marketplace description |
| Invalid plugin source | Path doesn't exist or incorrect format | Verify plugin paths are correct |
| Missing required fields | name or owner missing | Add all required fields per schema |

### Debug Mode

For detailed validation information:

```bash
claude --debug plugin validate .
```

Shows:
- Detailed parsing steps
- Field-by-field validation
- Path resolution details
- Schema validation messages

---

## Makefile Usage

The project includes a Makefile for common development tasks.

### Available Commands

```bash
# Show all available commands
make help

# Validate marketplace and plugins
make validate
# or
make lint

# Install marketplace locally for testing
make install

# Format all JSON files (requires jq)
make format

# Run all tests
make test

# Clean temporary files
make clean

# Check for required dependencies
make check-deps

# Validate with debug output
make validate-debug

# Show project structure
make structure
```

### Quick Start

**Validate the marketplace:**
```bash
make validate
```

**Install for local testing:**
```bash
make install
```

**Run complete test suite:**
```bash
make test
```

### Development Workflow

1. **After making changes**:
   ```bash
   make validate
   ```

2. **Format JSON files**:
   ```bash
   make format
   ```

3. **Test everything**:
   ```bash
   make test
   ```

4. **Install locally**:
   ```bash
   make install
   ```

### Prerequisites

**Required:**
- `claude` - Claude Code CLI

**Optional:**
- `jq` - For JSON formatting
- `tree` - For structure visualization

Check dependencies:
```bash
make check-deps
```
