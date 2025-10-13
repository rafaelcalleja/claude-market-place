# SuperClaude Framework Plugin

Complete SuperClaude Framework v4.1.5 packaged as a Claude Code plugin. This plugin provides behavioral rules, specialized agents, productivity commands, and MCP server integrations for enhanced development workflows.

## Overview

The SuperClaude Framework is a comprehensive system that enhances Claude Code with:
- **Behavioral Rules & Flags**: Execution modes and quality standards
- **Specialized Agents**: Task-specific AI agents for complex workflows
- **Productivity Commands**: 28 slash commands organized by category
- **MCP Integrations**: 8 Model Context Protocol servers for extended capabilities

## Installation

Install from the Claude Code marketplace:

```bash
claude plugin install superclaude-framework
```

Or install from local source:

```bash
cd /path/to/claude-market-place
claude plugin install plugins/superclaude-framework
```

## Quick Start

### Load Core Framework

To activate the complete SuperClaude behavioral system:

```
/sc:load-core
```

This loads all core configurations:
- FLAGS.md - Behavioral execution flags
- RULES.md - Code quality and safety rules
- PRINCIPLES.md - Software engineering principles
- RESEARCH_CONFIG.md - Deep research configuration
- BUSINESS_PANEL_EXAMPLES.md - Business panel examples
- BUSINESS_SYMBOLS.md - Business communication symbols

### Load Individual Components

```
/sc:load-flags    # Load only behavioral flags
/sc:load-rules    # Load only behavioral rules
```

## Available Commands (28)

### Core Loading (3)
- `/sc:load-core` - Load complete SuperClaude Core framework
- `/sc:load-flags` - Load behavioral flags
- `/sc:load-rules` - Load behavioral rules

### Development (5)
- `/sc:implement` - Feature and code implementation with intelligent persona activation
- `/sc:build` - Build, compile, and package projects with error handling
- `/sc:test` - Execute tests with coverage analysis and quality reporting
- `/sc:improve` - Apply systematic improvements to code quality and performance
- `/sc:cleanup` - Clean up code, remove dead code, optimize structure

### Analysis (4)
- `/sc:analyze` - Comprehensive code analysis (quality, security, performance, architecture)
- `/sc:troubleshoot` - Diagnose and resolve issues in code, builds, deployments
- `/sc:explain` - Provide clear explanations of code, concepts, system behavior
- `/sc:research` - Deep web research with adaptive planning and intelligent search

### Planning (7)
- `/sc:design` - Design system architecture, APIs, and component interfaces
- `/sc:workflow` - Generate structured implementation workflows from requirements
- `/sc:brainstorm` - Interactive requirements discovery through Socratic dialogue
- `/sc:estimate` - Development estimates with intelligent analysis
- `/sc:document` - Generate focused documentation for components, functions, APIs
- `/sc:business-panel` - Multi-expert business review panel
- `/sc:spec-panel` - Multi-expert specification review panel

### Advanced (9)
- `/sc:spawn` - Meta-system task orchestration with intelligent breakdown
- `/sc:task` - Execute complex tasks with intelligent workflow management
- `/sc:reflect` - Task reflection and validation using Serena MCP
- `/sc:load` - Session lifecycle management with Serena MCP (load context)
- `/sc:save` - Session lifecycle management with Serena MCP (save context)
- `/sc:select-tool` - Intelligent MCP tool selection based on complexity scoring
- `/sc:help` - List all available /sc commands
- `/sc:git` - Git operations with intelligent commit messages
- `/sc:index` - Generate comprehensive project documentation and knowledge base

## Specialized Agents (16)

The framework includes 16 specialized agents for complex tasks:

- `agent-architect.md` - System architecture design
- `agent-business.md` - Business analysis and strategy
- `agent-code-reviewer.md` - Code quality and review
- `agent-debugger.md` - Issue diagnosis and resolution
- `agent-devops.md` - Deployment and infrastructure
- `agent-documentation.md` - Technical documentation
- `agent-performance.md` - Performance optimization
- `agent-refactoring.md` - Code refactoring and modernization
- `agent-research.md` - Deep research and analysis
- `agent-security.md` - Security assessment and hardening
- `agent-tdd.md` - Test-driven development
- `agent-testing.md` - Test strategy and implementation
- `agent-ui-ux.md` - User interface and experience
- Plus 3 additional agents

## MCP Server Integrations (8)

The plugin configures 8 MCP servers for extended capabilities:

### 1. Context7
Library documentation and curated knowledge lookup.
```
No API key required
```

### 2. Magic (21st.dev)
Modern UI component generation from 21st.dev patterns.
```bash
export TWENTYFIRST_API_KEY="your_key"
```

### 3. Morphllm Fast Apply
Bulk code transformations and pattern-based edits.
```bash
export MORPH_API_KEY="your_key"
```

### 4. Playwright
Browser automation and E2E testing.
```
No API key required
```

### 5. Sequential Thinking
Structured multi-step reasoning and hypothesis testing.
```
No API key required
```

### 6. Serena (Standard)
Semantic understanding and session persistence.
```
Requires uvx and serena installation
```

### 7. Serena (Docker)
Dockerized version of Serena for containerized environments.
```
Requires Docker
```

### 8. Tavily
Real-time web search and information retrieval.
```bash
export TAVILY_API_KEY="your_key"
```

## Environment Variables

Set the following environment variables for MCP servers requiring API keys:

```bash
# Magic (21st.dev) - UI component generation
export TWENTYFIRST_API_KEY="your_21st_dev_api_key"

# Morphllm - Code transformations
export MORPH_API_KEY="your_morph_api_key"

# Tavily - Web search
export TAVILY_API_KEY="your_tavily_api_key"
```

Add to your `~/.bashrc`, `~/.zshrc`, or equivalent shell configuration file.

## Usage Examples

### Example 1: Complete Development Workflow

```bash
# 1. Load framework
/sc:load-core

# 2. Design feature
/sc:design "Add user authentication system"

# 3. Generate workflow
/sc:workflow

# 4. Implement feature
/sc:implement

# 5. Run tests
/sc:test

# 6. Analyze quality
/sc:analyze

# 7. Commit changes
/sc:git
```

### Example 2: Research and Analysis

```bash
# 1. Deep research on topic
/sc:research "Best practices for serverless authentication"

# 2. Analyze findings
/sc:analyze

# 3. Generate documentation
/sc:document
```

### Example 3: Code Improvement

```bash
# 1. Troubleshoot issues
/sc:troubleshoot

# 2. Apply improvements
/sc:improve

# 3. Clean up code
/sc:cleanup

# 4. Run tests
/sc:test
```

## Core Framework Components

### FLAGS.md
Behavioral flags for specific execution modes:
- `--brainstorm` - Collaborative discovery
- `--introspect` - Meta-cognition and reasoning
- `--task-manage` - Multi-step orchestration
- `--think`, `--think-hard`, `--ultrathink` - Analysis depth
- `--c7`, `--seq`, `--magic`, etc. - MCP server activation
- Plus 15+ additional flags

### RULES.md
Behavioral rules organized by priority:
- Critical (Security, data safety, production)
- Important (Quality, maintainability, professionalism)
- Recommended (Optimization, style, best practices)

Includes decision trees and quick reference guides.

### PRINCIPLES.md
Software engineering principles:
- SOLID principles
- Core patterns (DRY, KISS, YAGNI)
- Systems thinking
- Decision frameworks
- Quality standards

### RESEARCH_CONFIG.md
Deep research configuration:
- Planning strategies
- Multi-hop patterns
- Confidence scoring
- Source credibility matrix
- Tool coordination

## Plugin Structure

```
superclaude-framework/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── .mcp.json                # Consolidated MCP server configs
├── commands/
│   ├── core-loading/        # Framework loading commands (3)
│   ├── development/         # Development commands (5)
│   ├── analysis/            # Analysis commands (4)
│   ├── planning/            # Planning commands (7)
│   └── advanced/            # Advanced commands (9)
├── agents/                  # Specialized agents (16)
├── core/                    # Core framework configs (6)
└── README.md
```

## Development

### Building from Source

```bash
# Clone marketplace
git clone https://github.com/your-org/claude-market-place.git
cd claude-market-place

# Build SuperClaude plugin
make build-superclaude-plugin

# Validate
make validate-superclaude
```

### Upgrading to New Version

```bash
# Upgrade to specific version
make upgrade-superclaude

# Or sync manually
make sync-superclaude SUPERCLAUDE_VERSION=4.1.6
make build-superclaude-plugin
```

## Requirements

**Minimum:**
- Claude Code CLI
- Node.js (for most MCP servers)

**Optional:**
- Docker (for serena-docker)
- uvx (for serena standard)
- API keys (for Magic, Morphllm, Tavily)

## Troubleshooting

### MCP Server Not Working

Check server status:
```bash
claude mcp status
```

Verify environment variables are set:
```bash
echo $TAVILY_API_KEY
echo $TWENTYFIRST_API_KEY
echo $MORPH_API_KEY
```

### Commands Not Found

Verify plugin installation:
```bash
claude plugin list
```

Reinstall if needed:
```bash
claude plugin install superclaude-framework
```

### Core Framework Not Loading

Verify plugin root is set correctly:
```bash
echo $CLAUDE_PLUGIN_ROOT
```

Test command manually:
```bash
cat "${CLAUDE_PLUGIN_ROOT}/core/FLAGS.md"
```

## Contributing

Contributions welcome! Please see the main SuperClaude Framework repository:
https://github.com/SuperClaude-Org/SuperClaude_Framework

## License

See upstream SuperClaude Framework license.

## Links

- **Upstream Repository**: https://github.com/SuperClaude-Org/SuperClaude_Framework
- **Documentation**: See `/docs` directory in upstream repository
- **Issue Tracker**: https://github.com/SuperClaude-Org/SuperClaude_Framework/issues

## Version

Plugin Version: 4.1.5
SuperClaude Framework Version: 4.1.5

Last Updated: 2025-10-13
