# Configuration Formats

## Component Mode (Recommended - GitLab 16.0+)

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/python/python@7
    inputs:
      image: "python:3.12-slim"
      build-system: "poetry"
      pytest-enabled: true
```

## Project Mode (Self-hosted GitLab)

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

## Remote Mode (External GitLab)

```yaml
include:
  - remote: "https://gitlab.com/to-be-continuous/python/-/raw/7.5/templates/gitlab-ci-python.yml"

variables:
  PYTHON_IMAGE: "python:3.12-slim"
```

## Input Name Transformation (Component Mode)

1. Strip prefix: `PYTHON_IMAGE` → `IMAGE`
2. Lowercase: `IMAGE` → `image`
3. Hyphens for underscores: `BUILD_SYSTEM` → `build-system`

Examples:
- `DOCKER_IMAGE` → `image`
- `NODE_VERSION` → `version`
- `PYTHON_BUILD_SYSTEM` → `build-system`
- `SONAR_ENABLED` → `enabled`

## Features (Toggles)

```yaml
# Feature enabled by default - disable with:
inputs:
  lint-disabled: true

# Feature disabled by default - enable with:
inputs:
  publish-enabled: true
```

## Variants

Include as separate component:
- Vault: `{template}-vault`
- OIDC: `{template}-oidc`
- Cloud-specific: `{template}-gcp`, `{template}-aws`

## Environment Configuration (Deployment)

| Environment | Variable Prefix | Branch |
|-------------|-----------------|--------|
| review | `{PREFIX}_REVIEW_` | Feature branches |
| integration | `{PREFIX}_INTEG_` | develop |
| staging | `{PREFIX}_STAGING_` | main |
| production | `{PREFIX}_PROD_` | main |
