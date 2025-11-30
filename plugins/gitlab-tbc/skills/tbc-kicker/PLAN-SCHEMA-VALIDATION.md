# Plan: Schema Validation for TBC Kicker Skill

## Problem Statement

The skill currently hallucinates non-existent variables when suggesting configurations.

**Example of hallucinated AWS config:**
```yaml
# ALL OF THIS IS INVENTED - NONE EXISTS IN REAL TEMPLATE
inputs:
  region: "us-east-1"           # FAKE
  ecs-enabled: true             # FAKE
  ecs-cluster: "production"     # FAKE
  health-check-url: "..."       # FAKE
  rollback-enabled: true        # FAKE
```

**Real AWS template variables:**
```yaml
inputs:
  cli-image: "..."              # REAL (AWS_CLI_IMAGE)
  base-app-name: "..."          # REAL (AWS_BASE_APP_NAME)
  environment-url: "..."        # REAL (AWS_ENVIRONMENT_URL)
  scripts-dir: "..."            # REAL (AWS_SCRIPTS_DIR)
  review-enabled: true          # REAL (AWS_REVIEW_ENABLED)
  # ... environment-specific variables
```

---

## Solution Architecture

### Directory Structure

```
plugins/gitlab-tbc/skills/tbc-kicker/
├── SKILL.md
├── schemas/                          # NEW
│   ├── aws.json                      # JSON Schema for AWS template
│   ├── python.json                   # JSON Schema for Python template
│   ├── docker.json                   # JSON Schema for Docker template
│   ├── ... (50 total schemas)
│   └── _meta.json                    # Schema metadata & versions
├── scripts/
│   ├── validate-tbc-config.sh        # Existing
│   ├── extract-schemas.py            # NEW - Extract from kicker JSON
│   └── validate-inputs.py            # NEW - Validate YAML against schemas
├── references/
│   └── ... (existing)
└── examples/
    └── ... (existing)
```

---

## Phase 1: Schema Extraction

### 1.1 Create `scripts/extract-schemas.py`

**Purpose:** Extract JSON schemas from kicker-aggregated.json

**Input:** `/tmp/kicker/src/assets/kicker-aggregated.json`

**Output:** One JSON schema per template in `schemas/` directory

**Schema Format per Template:**

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "AWS Template",
  "description": "to-be-continuous/aws",
  "type": "object",
  "properties": {
    "inputs": {
      "type": "object",
      "properties": {
        "cli-image": {
          "type": "string",
          "description": "The Docker image used to run AWS CLI commands",
          "default": "docker.io/amazon/aws-cli:latest"
        },
        "base-app-name": {
          "type": "string",
          "description": "Base application name",
          "default": "$CI_PROJECT_NAME"
        },
        "review-enabled": {
          "type": "boolean",
          "description": "Enable Review environment",
          "default": false
        }
        // ... all real variables
      },
      "additionalProperties": false  // KEY: Reject unknown inputs
    }
  },
  "_meta": {
    "prefix": "AWS_",
    "kind": "hosting",
    "is_component": false,
    "variants": ["OpenID Connect", "Vault"],
    "features": ["Review", "Integration", "Staging", "Production"]
  }
}
```

**Key Implementation Details:**

1. **Input Name Transformation:**
   ```python
   def var_to_input(var_name: str, prefix: str) -> str:
       # AWS_CLI_IMAGE -> cli-image
       # AWS_REVIEW_ENABLED -> review-enabled
       name = var_name
       if name.startswith(prefix + '_'):
           name = name[len(prefix) + 1:]
       return name.lower().replace('_', '-')
   ```

2. **Include Feature Variables:**
   - Features have their own variables
   - Enable/disable variables (`AWS_REVIEW_ENABLED`)
   - Feature-specific variables (`AWS_REVIEW_APP_NAME`)

3. **Include Variant Variables:**
   - Variants add additional variables
   - OIDC variant adds `AWS_OIDC_ROLE_ARN`
   - Vault variant adds `VAULT_*` variables

### 1.2 Generate All 50 Schemas

Run extraction for all templates:

```bash
python3 scripts/extract-schemas.py \
  --input /tmp/kicker/src/assets/kicker-aggregated.json \
  --output-dir schemas/
```

Expected output:
- `schemas/angular.json`
- `schemas/aws.json`
- `schemas/azure.json`
- ... (50 files total)
- `schemas/_meta.json` (index of all schemas)

---

## Phase 2: Validation Script

### 2.1 Create `scripts/validate-inputs.py`

**Purpose:** Validate a .gitlab-ci.yml file against TBC schemas

**Usage:**
```bash
python3 scripts/validate-inputs.py .gitlab-ci.yml
```

**Output:**
```
Validating .gitlab-ci.yml against TBC schemas...

✓ to-be-continuous/python/python@7
  All inputs are valid.

✗ to-be-continuous/aws/aws@7
  ERROR: Unknown inputs found:
    - 'region' is not a valid input (did you mean 'scripts-dir'?)
    - 'ecs-enabled' is not a valid input
    - 'ecs-cluster' is not a valid input
    - 'health-check-url' is not a valid input
    - 'rollback-enabled' is not a valid input

  Valid inputs for aws template:
    - cli-image (string)
    - base-app-name (string)
    - environment-url (string)
    - scripts-dir (string)
    - review-enabled (boolean)
    - review-app-name (string)
    - integ-enabled (boolean)
    - staging-enabled (boolean)
    - prod-enabled (boolean)
    ...

Summary: 1 template valid, 1 template with errors
```

**Implementation:**

```python
#!/usr/bin/env python3
"""Validate .gitlab-ci.yml inputs against TBC schemas."""

import yaml
import json
import sys
import re
from pathlib import Path
from difflib import get_close_matches

SCHEMAS_DIR = Path(__file__).parent.parent / "schemas"

def load_schemas():
    """Load all JSON schemas."""
    schemas = {}
    for schema_file in SCHEMAS_DIR.glob("*.json"):
        if schema_file.name.startswith("_"):
            continue
        with open(schema_file) as f:
            schema = json.load(f)
            # Index by project path
            project = schema.get("description", "")
            schemas[project] = schema
    return schemas

def extract_component_path(component_str):
    """Extract project path from component string."""
    # $CI_SERVER_FQDN/to-be-continuous/aws/aws@7 -> to-be-continuous/aws
    match = re.search(r'to-be-continuous/([^/@]+)', component_str)
    if match:
        return f"to-be-continuous/{match.group(1)}"
    return None

def validate_inputs(yaml_content, schemas):
    """Validate all component inputs."""
    errors = []
    valid = []

    includes = yaml_content.get("include", [])
    for include in includes:
        if "component" not in include:
            continue

        component = include["component"]
        project = extract_component_path(component)

        if project not in schemas:
            continue

        schema = schemas[project]
        valid_inputs = set(schema["properties"]["inputs"]["properties"].keys())
        provided_inputs = set(include.get("inputs", {}).keys())

        unknown = provided_inputs - valid_inputs

        if unknown:
            suggestions = {}
            for inp in unknown:
                matches = get_close_matches(inp, valid_inputs, n=1)
                if matches:
                    suggestions[inp] = matches[0]

            errors.append({
                "component": component,
                "unknown_inputs": list(unknown),
                "suggestions": suggestions,
                "valid_inputs": sorted(valid_inputs)
            })
        else:
            valid.append(component)

    return valid, errors

def main():
    if len(sys.argv) < 2:
        print("Usage: validate-inputs.py <gitlab-ci.yml>")
        sys.exit(1)

    yaml_file = Path(sys.argv[1])
    with open(yaml_file) as f:
        content = yaml.safe_load(f)

    schemas = load_schemas()
    valid, errors = validate_inputs(content, schemas)

    # Print results
    for v in valid:
        print(f"✓ {v}")
        print("  All inputs are valid.\n")

    for e in errors:
        print(f"✗ {e['component']}")
        print("  ERROR: Unknown inputs found:")
        for inp in e['unknown_inputs']:
            suggestion = e['suggestions'].get(inp)
            if suggestion:
                print(f"    - '{inp}' is not valid (did you mean '{suggestion}'?)")
            else:
                print(f"    - '{inp}' is not valid")
        print()
        print("  Valid inputs:")
        for inp in e['valid_inputs'][:10]:
            print(f"    - {inp}")
        if len(e['valid_inputs']) > 10:
            print(f"    ... and {len(e['valid_inputs']) - 10} more")
        print()

    if errors:
        sys.exit(1)

if __name__ == "__main__":
    main()
```

---

## Phase 3: SKILL.md Integration

### 3.1 Add Validation Workflow to SKILL.md

Add section to SKILL.md:

```markdown
## Input Validation

Before generating or suggesting any configuration:

1. **Check schema first**: Read the relevant schema from `schemas/{template}.json`
2. **Only suggest valid inputs**: Never invent inputs not in the schema
3. **Validate after generation**: Run `scripts/validate-inputs.py` on output

### Validation Command

After generating any `.gitlab-ci.yml`:

\`\`\`bash
python3 scripts/validate-inputs.py .gitlab-ci.yml
\`\`\`

### Schema Location

All valid inputs are defined in `schemas/`:
- `schemas/aws.json` - Valid AWS template inputs
- `schemas/python.json` - Valid Python template inputs
- etc.

**CRITICAL**: If an input is not in the schema, DO NOT suggest it.
```

### 3.2 Add Pre-Generation Check

Add to workflow:

```markdown
### Before Suggesting Inputs

1. Identify the template being configured
2. Read `schemas/{template}.json`
3. List ONLY inputs from `properties.inputs.properties`
4. NEVER suggest inputs not in the schema
```

---

## Phase 4: Testing

### 4.1 Test Cases

**Test 1: Valid Configuration**
```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/python/python@7
    inputs:
      image: "python:3.12"
      pytest-enabled: true
```
Expected: `✓ All inputs are valid`

**Test 2: Invalid Configuration (Current Problem)**
```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/aws/aws@7
    inputs:
      region: "us-east-1"        # INVALID
      ecs-enabled: true          # INVALID
```
Expected: `✗ Unknown inputs: region, ecs-enabled`

**Test 3: Typo Detection**
```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/docker/docker@6
    inputs:
      bild-tool: "kaniko"        # Typo of build-tool
```
Expected: `✗ 'bild-tool' is not valid (did you mean 'build-tool'?)`

---

## Implementation Order

1. **Day 1: Schema Extraction**
   - [ ] Create `scripts/extract-schemas.py`
   - [ ] Test with one template (AWS)
   - [ ] Generate all 50 schemas
   - [ ] Create `schemas/_meta.json`

2. **Day 2: Validation Script**
   - [ ] Create `scripts/validate-inputs.py`
   - [ ] Test with valid YAML
   - [ ] Test with invalid YAML (current problem)
   - [ ] Add typo suggestions

3. **Day 3: Integration**
   - [ ] Update SKILL.md with validation workflow
   - [ ] Add pre-generation check instructions
   - [ ] Test full workflow

4. **Day 4: Testing & Release**
   - [ ] Run validation on all examples/
   - [ ] Fix any issues in examples
   - [ ] Create new release

---

## Success Criteria

1. **No more hallucinated inputs**: Claude only suggests inputs that exist in schemas
2. **Immediate validation**: Users can validate their configs instantly
3. **Helpful error messages**: Clear indication of what went wrong and suggestions
4. **Self-updating**: Can regenerate schemas when TBC releases new versions

---

## Future Enhancements

1. **Pre-commit hook**: Run validation before git commit
2. **MCP server**: Expose validation as MCP tool
3. **Auto-update**: Script to fetch latest kicker JSON and regenerate schemas
4. **IDE integration**: JSON schema for VS Code autocomplete
