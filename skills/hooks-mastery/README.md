# Hooks Mastery Skill

A comprehensive Claude Code skill for creating, configuring, and validating hooks following the official protocol specification.

## Overview

This skill provides everything needed to master Claude Code hooks:
- Complete protocol specification
- Detailed event reference
- JSON schema for validation
- Working examples with explanations
- Validation and testing scripts
- Template generators

## Skill Structure

```
hooks-mastery/
├── SKILL.md                          # Main skill file (loaded when triggered)
├── README.md                         # This file
│
├── references/                       # Detailed documentation (loaded as needed)
│   ├── protocol-specification.md    # Complete hooks protocol spec
│   └── event-reference.md           # Detailed event documentation
│
├── scripts/                          # Utility scripts
│   ├── validate-hook-config.py      # Validate hooks.json against schema
│   ├── test-hook-io.py              # Test hooks locally
│   └── generate-hook-template.sh    # Generate hook boilerplate
│
├── examples/                         # Working examples
│   ├── pretooluse-validator/        # Bash command validator
│   ├── userprompt-enricher/         # Context injection
│   ├── sessionstart-setup/          # Environment setup
│   └── stop-evaluator/              # Prompt-based Stop hook
│
└── assets/                           # Supporting files
    └── hooks-schema.json             # JSON schema for validation
```

## Quick Start

### 1. Use the Skill

The skill is automatically loaded when you ask Claude Code about hooks:
- "Create a PreToolUse hook"
- "Configure a SessionStart hook"
- "Validate my hooks configuration"
- "Add a bash command validator"

### 2. Generate a Hook Template

```bash
# Generate Python hook
./scripts/generate-hook-template.sh PreToolUse validator.py --language python

# Generate Bash hook
./scripts/generate-hook-template.sh SessionStart setup.sh --language bash
```

### 3. Test Your Hook Locally

```bash
# Test with sample input
./scripts/test-hook-io.py validator.py PreToolUse

# Test with custom command
./scripts/test-hook-io.py validator.py PreToolUse --command "rm -rf /"
```

### 4. Validate Configuration

```bash
# Validate hooks in settings file
./scripts/validate-hook-config.py ~/.claude/settings.json

# Validate project settings
./scripts/validate-hook-config.py .claude/settings.json
```

## Examples

### PreToolUse: Bash Command Validator

Blocks dangerous bash commands before execution:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/validator.py",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

See `examples/pretooluse-validator/` for complete implementation.

### UserPromptSubmit: Context Enricher

Adds git status and environment info to every prompt:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/enricher.py",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

See `examples/userprompt-enricher/` for complete implementation.

### SessionStart: Environment Setup

Activates Node/Python environments and persists variables:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/setup.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

See `examples/sessionstart-setup/` for complete implementation.

### Stop: Prompt-Based Evaluator

Uses LLM to decide if Claude should continue:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Context: $ARGUMENTS\n\nCheck if all tasks complete...\n\nRespond: {\"decision\": \"approve\" or \"block\", \"reason\": \"explanation\"}"
          }
        ]
      }
    ]
  }
}
```

See `examples/stop-evaluator/` for complete details.

## Documentation

### References

- **`references/protocol-specification.md`** - Complete hooks protocol specification v1.0
- **`references/event-reference.md`** - Detailed documentation for all hook events

### Events Coverage

| Event | Description | Example Use Case |
|-------|-------------|------------------|
| PreToolUse | Before tool execution | Validate bash commands |
| PermissionRequest | Permission dialog | Auto-approve safe operations |
| PostToolUse | After tool execution | Auto-format code |
| UserPromptSubmit | Before prompt processing | Add git context |
| Stop/SubagentStop | Agent finishing | Verify tasks complete |
| SessionStart | Session start | Setup environment |
| SessionEnd | Session end | Cleanup |
| Notification | Notifications sent | Desktop alerts |
| PreCompact | Before compact | Backup conversation |

## Tools and Scripts

### validate-hook-config.py

Validates hooks configuration against JSON schema:

```bash
python3 scripts/validate-hook-config.py ~/.claude/settings.json
```

Features:
- Schema validation
- Command safety checks
- Matcher validation
- Detailed error reporting

### test-hook-io.py

Test hooks locally without running Claude Code:

```bash
python3 scripts/test-hook-io.py <script> <event> [options]
```

Features:
- Sample inputs for all events
- Exit code interpretation
- JSON output parsing
- Custom input support

### generate-hook-template.sh

Generate hook boilerplate:

```bash
./scripts/generate-hook-template.sh <event> <output> --language <python|bash>
```

Features:
- Python and Bash templates
- Event-specific structure
- Best practices included
- Executable permissions set

## JSON Schema

The skill includes a complete JSON schema (`assets/hooks-schema.json`) for validating hooks configuration. Use with any JSON schema validator or the included validation script.

## Best Practices

### 1. Security
- Always validate inputs
- Quote shell variables
- Block path traversal
- Skip sensitive files

### 2. Performance
- Keep hooks fast (<100ms for command, <2s for prompt)
- Run in parallel when possible
- Use appropriate timeouts
- Cache expensive operations

### 3. Testing
- Test locally before deploying
- Use sample inputs
- Verify exit codes
- Check JSON output

### 4. Maintainability
- Use `$CLAUDE_PROJECT_DIR` for paths
- Document hook purpose
- Keep logic simple
- Handle errors gracefully

## Contributing

To add new examples or improve documentation:

1. Follow existing structure
2. Include README with examples
3. Test thoroughly
4. Document edge cases

## License

This skill is part of the Claude Code ecosystem and follows Anthropic's licensing terms.

## Version

**Skill Version**: 1.0.0
**Protocol Version**: 1.0
**Last Updated**: 2025

## Support

For questions or issues:
- Review `references/protocol-specification.md` for protocol details
- Check `examples/` for working implementations
- Use validation scripts to identify configuration issues
- Consult official Claude Code documentation
