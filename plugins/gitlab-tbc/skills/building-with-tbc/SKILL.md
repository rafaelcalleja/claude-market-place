---
name: building-with-tbc
description: This skill should be used when building GitLab CI/CD pipelines with
  the To-Be-Continuous framework. Load this skill to access accurate template
  specifications, variables, schemas, and configuration patterns. Required by
  TBC commands to generate valid configurations without hallucinations.
version: 1.0.0
---

# Building with To-Be-Continuous (TBC)

This skill provides the knowledge base for generating GitLab CI/CD configurations using the To-Be-Continuous framework.

## Overview

To-Be-Continuous (TBC) is a framework of 62 modular templates organized into 8 categories for building GitLab CI/CD pipelines. Templates are reusable components that handle specific aspects of CI/CD workflows.

### Template Categories

| Category | Count | Selection | Description |
|----------|-------|-----------|-------------|
| Build | 15 | Single | Programming language/framework |
| Code Analysis | 7 | Multiple | Security, linting, SAST |
| Packaging | 3 | Single | Container/package builds |
| Infrastructure | 1 | Single | Terraform IaC |
| Deployment | 11 | Single | Cloud/K8s deployment |
| Acceptance | 10 | Multiple | E2E/API testing |
| Other | 3 | Multiple | Misc utilities |

**Selection Rules:**
- Build, Packaging, Infrastructure, Deployment: SELECT ONE or NONE
- Code Analysis, Acceptance, Other: SELECT MULTIPLE (including none)

## Configuration Format

### Component Mode (Recommended - GitLab 16.0+)

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/python/python@7
    inputs:
      image: "python:3.12-slim"
      build-system: "poetry"
      pytest-enabled: true
```

### Project Mode (Self-hosted GitLab)

```yaml
include:
  - project: "to-be-continuous/python"
    ref: "7.5"
    file: "templates/gitlab-ci-python.yml"

variables:
  PYTHON_IMAGE: "python:3.12-slim"
  PYTHON_BUILD_SYSTEM: "poetry"
  PYTEST_ENABLED: "true"
```

### Remote Mode (External GitLab)

```yaml
include:
  - remote: "https://gitlab.com/to-be-continuous/python/-/raw/7.5/templates/gitlab-ci-python.yml"

variables:
  PYTHON_IMAGE: "python:3.12-slim"
```

## Input Name Transformation

For component mode, transform variable names:

1. **Strip prefix**: `PYTHON_IMAGE` → `IMAGE`
2. **Lowercase**: `IMAGE` → `image`
3. **Hyphens for underscores**: `BUILD_SYSTEM` → `build-system`

**Examples:**
- `DOCKER_IMAGE` → `image`
- `NODE_VERSION` → `version`
- `PYTHON_BUILD_SYSTEM` → `build-system`
- `SONAR_ENABLED` → `enabled`

## Template Configuration

### Variables

Each template has variables with these properties:

| Property | Type | Description |
|----------|------|-------------|
| `name` | string | Variable name (e.g., `PYTHON_IMAGE`) |
| `default` | any | Default value if not specified |
| `type` | enum | `text`, `url`, `boolean`, `enum`, `number` |
| `mandatory` | boolean | Required to use template |
| `secret` | boolean | Store in CI/CD settings, not in file |
| `advanced` | boolean | Only show in advanced mode |

### Features

Templates have toggleable features (enabled/disabled by default):

```yaml
# Feature enabled by default - disable with:
inputs:
  lint-disabled: true

# Feature disabled by default - enable with:
inputs:
  publish-enabled: true
```

### Variants

Templates may have variants for additional functionality:

| Variant | Templates | Purpose |
|---------|-----------|---------|
| **Vault** | Most | HashiCorp Vault secrets integration |
| **OIDC** | AWS, Azure, GCP | OpenID Connect authentication |
| **Cloud-specific** | Various | Cloud provider authentication |

## Version Modes

| Mode | Syntax | Updates | Use Case |
|------|--------|---------|----------|
| `major` | `@7` | Auto major | Latest features (less stable) |
| `minor` | `@7.5` | Auto patch | Recommended balance |
| `full` | `@7.5.2` | None | Maximum stability |

## Validation

### Using Schemas

All 50 templates have JSON schemas in `${CLAUDE_PLUGIN_ROOT}/skills/building-with-tbc/schemas/`.

**Available schemas:**
- Build: `python.json`, `node.json`, `go.json`, `maven.json`, `gradle.json`, etc.
- Analysis: `sonar.json`, `gitleaks.json`, `defectdojo.json`, etc.
- Packaging: `docker.json`, `cnb.json`, `source-to-image.json`
- Deployment: `kubernetes.json`, `helm.json`, `aws.json`, `azure.json`, etc.

### Validation Script

Use `validate-inputs.py` to validate configurations:

```bash
python3 ${CLAUDE_PLUGIN_ROOT}/skills/building-with-tbc/scripts/validate-inputs.py /path/to/.gitlab-ci.yml
```

**CRITICAL RULE**: ALWAYS invoke the `tbc-validator` agent before presenting generated configurations to users. Never show unvalidated output.

## Reference Files

Detailed information is available in the references directory:

- **templates-catalog.md**: Complete catalog of all 62 templates
- **build-templates.md**: Build category templates (15)
- **deployment-templates.md**: Deployment category templates (11)
- **analysis-templates.md**: Code analysis templates (7)
- **variantes.md**: Variants (Vault, OIDC, cloud-specific)
- **presets.md**: Common configuration presets
- **best-practices.md**: TBC usage best practices

## Example Configurations

Example configurations are in `${CLAUDE_PLUGIN_ROOT}/skills/building-with-tbc/examples/`:

- Python with Docker and Kubernetes
- Node.js with SonarQube
- Go with Helm
- Java with Maven and AWS

## Workflow: Kicker Wizard

The traditional TBC workflow is an 8-step wizard:

1. **Configure Global Options**: Mode (component/project/remote), version mode, advanced settings
2. **Build**: Select language template
3. **Code Analysis**: Select analysis tools (multiple)
4. **Packaging**: Select packaging method
5. **Infrastructure**: Select Terraform or none
6. **Deployment**: Select deployment target
7. **Acceptance Tests**: Select test frameworks (multiple)
8. **Generate**: Create `.gitlab-ci.yml` with all selections

## Key Principles

1. **Read schemas first**: Templates have specific variables - don't hallucinate
2. **Transform names correctly**: Component mode requires lowercase with hyphens
3. **Validate before presenting**: Use tbc-validator agent
4. **Respect selection rules**: Single vs multiple per category
5. **Include secret variables comments**: Document CI/CD variables needed
6. **Use $CI_SERVER_FQDN**: For component mode in generic configurations

## Common Patterns

### Python + Docker + Kubernetes

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/python/python@7
    inputs:
      image: "python:3.12-slim"
      build-system: "poetry"

  - component: $CI_SERVER_FQDN/to-be-continuous/docker/docker@7
    inputs:
      image-name: "myapp"

  - component: $CI_SERVER_FQDN/to-be-continuous/kubernetes/kubernetes@7
    inputs:
      namespace: "production"

# secret variables
# DOCKER_REGISTRY_USER: Docker registry username
# DOCKER_REGISTRY_PASSWORD: Docker registry password
# KUBE_CONFIG: Kubernetes config file (base64)
```

### Node.js + SonarQube

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/node/node@7
    inputs:
      version: "20"
      package-manager: "npm"

  - component: $CI_SERVER_FQDN/to-be-continuous/sonar/sonar@7
    inputs:
      enabled: true

# secret variables
# SONAR_TOKEN: SonarQube authentication token
```

## Path References

All paths should use `${CLAUDE_PLUGIN_ROOT}` for portability:

- Schemas: `${CLAUDE_PLUGIN_ROOT}/skills/building-with-tbc/schemas/`
- Scripts: `${CLAUDE_PLUGIN_ROOT}/skills/building-with-tbc/scripts/`
- Examples: `${CLAUDE_PLUGIN_ROOT}/skills/building-with-tbc/examples/`
- References: `${CLAUDE_PLUGIN_ROOT}/skills/building-with-tbc/references/`
