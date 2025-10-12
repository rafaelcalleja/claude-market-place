# Claude Code Plugin Marketplace Example

**Complete working plugin marketplace with comprehensive research and documentation**

---

## Overview

This repository serves dual purposes:

1. **Working Plugin Marketplace** - A production-ready marketplace with four fully-functional example plugins
2. **Comprehensive Research** - Complete documentation on Claude Code's plugin system

Everything you need to use, create, distribute, and manage Claude Code plugins.

**Created:** 2025-10-11
**Sources:** Official Anthropic documentation and https://github.com/anthropics/claude-code

---

## Quick Start - Use This Marketplace

### Install the Marketplace

```bash
# If using locally
/plugin marketplace add /home/rcalleja/projects/claude-market-place

# If hosted on GitHub (after publishing)
/plugin marketplace add your-username/claude-market-place
```

### Install the Plugins

```bash
# Interactive menu
/plugin

# Or install directly
/plugin install productivity-commands@example-marketplace
/plugin install code-analysis-agents@example-marketplace
/plugin install auto-formatter@example-marketplace
/plugin install fabric-helper@example-marketplace
```

---

## Included Plugins

### 1. Productivity Commands
**Slash commands for common development workflows**

- `/quick-test` - Auto-detect and run project tests
- `/analyze-deps` - Check dependencies for vulnerabilities
- `/project-stats` - Generate comprehensive project statistics

[View documentation →](plugins/productivity-commands/README.md)

### 2. Code Analysis Agents
**Specialized agents for code review and optimization**

- `security-auditor` - Security vulnerability assessment
- `performance-optimizer` - Performance bottleneck identification
- `architecture-reviewer` - Architecture and design review

[View documentation →](plugins/code-analysis-agents/README.md)

### 3. Auto-Formatter
**Automatic code formatting after file edits**

- Formats JS/TS, Python, Go, Rust, JSON automatically
- Safety warnings before destructive operations
- Session notifications

[View documentation →](plugins/auto-formatter/README.md)

### 4. Fabric Helper
**Fabric AI system integration with pattern suggestion and execution**

- `/suggest` - Intelligent pattern recommendation based on semantic analysis
- `/exec` - Execute specific Fabric patterns with high-quality analysis
- `/orchestrate` - Chain multiple patterns into automated workflows
- 200+ pre-built patterns for code analysis, security, documentation, and more

[View documentation →](plugins/fabric-helper/README.md)

---

## Documentation Included

This repository provides five essential documents:

### 1. [RESEARCH_REPORT.md](./RESEARCH_REPORT.md) - Complete Technical Documentation
**~50 pages of detailed specifications**

- Complete marketplace and plugin schemas
- All component types (commands, agents, hooks, MCP servers)
- Working examples from Anthropic's official repository
- Field-by-field documentation
- Best practices and guidelines
- Distribution strategies
- Debugging and validation techniques

**Use this when:** You need detailed technical specifications or want to understand every aspect of the plugin system.

### 2. [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) - One-Page Cheat Sheet
**Everything you need on one page**

- 3-step marketplace setup
- 3-step plugin setup
- Essential commands
- File location reference
- Minimal working example
- Component templates
- Common troubleshooting

**Use this when:** You want to quickly look up syntax, commands, or create something fast.

### 3. [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md) - Step-by-Step Tutorial
**Guided walkthrough from zero to production marketplace**

- Phase-by-phase implementation
- Hands-on exercises with exact commands
- Building from minimal to full-featured
- Testing and validation at each step
- GitHub publication guide
- Troubleshooting for each phase

**Use this when:** You're creating your first marketplace or want a structured learning path.

### 4. [SUMMARY.md](./SUMMARY.md) - Research Overview

### 5. This README - Marketplace overview and navigation guide

---

## Repository Structure

```
claude-market-place/
├── .claude-plugin/
│   └── marketplace.json              # Marketplace configuration
├── plugins/
│   ├── productivity-commands/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── commands/
│   │   │   ├── quick-test.md
│   │   │   ├── analyze-deps.md
│   │   │   └── project-stats.md
│   │   └── README.md
│   ├── code-analysis-agents/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── agents/
│   │   │   ├── security-auditor.md
│   │   │   ├── performance-optimizer.md
│   │   │   └── architecture-reviewer.md
│   │   └── README.md
│   ├── auto-formatter/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── hooks/
│   │   │   └── hooks.json
│   │   ├── scripts/
│   │   │   └── format-file.sh
│   │   └── README.md
│   └── fabric-helper/
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── commands/
│       │   ├── suggest.md
│       │   ├── orchestrate.md
│       │   └── exec.md
│       ├── agents/
│       │   ├── pattern-suggester.md
│       │   └── pattern-executor.md
│       ├── .fabric-core/
│       │   ├── pattern_descriptions.json
│       │   └── pattern_extracts.json
│       ├── README.md
│       └── LICENSE
├── README.md                         # This file
├── QUICK_REFERENCE.md               # One-page cheat sheet
├── RESEARCH_REPORT.md               # Complete specifications
├── IMPLEMENTATION_GUIDE.md          # Step-by-step tutorial
└── SUMMARY.md                       # Research findings
```

---

## Quick Start Paths

Choose your path based on your goal:

### Path A: "I want to use these plugins"
1. Install this marketplace (see Quick Start above)
2. Install the plugins you want
3. Start using commands and agents!

### Path B: "I want to build my own marketplace"
1. Read [QUICK_REFERENCE.md](./QUICK_REFERENCE.md)
2. Copy the "Minimal Working Example"
3. Modify to your needs
4. Done in 5 minutes!

### Path C: "I want to understand everything first"
1. Read [RESEARCH_REPORT.md](./RESEARCH_REPORT.md)
2. Review official examples at https://github.com/anthropics/claude-code
3. Follow [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md) to practice
4. Comprehensive understanding achieved!

### Path D: "I want guided hands-on learning"
1. Start with [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md)
2. Follow each phase step-by-step
3. Reference [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) for syntax
4. Check [RESEARCH_REPORT.md](./RESEARCH_REPORT.md) for details
5. Build working marketplace with full understanding!

### Path E: "I just need to look something up"
1. Open [QUICK_REFERENCE.md](./QUICK_REFERENCE.md)
2. Find what you need
3. Back to work!

---

## Key Concepts (2-Minute Overview)

### What is a Plugin Marketplace?

A **plugin marketplace** is a catalog of plugins that can be installed into Claude Code. It's just a Git repository with a special JSON file.

**Required file:** `.claude-plugin/marketplace.json`

### What is a Plugin?

A **plugin** is a bundle of customizations (commands, agents, hooks, MCP servers) that extends Claude Code's capabilities.

**Required file:** `.claude-plugin/plugin.json`

### Plugin Components

Plugins can contain any combination of:

1. **Commands** - Custom slash commands (e.g., `/deploy`, `/test`)
2. **Agents** - Specialized AI personas for specific tasks
3. **Hooks** - Automation triggers for events
4. **MCP Servers** - External tool integrations

### Installation Flow

```
1. Create marketplace with plugins
2. Add marketplace to Claude Code: /plugin marketplace add owner/repo
3. Install plugin: /plugin install plugin-name@marketplace
4. Use features: /command or ask for agent help
```

---

## Minimal Working Example

**Complete working marketplace in 30 seconds:**

```bash
# Create structure
mkdir -p my-marketplace/.claude-plugin
mkdir -p my-marketplace/plugins/hello/.claude-plugin
mkdir -p my-marketplace/plugins/hello/commands

# Create marketplace.json
cat > my-marketplace/.claude-plugin/marketplace.json << 'EOF'
{
  "name": "my-marketplace",
  "owner": {"name": "Me"},
  "plugins": [{
    "name": "hello",
    "description": "Simple greeting",
    "source": "./plugins/hello"
  }]
}
EOF

# Create plugin.json
cat > my-marketplace/plugins/hello/.claude-plugin/plugin.json << 'EOF'
{
  "name": "hello",
  "version": "1.0.0",
  "description": "Greeting plugin"
}
EOF

# Create command
cat > my-marketplace/plugins/hello/commands/greet.md << 'EOF'
---
description: Greet the user
---
Greet the user warmly and offer your help.
EOF

# Test it
cd /your/project
claude
/plugin marketplace add /full/path/to/my-marketplace
/plugin install hello@my-marketplace
# Restart Claude Code
/greet
```

**Done!** You now have a working plugin marketplace with a custom command.

---

## Official Resources

### Documentation
- **Plugin Guide:** https://docs.claude.com/en/docs/claude-code/plugins
- **Plugin Reference:** https://docs.claude.com/en/docs/claude-code/plugins-reference
- **Marketplace Guide:** https://docs.claude.com/en/docs/claude-code/plugin-marketplaces
- **Announcement Post:** https://www.anthropic.com/news/claude-code-plugins

### Examples
- **Anthropic Repository:** https://github.com/anthropics/claude-code
- **Official Plugins:** https://github.com/anthropics/claude-code/tree/main/plugins
- **Marketplace Example:** https://github.com/anthropics/claude-code/blob/main/.claude-plugin/marketplace.json

### Community
- **Claude Developers Discord:** https://anthropic.com/discord
- **Dan Ávila's Plugins:** https://www.aitmpl.com/plugins
- **Seth Hobson's Agents:** https://github.com/wshobson/agents

---

## File Reference

### Marketplace Structure
```
marketplace-repo/
├── .claude-plugin/
│   └── marketplace.json     ← REQUIRED: Lists all plugins
└── plugins/
    └── plugin-name/
        ├── .claude-plugin/
        │   └── plugin.json  ← REQUIRED: Plugin metadata
        ├── commands/        ← Optional: Slash commands
        ├── agents/          ← Optional: AI agents
        ├── hooks/           ← Optional: Event hooks
        └── .mcp.json       ← Optional: MCP servers
```

### Critical Rules

1. **Marketplace file location:** `.claude-plugin/marketplace.json` at repository root
2. **Plugin file location:** `.claude-plugin/plugin.json` at plugin root
3. **Component directories:** `commands/`, `agents/`, `hooks/` at plugin root (NOT inside `.claude-plugin/`)
4. **Path variable:** Always use `${CLAUDE_PLUGIN_ROOT}` in hooks and MCP configs
5. **Naming:** Use kebab-case (lowercase with hyphens, no spaces)

---

## Common Commands

```bash
# Marketplace management
/plugin marketplace add owner/repo              # Add from GitHub
/plugin marketplace add ./path                  # Add local
/plugin marketplace list                        # List all
/plugin marketplace update name                 # Update
/plugin marketplace remove name                 # Remove

# Plugin management
/plugin                                         # Interactive menu
/plugin install name@marketplace                # Install
/plugin enable name@marketplace                 # Enable
/plugin disable name@marketplace                # Disable
/plugin uninstall name@marketplace              # Uninstall

# Debugging
claude --debug                                  # Debug mode
claude plugin validate .                        # Validate JSON
```

---

## Examples from Anthropic

The official repository includes 5 production-ready plugin examples:

1. **agent-sdk-dev** - Development tools for Claude Agent SDK
2. **pr-review-toolkit** - 6 specialized PR review agents
3. **commit-commands** - Git workflow commands
4. **feature-dev** - Feature development workflow
5. **security-guidance** - Security warning hooks

Each demonstrates different plugin capabilities and best practices.

---

## Distribution Strategies

### Strategy 1: GitHub (Recommended)
- Host marketplace as public GitHub repository
- Users install with: `/plugin marketplace add owner/repo`
- Benefits: Version control, issues, collaboration

### Strategy 2: Private Git
- Host on GitLab, Bitbucket, or internal Git server
- Users install with full Git URL
- Benefits: Privacy, corporate control

### Strategy 3: Local Development
- Keep marketplace in local directory
- Install with local path
- Benefits: Fast iteration, testing

### Strategy 4: Team Auto-Install
- Configure in project's `.claude/settings.json`
- Automatically installs when developers trust folder
- Benefits: Consistency, onboarding

---

## Use Cases

### For Individuals
- Personal productivity commands
- Favorite workflows automation
- Learning and experimentation

### For Teams
- Standardized code review processes
- Deployment and CI/CD commands
- Team-specific agents and helpers

### For Organizations
- Company-wide tooling distribution
- Internal API integrations
- Compliance and security enforcement

### For Open Source
- Framework-specific helpers
- Language-specific tools
- Community best practices

---

## Advanced Topics

See [RESEARCH_REPORT.md](./RESEARCH_REPORT.md) for details on:

- Hook event types and matchers
- MCP server configuration
- Environment variables
- Path resolution rules
- Inline vs. external configurations
- Component path customization
- Marketplace versioning
- Plugin dependencies
- Security considerations

---

## Getting Help

1. **Quick syntax question?** → [QUICK_REFERENCE.md](./QUICK_REFERENCE.md)
2. **How do I build X?** → [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md)
3. **What does this field do?** → [RESEARCH_REPORT.md](./RESEARCH_REPORT.md)
4. **Is this a bug?** → Check official docs or Discord
5. **Need examples?** → https://github.com/anthropics/claude-code/tree/main/plugins

---

## Contributing

This research is based on publicly available documentation and examples. Feel free to:

- Add your own notes and findings
- Create example plugins
- Share successful patterns
- Report documentation issues

---

## Next Steps

Ready to start? Choose your path:

- **Quick start:** Copy example from [QUICK_REFERENCE.md](./QUICK_REFERENCE.md)
- **Learn by doing:** Follow [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md)
- **Deep dive:** Read [RESEARCH_REPORT.md](./RESEARCH_REPORT.md)

**Happy plugin development!**

---

## Adding Your Own Plugins

Want to add a plugin to this marketplace?

1. Create plugin directory in `plugins/your-plugin-name/`
2. Add `.claude-plugin/plugin.json` and components
3. Update `.claude-plugin/marketplace.json`
4. Test locally: `/plugin marketplace add ./claude-market-place`
5. Commit and push

See [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md) for detailed instructions.

---

## Publishing to GitHub

To share this marketplace:

```bash
# Initialize git (if not already)
git init
git add .
git commit -m "Initial marketplace with example plugins"

# Create GitHub repo and push
git remote add origin https://github.com/your-username/claude-market-place.git
git branch -M main
git push -u origin main
```

Users can then install with:
```
/plugin marketplace add your-username/claude-market-place
```

---

## License

MIT License - Individual plugins may have different licenses. See plugin directories for details.

**Created by:** Claude Code
**Date:** 2025-10-11
**Version:** 1.0.0
