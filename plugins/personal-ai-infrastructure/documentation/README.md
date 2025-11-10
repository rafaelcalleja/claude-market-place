# PAI System Documentation

Welcome to the Personal AI Infrastructure (PAI) documentation. PAI is a comprehensive system for integrating AI assistants into your personal workflow with advanced context management, automation, and extensibility.

## 📚 Documentation Index

### 🚀 New to PAI? Start Here!

> **👉 [Getting Started Guide](./how-to-start.md)** - Complete setup guide with automated option
>
> **👉 [Quick Reference](./QUICK-REFERENCE.md)** - Bookmark this for daily commands

### Getting Started
- **[How to Start Guide](./how-to-start.md)** - Complete setup with step-by-step instructions
- [Quick Reference](./QUICK-REFERENCE.md) - Common commands and troubleshooting
- [Installation Guide](./installation.md) - Detailed installation instructions (optional)
- [Configuration Guide](./configuration.md) - System configuration options (optional)

### Core Concepts
- [System Architecture](./architecture.md) - Overview of PAI components
- [Skills System](./skills-system.md) - Modular capability packages with progressive disclosure
- [Hook System](./hook-system.md) - Event-driven automation
- [Agent System](./agent-system.md) - Specialized AI agents

### Components
- [Voice Server](../voice-server/README.md) - Voice notification system
- [Context Management](./context-management.md) - Dynamic context loading
- [Command System](./command-system.md) - Custom commands and scripts

### Development
- [API Reference](./api-reference.md) - HTTP APIs and interfaces
- [Security Guide](./security.md) - Security best practices
- [Contributing](./contributing.md) - How to contribute to PAI

## 🚀 What is PAI?

PAI (Personal AI Infrastructure) is a powerful framework that enhances AI assistants with:

- **Skills System**: Modular capability packages activated by intent
- **Progressive Disclosure**: Load information as needed (SKILL.md → CLAUDE.md → Resources)
- **Hook System**: Event-driven automation for tool calls
- **Voice Notifications**: macOS native voice feedback with distinct agent voices
- **Multi-Agent Architecture**: Specialized agents for different tasks
- **Security First**: Built with security best practices

## 🎯 Key Features

### 1. Skills Intelligence
- Intent-based skill activation
- Progressive information disclosure
- Modular capability packages
- Dynamic agent selection

### 2. Automation
- Pre and post-execution hooks
- Custom command integration
- Workflow automation
- Event-driven responses

### 3. Voice Integration
- macOS native Premium/Enhanced voices
- Zero API costs (100% offline)
- Distinct voices for Kai and each agent
- Real-time completion notifications

### 4. Security
- Input validation and sanitization
- Rate limiting
- CORS protection
- No hardcoded secrets

## 🏗️ System Components

```
PAI/
├── PAI_DIRECTORY/          # PAI system configuration
│   ├── skills/             # Modular capability packages
│   ├── hooks/              # Event hooks
│   ├── commands/           # Custom slash commands
│   ├── agents/             # Specialized AI agents
│   └── voice-server/       # Voice notification server
├── Documentation/          # System documentation
├── Projects/               # User projects
└── Library/               # System libraries and logs
```

## 🔧 Environment Variables

PAI uses environment variables for configuration:

- `PAI_DIR`: PAI configuration directory (points to PAI_DIRECTORY)
- `PAI_HOME`: Your home directory
- `PORT`: Voice server port (default: 8888)
- `DA`: Digital Assistant name (optional)
- `DA_COLOR`: Display color (optional)

## 📖 Quick Links

- [System Requirements](#system-requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage Examples](#usage-examples)
- [Troubleshooting](#troubleshooting)

## System Requirements

- macOS 11+ (primary support)
- Bun runtime
- AI assistant access (Claude, GPT, Gemini, etc.)
- Optional: ElevenLabs API key
- Optional: SwiftBar for menu indicators

## Installation

```bash
# Clone PAI repository
git clone https://github.com/yourusername/PAI.git
cd PAI

# Set PAI_DIR
export PAI_DIR="$HOME/PAI/PAI_DIRECTORY"

# Install voice server (optional)
cd PAI_DIRECTORY/voice-server
./install.sh

# Configure environment
cp ${PAI_DIR}/env-example ${PAI_DIR}/.env
# Edit ${PAI_DIR}/.env with your settings
```

## Configuration

PAI is configured through:
1. Environment variables in `${PAI_DIR}/.env`
2. Skills in `${PAI_DIR}/skills/`
3. Hook scripts in `${PAI_DIR}/hooks/`
4. Agent definitions in `${PAI_DIR}/agents/`
5. Slash commands in `${PAI_DIR}/commands/`

## Usage Examples

### Skill Activation
```bash
# Skills activate based on intent matching
"Help me with prompt engineering" → Activates prompting skill
"Create a new skill for X" → Activates create-skill
"Do research on AI trends" → Activates research skill (launches agents)
```

### Voice Notifications
```bash
# Send voice notification
curl -X POST http://localhost:8888/notify \
  -d '{"message": "Task completed"}'
```

### Hook System
```yaml
# ${PAI_DIR}/hooks/user-prompt-submit.sh
# Automatically loads context before processing prompts
```

## Troubleshooting

Common issues and solutions:

| Issue | Solution |
|-------|----------|
| Skill not activating | Check skill description in `<available_skills>` |
| Voice not working | Verify voice server running: `curl http://localhost:8888/health` |
| Hooks not triggering | Ensure hook scripts are executable |
| Port conflicts | Change PORT in `${PAI_DIR}/.env` |

## Contributing

PAI is open for contributions. See [Contributing Guide](./contributing.md) for:
- Code style guidelines
- Pull request process
- Issue reporting
- Feature requests

## Support

- GitHub Issues: Report bugs and request features
- Documentation: This directory contains all documentation
- Community: Join discussions in the repository

## License

PAI is part of the Personal AI Infrastructure project.

---

*Last updated: [Current Date]*
*Version: 1.0.0*