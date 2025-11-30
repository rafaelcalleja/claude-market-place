# Kicker Aggregated JSON Structure

This document describes the structure of `/tmp/kicker/src/assets/kicker-aggregated.json`, the source file for schema extraction.

## Top-Level Structure

```json
{
  "extensions": [],
  "presets": [...],
  "templates": [...]
}
```

### Extensions
Currently empty array. Reserved for future use.

### Presets
Pre-configured variable sets:
```json
{
  "name": "SonarCloud",
  "description": "Configure for SonarCloud",
  "values": {
    "SONAR_HOST_URL": "https://sonarcloud.io"
  },
  "extension_id": null,
  "project": "..."
}
```

### Templates
Main array of 50 TBC templates:

```json
{
  "name": "Python",
  "description": "Template for Python projects",
  "template_path": "templates/gitlab-ci-python.yml",
  "kind": "build",
  "prefix": "python",
  "is_component": true,
  "variables": [...],
  "features": [...],
  "variants": [...],
  "extension_id": null,
  "project": {
    "path": "to-be-continuous/python",
    "name": "python",
    "tag": "7.5.2",
    "tags": ["7.5.2", "7.5.1", ...],
    "web_url": "https://gitlab.com/to-be-continuous/python",
    "avatar": "..."
  }
}
```

## Template Fields

### Core Fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Human-readable name |
| `description` | string | Template description |
| `template_path` | string | Path in project |
| `kind` | string | Category: build, hosting, analysis, acceptance |
| `prefix` | string | Variable prefix (lowercase) |
| `is_component` | boolean | Supports component mode |

### Variables Array

Each variable:
```json
{
  "name": "PYTHON_IMAGE",
  "description": "The Docker image used to run Python",
  "default": "docker.io/library/python:3-slim",
  "type": "string",
  "mandatory": false,
  "secret": false,
  "advanced": true
}
```

#### Variable Types

| Type | JSON Schema Type | Example |
|------|------------------|---------|
| `string` (default) | `"type": "string"` | `"python:3.12"` |
| `boolean` | `"type": "boolean"` | `true` |
| `number` | `"type": "number"` | `8080` |
| `enum` | `"type": "string", "enum": [...]` | `["manual", "auto"]` |

#### Variable Flags

| Flag | Description |
|------|-------------|
| `mandatory` | Required to use template |
| `secret` | Should be stored in CI/CD variables |
| `advanced` | Only show in advanced configuration mode |

### Features Array

Features are optional capabilities that add variables:

```json
{
  "name": "pytest",
  "description": "Enable pytest testing",
  "default_enabled": true,
  "variables": [
    {
      "name": "PYTEST_ARGS",
      "description": "Arguments to pass to pytest",
      "default": ""
    }
  ]
}
```

Feature naming conventions:
- Enable variable: `{PREFIX}_{FEATURE}_ENABLED` or defaults to enabled
- Disable variable: `{PREFIX}_{FEATURE}_DISABLED`
- Feature-specific: `{FEATURE}_*`

### Variants Array

Variants are alternative configurations adding authentication methods:

```json
{
  "name": "Vault",
  "description": "Use HashiCorp Vault for secrets",
  "variables": [
    {
      "name": "VAULT_BASE_URL",
      "description": "Vault server URL"
    },
    {
      "name": "VAULT_ROLE_ID",
      "description": "AppRole RoleID"
    }
  ]
}
```

Common variants:
- **Vault**: HashiCorp Vault secrets integration
- **OpenID Connect**: OIDC authentication (cloud providers)
- **Google Cloud**: GCP-specific authentication
- **AWS**: AWS-specific variables (CodeArtifact, ECR)
- **Amazon ECR**: ECR registry integration

### Project Object

Contains GitLab project metadata:

```json
{
  "path": "to-be-continuous/python",
  "name": "python",
  "tag": "7.5.2",
  "tags": ["7.5.2", "7.5.1", "7.5", "7"],
  "web_url": "https://gitlab.com/to-be-continuous/python",
  "avatar": "https://gitlab.com/uploads/-/system/project/avatar/..."
}
```

Used for:
- Schema `description` field (project path)
- Version tracking
- Documentation links

## Input Name Transformation

The extraction script transforms variable names for component mode:

1. **Strip prefix**: `PYTHON_IMAGE` → `IMAGE`
2. **Lowercase**: `IMAGE` → `image`
3. **Hyphens**: `BUILD_SYSTEM` → `build-system`

Example transformations:
| Variable | Prefix | Input Name |
|----------|--------|------------|
| `PYTHON_IMAGE` | `PYTHON_` | `image` |
| `PYTHON_BUILD_SYSTEM` | `PYTHON_` | `build-system` |
| `PYTEST_ARGS` | `PYTHON_` | `pytest-args` |
| `AWS_CLI_IMAGE` | `AWS_` | `cli-image` |
| `AWS_OIDC_ROLE_ARN` | `AWS_` | `oidc-role-arn` |

## Template Categories (kind)

| Kind | Description | Count |
|------|-------------|-------|
| `build` | Language/framework builds | 15 |
| `analysis` | Code analysis, security | 7 |
| `packaging` | Container/package builds | 3 |
| `infrastructure` | IaC (Terraform) | 1 |
| `hosting` | Deployment targets | 11 |
| `acceptance` | E2E/API testing | 10 |
| `publish` | Publishing utilities | 3 |

## Useful jq Queries

```bash
# List all template names
jq '.templates[].name' kicker-aggregated.json

# Count variables per template
jq '.templates[] | {name, vars: (.variables | length)}' kicker-aggregated.json

# Find templates with Vault variant
jq '.templates[] | select(.variants[]?.name == "Vault") | .name' kicker-aggregated.json

# Get all features for a template
jq '.templates[] | select(.name == "Python") | .features[].name' kicker-aggregated.json

# List all variable prefixes
jq '.templates[].prefix' kicker-aggregated.json | sort -u
```
