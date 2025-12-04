# JSON Schemas for Skill Validation

Documentation for using JSON schemas to validate Agent Skills.

## Available Schemas

### skill-frontmatter-schema.json

Validates the YAML frontmatter in SKILL.md files.

**Location**: `../assets/skill-frontmatter-schema.json`

**Fields validated**:
- `name`: Pattern, length, format
- `description`: Length, presence
- `allowed-tools`: Valid tool names

### skill-schema.json

Complete schema for representing skills as JSON objects.

**Location**: `../assets/skill-schema.json`

**Fields validated**:
- All frontmatter fields
- Content structure
- Supporting files
- Dependencies

## Schema Details

### Name Field Schema

```json
{
  "name": {
    "type": "string",
    "pattern": "^[a-z0-9-]+$",
    "minLength": 1,
    "maxLength": 64,
    "description": "Unique identifier using lowercase letters, numbers, and hyphens only"
  }
}
```

### Description Field Schema

```json
{
  "description": {
    "type": "string",
    "minLength": 1,
    "maxLength": 1024,
    "description": "Must include what skill does AND when to use it. Use third person."
  }
}
```

### Allowed-Tools Field Schema

```json
{
  "allowed-tools": {
    "oneOf": [
      {
        "type": "array",
        "items": {
          "type": "string",
          "enum": [
            "Read", "Write", "Edit", "Bash", "Glob", "Grep",
            "Task", "WebFetch", "WebSearch", "TodoWrite",
            "AskUserQuestion", "Skill", "SlashCommand",
            "EnterPlanMode", "ExitPlanMode", "NotebookEdit",
            "BashOutput", "KillShell", "ListMcpResourcesTool",
            "ReadMcpResourceTool"
          ]
        },
        "uniqueItems": true
      },
      {
        "type": "string",
        "pattern": "^[A-Za-z]+(,\\s*[A-Za-z]+)*$"
      }
    ]
  }
}
```

## Validation Examples

### Python Validation

```python
import json
import yaml
from jsonschema import validate, ValidationError

# Load schema
with open('skill-frontmatter-schema.json', 'r') as f:
    schema = json.load(f)

# Extract frontmatter from SKILL.md
with open('.claude/skills/my-skill/SKILL.md', 'r') as f:
    content = f.read()
    frontmatter_text = content.split('---')[1]
    frontmatter = yaml.safe_load(frontmatter_text)

# Validate
try:
    validate(instance=frontmatter, schema=schema)
    print("✅ Valid!")
except ValidationError as e:
    print(f"❌ Error: {e.message}")
```

### Node.js Validation

```javascript
const Ajv = require('ajv');
const yaml = require('js-yaml');
const fs = require('fs');

// Load schema
const schema = JSON.parse(
  fs.readFileSync('skill-frontmatter-schema.json', 'utf8')
);

// Create validator
const ajv = new Ajv();
const validate = ajv.compile(schema);

// Extract and parse frontmatter
const content = fs.readFileSync(
  '.claude/skills/my-skill/SKILL.md', 'utf8'
);
const frontmatterText = content.split('---')[1];
const frontmatter = yaml.load(frontmatterText);

// Validate
if (validate(frontmatter)) {
  console.log('✅ Valid!');
} else {
  console.log('❌ Errors:', validate.errors);
}
```

### CLI Validation with ajv-cli

```bash
# Install ajv-cli
npm install -g ajv-cli

# Extract frontmatter to JSON
python -c "
import yaml, json, sys
with open('SKILL.md') as f:
    fm = yaml.safe_load(f.read().split('---')[1])
    print(json.dumps(fm))
" > frontmatter.json

# Validate
ajv validate -s skill-frontmatter-schema.json -d frontmatter.json
```

## VS Code Integration

Add to `.vscode/settings.json`:

```json
{
  "yaml.schemas": {
    "./skill-frontmatter-schema.json": [
      ".claude/skills/*/SKILL.md",
      "~/.claude/skills/*/SKILL.md"
    ]
  }
}
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Validate Skills

on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: '3.x'

      - name: Install dependencies
        run: pip install jsonschema pyyaml

      - name: Validate Skills
        run: python scripts/validate_skills.py
```

### Validation Script

```python
#!/usr/bin/env python3
import json
import yaml
import sys
from pathlib import Path
from jsonschema import validate, ValidationError

def extract_frontmatter(content):
    parts = content.split('---')
    if len(parts) < 3:
        raise ValueError("No valid frontmatter")
    return yaml.safe_load(parts[1])

def validate_skill(skill_path, schema):
    print(f"Validating {skill_path}...")

    with open(skill_path, 'r') as f:
        content = f.read()

    try:
        frontmatter = extract_frontmatter(content)
        validate(instance=frontmatter, schema=schema)
        print(f"  ✅ Valid")
        return True
    except ValidationError as e:
        print(f"  ❌ {e.message}")
        return False
    except Exception as e:
        print(f"  ❌ {str(e)}")
        return False

def main():
    schema_path = Path('skill-frontmatter-schema.json')
    with open(schema_path, 'r') as f:
        schema = json.load(f)

    skill_files = list(Path('.claude/skills').rglob('SKILL.md'))

    if not skill_files:
        print("No SKILL.md files found")
        return 0

    print(f"Found {len(skill_files)} skill(s)\n")

    results = [validate_skill(f, schema) for f in skill_files]

    print(f"\nResults: {sum(results)}/{len(results)} valid")
    return 0 if all(results) else 1

if __name__ == '__main__':
    sys.exit(main())
```

## Common Validation Errors

### "name does not match pattern"

**Problem**: Name contains invalid characters

**Examples**:
- `MySkill` → Contains uppercase
- `my_skill` → Contains underscore
- `skill 1` → Contains space

**Fix**: Use only lowercase letters, numbers, and hyphens: `my-skill`

### "description is too long"

**Problem**: Description exceeds 1024 characters

**Fix**: Shorten description, move details to SKILL.md body

### "allowed-tools contains invalid value"

**Problem**: Tool name not recognized

**Common mistakes**:
- `read` → Should be `Read`
- `bash` → Should be `Bash`
- `grep` → Should be `Grep`

**Fix**: Use exact tool names with proper capitalization

### "Additional properties not allowed"

**Problem**: Unknown field in frontmatter

**Fix**: Check spelling, use only defined fields (name, description, allowed-tools, version)

## Schema Versioning

Current schema version: 1.0.0

Schemas follow semantic versioning:
- **Major**: Breaking changes to validation
- **Minor**: New optional fields
- **Patch**: Documentation fixes
