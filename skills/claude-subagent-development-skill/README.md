# Claude Code Subagent Development Skill

Comprehensive skill for creating, validating, and documenting Claude Code subagents with schemas and protocol specifications.

## Purpose

This skill provides structured workflows and tools for developing production-ready Claude Code subagents. It includes:

- Complete protocol specification
- JSON schema for validation
- Validation and creation scripts
- Production-ready examples
- Detailed field reference
- Advanced best practices

## Structure

```
claude-subagent-development-skill/
├── SKILL.md                          # Main skill file (~2,000 words)
├── references/                       # Detailed documentation
│   ├── protocol-specification.md    # Complete protocol (20,000+ words)
│   ├── field-reference.md           # Detailed field reference (8,000+ words)
│   └── best-practices.md            # Advanced patterns (7,000+ words)
├── examples/                         # Production-ready subagents
│   ├── code-reviewer.md             # Code review specialist
│   ├── debugger.md                  # Debugging expert
│   └── test-runner.md               # Test automation
├── scripts/                          # Utility scripts
│   ├── validate-subagent.sh         # Validate subagent config
│   └── create-subagent.sh           # Create from template
├── assets/                           # Templates and schemas
│   ├── subagent-schema.json         # JSON Schema for validation
│   └── template.md                  # Base template
└── README.md                         # This file
```

## When to Use

This skill triggers when user asks to:
- "create a subagent"
- "validate a subagent"
- "generate subagent schema"
- "check subagent configuration"
- "write subagent specification"
- Or mentions subagent development, validation, or documentation

## Quick Start

### Create a New Subagent

```bash
scripts/create-subagent.sh my-subagent project
```

This creates `.claude/agents/my-subagent.md` from template.

### Validate a Subagent

```bash
scripts/validate-subagent.sh .claude/agents/my-subagent.md
```

Add `--check-tools` to also validate tool names:

```bash
scripts/validate-subagent.sh .claude/agents/my-subagent.md --check-tools
```

### Use an Example

Copy one of the production-ready examples:

```bash
cp examples/code-reviewer.md .claude/agents/
```

## Key Features

### 1. Progressive Disclosure

- **SKILL.md**: Core concepts and workflows (~2,000 words)
- **References**: Detailed documentation loaded as needed
- **Examples**: Copy-paste ready subagents
- **Scripts**: Automation utilities

### 2. Complete Protocol Spec

`references/protocol-specification.md` includes:
- Architecture and data flow diagrams
- File format specification
- All configuration fields
- Lifecycle management
- Security considerations
- Built-in subagents reference

### 3. Field Reference

`references/field-reference.md` provides:
- Every field explained in detail
- Valid/invalid examples
- Common mistakes
- Best practices
- Validation rules

### 4. Validation Tools

**JSON Schema** (`assets/subagent-schema.json`):
```bash
# With ajv-cli
ajv validate -s assets/subagent-schema.json -d subagent.json

# With Python
python -c "import json, jsonschema; \
  jsonschema.validate( \
    json.load(open('subagent.json')), \
    json.load(open('assets/subagent-schema.json')))"
```

**Bash Script** (`scripts/validate-subagent.sh`):
- YAML frontmatter validation
- Required fields check
- Name pattern validation
- Model alias validation
- Tool names verification
- Description quality checks

### 5. Creation Script

`scripts/create-subagent.sh` scaffolds:
- Proper file structure
- Valid YAML frontmatter
- Template system prompt
- Correct file location

## Usage Examples

### Creating a Code Reviewer

```bash
# Create from scratch
scripts/create-subagent.sh code-reviewer project

# Or copy example
cp examples/code-reviewer.md .claude/agents/

# Validate
scripts/validate-subagent.sh .claude/agents/code-reviewer.md --check-tools
```

### Generating Documentation

The protocol specification can be extracted for documentation:

```bash
# Full spec
cp references/protocol-specification.md docs/subagent-protocol.md

# Just field reference
cp references/field-reference.md docs/subagent-fields.md
```

### Custom Validation

Use JSON schema programmatically:

```python
import json
import jsonschema

# Load schema
with open('assets/subagent-schema.json') as f:
    schema = json.load(f)

# Validate subagent
with open('my-subagent.json') as f:
    subagent = json.load(f)

try:
    jsonschema.validate(subagent, schema)
    print("Valid!")
except jsonschema.ValidationError as e:
    print(f"Invalid: {e.message}")
```

## File Contents

### SKILL.md (Main Skill)

Lean, focused content:
- Core concepts
- Workflows (create, validate, document)
- Tools and resources
- Quick reference
- Troubleshooting basics

### References (Detailed Docs)

**protocol-specification.md**:
- Complete protocol definition
- Architecture diagrams
- All configuration options
- Security model
- Examples

**field-reference.md**:
- Every field detailed
- Validation rules
- Examples (good/bad)
- Common patterns
- Troubleshooting

**best-practices.md**:
- Design principles
- Advanced patterns
- Team collaboration
- Testing strategies
- Performance optimization

### Examples (Working Subagents)

**code-reviewer.md**:
- Security, quality, performance checks
- Structured feedback format
- Git integration

**debugger.md**:
- Root cause analysis
- Systematic debugging
- Common issue patterns

**test-runner.md**:
- Test framework detection
- Failure analysis
- Fast execution (Haiku model)

### Scripts (Automation)

**validate-subagent.sh**:
- YAML syntax check
- Field validation
- Pattern matching
- Tool verification

**create-subagent.sh**:
- Template instantiation
- Directory creation
- Interactive setup

### Assets (Templates/Schemas)

**subagent-schema.json**:
- JSON Schema Draft 07
- Complete field definitions
- Validation constraints
- Examples

**template.md**:
- Base subagent structure
- Placeholder content
- Best practice hints

## Validation Details

The validation script checks:

✓ YAML frontmatter exists and is valid
✓ Required fields present (`name`, `description`)
✓ Name pattern: `^[a-z0-9-]+$`
✓ Description length: 10-2000 characters
✓ Model alias valid: `sonnet|opus|haiku|inherit`
✓ Permission mode valid
✓ Tools format correct
✓ Content present below frontmatter
✓ No common mistakes (uppercase, underscores, spaces in name)

Optional checks with `--check-tools`:
✓ Tool names valid
✓ MCP tools recognized

## Best Practices Demonstrated

### 1. Strong Trigger Description

```yaml
description: This skill should be used when the user asks to "create a subagent", "validate a subagent", "generate subagent schema", or mentions subagent development.
```

### 2. Imperative Writing Style

All content uses imperative/infinitive form:
- "Create a new subagent" (not "You should create")
- "Validate configuration" (not "You need to validate")
- "Use the validation script" (not "You can use")

### 3. Progressive Disclosure

- SKILL.md: ~2,000 words (core essentials)
- References: ~35,000 words (loaded as needed)
- Ratio: 1:17 (main:detailed)

### 4. Clear Resource References

SKILL.md explicitly references:
- `references/protocol-specification.md`
- `references/field-reference.md`
- `references/best-practices.md`
- `examples/*.md`
- `scripts/*.sh`
- `assets/*.json`

### 5. Working Examples

All examples are:
- Complete and runnable
- Production-ready
- Well-documented
- Demonstrating different patterns

## Integration

### As a Plugin Skill

To include in a Claude Code plugin:

```
my-plugin/
└── skills/
    └── claude-subagent-development/
        ├── SKILL.md
        ├── references/
        ├── examples/
        ├── scripts/
        └── assets/
```

### Standalone Usage

Can be used directly:

```bash
# Clone or copy skill directory
cp -r claude-subagent-development-skill ~/.claude/skills/

# Restart Claude Code to load
claude
```

## Version

**1.0.0** (2025-12-03)

Initial release with:
- Complete protocol specification
- JSON schema validation
- Bash validation script
- Creation automation
- 3 production examples
- Comprehensive references

## License

Part of Claude Code ecosystem. See Claude Code documentation license.

## See Also

- [Claude Code Subagents Documentation](https://code.claude.com/docs/en/sub-agents)
- [Claude Code Agent Skills](https://code.claude.com/docs/en/skills)
- [Model Context Protocol](https://modelcontextprotocol.io/)
