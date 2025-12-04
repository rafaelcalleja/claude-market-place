# Hooks Mastery Skill - Installation Guide

## Quick Install

### Option 1: Copy to User Skills (Recommended)

Make the skill available across all your projects:

```bash
# Create skills directory if it doesn't exist
mkdir -p ~/.claude/skills

# Copy the skill
cp -r hooks-mastery ~/.claude/skills/

# Verify installation
ls ~/.claude/skills/hooks-mastery/SKILL.md
```

### Option 2: Copy to Project Skills

Make the skill available only in the current project:

```bash
# From your project root
mkdir -p .claude/skills

# Copy the skill
cp -r /path/to/hooks-mastery .claude/skills/

# Verify installation
ls .claude/skills/hooks-mastery/SKILL.md
```

## Verify Installation

Test that the skill loads properly:

```bash
# Start Claude Code
claude

# Ask Claude about hooks (this should load the skill)
> "Help me create a PreToolUse hook"

# Claude should respond with hooks-mastery skill content
```

## Using the Scripts

The skill includes three utility scripts that you can use directly:

### 1. Validate Hook Configuration

```bash
# Validate user settings
~/.claude/skills/hooks-mastery/scripts/validate-hook-config.py ~/.claude/settings.json

# Validate project settings
~/.claude/skills/hooks-mastery/scripts/validate-hook-config.py .claude/settings.json
```

### 2. Test Hooks Locally

```bash
# Navigate to script directory
cd ~/.claude/skills/hooks-mastery/scripts

# Test a hook
./test-hook-io.py /path/to/your-hook.py PreToolUse

# Test with custom command
./test-hook-io.py /path/to/your-hook.py PreToolUse --command "echo test"
```

### 3. Generate Hook Templates

```bash
# Navigate to script directory
cd ~/.claude/skills/hooks-mastery/scripts

# Generate Python hook
./generate-hook-template.sh PreToolUse validator.py --language python

# Generate Bash hook
./generate-hook-template.sh SessionStart setup.sh --language bash
```

## Using the Examples

The skill includes four complete working examples:

### 1. PreToolUse Validator

```bash
# Copy to your project
cp -r ~/.claude/skills/hooks-mastery/examples/pretooluse-validator .claude/hooks/

# Test it
cd .claude/hooks/pretooluse-validator
python3 validator.py < test-input.json

# Add to settings.json
```

### 2. UserPromptSubmit Enricher

```bash
# Copy to your project
cp -r ~/.claude/skills/hooks-mastery/examples/userprompt-enricher .claude/hooks/

# Test it
cd .claude/hooks/userprompt-enricher
python3 enricher.py < test-input.json
```

### 3. SessionStart Setup

```bash
# Copy to your project
cp -r ~/.claude/skills/hooks-mastery/examples/sessionstart-setup .claude/hooks/

# Test it
cd .claude/hooks/sessionstart-setup
bash setup.sh < test-input.json
```

### 4. Stop Evaluator (No Files Needed)

This example uses only configuration - no files to copy. Just add the JSON configuration to your settings.

## Adding Scripts to PATH (Optional)

To use the scripts from anywhere:

```bash
# Add to your shell profile (~/.bashrc, ~/.zshrc, etc.)
export PATH="$HOME/.claude/skills/hooks-mastery/scripts:$PATH"

# Reload shell
source ~/.bashrc  # or ~/.zshrc

# Now you can run from anywhere
validate-hook-config.py ~/.claude/settings.json
test-hook-io.py hook.py PreToolUse
generate-hook-template.sh Stop checker.py
```

## Accessing Documentation

All documentation is accessible within the skill directory:

```bash
# View protocol specification
less ~/.claude/skills/hooks-mastery/references/protocol-specification.md

# View event reference
less ~/.claude/skills/hooks-mastery/references/event-reference.md

# View example READMEs
less ~/.claude/skills/hooks-mastery/examples/pretooluse-validator/README.md
```

Or ask Claude to reference these files:

```
> "Show me the protocol specification for hooks"
> "Explain the PreToolUse event"
> "How do I use the validator example?"
```

## Troubleshooting

### Skill Not Loading

If Claude doesn't recognize hooks questions:

1. **Check skill location:**
   ```bash
   ls ~/.claude/skills/hooks-mastery/SKILL.md
   ```

2. **Verify frontmatter:**
   ```bash
   head -10 ~/.claude/skills/hooks-mastery/SKILL.md
   ```

3. **Check permissions:**
   ```bash
   chmod -R +r ~/.claude/skills/hooks-mastery
   ```

### Scripts Not Executable

If you get permission errors:

```bash
# Make scripts executable
chmod +x ~/.claude/skills/hooks-mastery/scripts/*.py
chmod +x ~/.claude/skills/hooks-mastery/scripts/*.sh
chmod +x ~/.claude/skills/hooks-mastery/examples/*/*.py
chmod +x ~/.claude/skills/hooks-mastery/examples/*/*.sh
```

### Missing Python Dependencies

If validation script fails:

```bash
# Install jsonschema
pip install jsonschema

# Or with user flag
pip install --user jsonschema
```

## Updating the Skill

To update to a newer version:

```bash
# Backup your customizations
cp -r ~/.claude/skills/hooks-mastery ~/.claude/skills/hooks-mastery.backup

# Copy new version
rm -rf ~/.claude/skills/hooks-mastery
cp -r /path/to/new/hooks-mastery ~/.claude/skills/

# Restore customizations if needed
```

## Uninstalling

To remove the skill:

```bash
# Remove from user skills
rm -rf ~/.claude/skills/hooks-mastery

# Or remove from project skills
rm -rf .claude/skills/hooks-mastery
```

## Next Steps

After installation:

1. **Try the examples**: Ask Claude to help you create hooks using the examples
2. **Read the protocol**: Review `references/protocol-specification.md`
3. **Validate your config**: Run the validation script on your settings
4. **Test locally**: Use the test script before deploying hooks
5. **Generate templates**: Create new hooks with the template generator

## Support

For questions or issues:

1. Review the README.md
2. Check references/ for detailed documentation
3. Review examples/ for working implementations
4. Ask Claude Code directly (the skill will load automatically)

## Version

**Skill Version**: 1.0.0
**Installation Date**: Run `date` to record when you installed

## File Structure Reference

```
~/.claude/skills/hooks-mastery/
├── SKILL.md                          # Main skill (auto-loaded)
├── README.md                         # Overview
├── INSTALLATION.md                   # This file
├── SKILL_SUMMARY.md                  # Validation results
│
├── references/                       # Detailed docs
│   ├── protocol-specification.md
│   └── event-reference.md
│
├── scripts/                          # Utilities
│   ├── validate-hook-config.py
│   ├── test-hook-io.py
│   └── generate-hook-template.sh
│
├── examples/                         # Working examples
│   ├── pretooluse-validator/
│   ├── userprompt-enricher/
│   ├── sessionstart-setup/
│   └── stop-evaluator/
│
└── assets/                           # Supporting files
    └── hooks-schema.json
```
