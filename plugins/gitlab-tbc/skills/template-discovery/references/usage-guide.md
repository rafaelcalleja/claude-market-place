# To Be Continuous: Usage Guide

## Including Templates

### Three Syntax Options

**1. CI/CD Component (Recommended)**
```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/maven/gitlab-ci-maven@3.9.0
    inputs:
      image: "maven:3.6-jdk-8"
      build-args: 'verify -Pcicd'
```

**2. Project Include (Legacy)**
```yaml
include:
  - project: "to-be-continuous/maven"
    ref: "3.9.0"
    file: "templates/gitlab-ci-maven.yml"
```

**3. Remote URL**
```yaml
include:
  - remote: "https://gitlab.com/to-be-continuous/maven/-/raw/3.9.0/templates/gitlab-ci-maven.yml"
```

### Versioning Strategy

- Use exact versions (e.g., `3.9.0`) for production stability
- Minor version aliases (e.g., `3.9`) automatically track patches
- Major version aliases (e.g., `3`) track latest minor release
- Avoid the default branch unless testing cutting-edge features

---

## Template Configuration

### Via CI/CD Component Inputs

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/maven/gitlab-ci-maven@3.9.0
    inputs:
      image: "maven:3.6-jdk-8"
      build-args: 'verify -Pcicd'
      sonar-url: "https://mysonar.domain.my"
```

### Via Variables (Legacy)

```yaml
include:
  - project: 'to-be-continuous/maven'
    ref: '3.9.0'
    file: '/templates/gitlab-ci-maven.yml'

variables:
  MAVEN_IMAGE: "maven:3.6-jdk-8"
  MAVEN_BUILD_ARGS: 'verify -Pcicd'
  SONAR_URL: "https://mysonar.domain.my"
```

---

## Debugging

Enable debug logs by setting `TRACE=true` during manual pipeline execution. This operates independently from GitLab's `CI_DEBUG_TRACE` variable.

**Security Warning:** `CI_DEBUG_TRACE` exposes sensitive data like credentials and tokens in logs. Use cautiously and restrict access to authorized personnel only.

---

## Docker Image Versioning Strategy

| Category | Recommendation | Rationale |
|----------|---|---|
| DevSecOps tools | Use latest | Detects vulnerabilities promptly |
| Build tools | Pin versions | Match project development environment |
| Infrastructure-as-Code | Pin versions | Control upgrade timing |
| Acceptance tests | Pin versions | Align with test framework |
| Cloud CLI clients | Use latest | Single version per cloud provider |

**Best Practice:** Explicitly override container image versions for build, infrastructure, private cloud, and acceptance test tools matching your project requirements.

---

## Secrets Management

### Standard Approach

- Declare as project or group CI/CD variables
- Enable "[mask variable](https://docs.gitlab.com/ci/variables/#mask-a-cicd-variable)" to prevent log exposure
- Enable "[protected variable](https://docs.gitlab.com/ci/variables/#protected-cicd-variables)" for production secrets

### Unmaskable Secrets (Base64 Encoding)

When characters prevent masking, encode in Base64 and prefix with `@b64@`:

```yaml
# Original secret containing special characters
CAVE_PASSPHRASE: '{"open":"$€5@me"}'

# Encoded solution (use base64 -w 0 to prevent line breaks)
CAVE_PASSPHRASE: '@b64@eyJvcGVuIjoiJOKCrDVAbWUifQ=='
```

### External Secrets Management

Prefix variables with `@url@` followed by the URL:

```yaml
MY_SECRET: '@url@https://vault.example.com/api/secret/my-secret'
```

For HashiCorp Vault integration, use the vault-secrets-provider image available in `-vault` template variants:

```yaml
MY_SECRET: '@url@http://vault-secrets-provider/api/secrets/{path}?field={name}'
```

Default timeout is 5 seconds; override with `TBC_SECRET_URL_TIMEOUT` variable.

---

## Scoped Variables

Limit or override environment variables based on execution context using this syntax:

```
scoped__<target_var>__<condition>__<cond_var>__<operator>__<value>=<result>
```

### Operators

| Type | Options |
|------|---------|
| Unary | `defined` |
| Comparison | `equals`, `startswith`, `endswith`, `contains`, `in` |
| Case-insensitive | Append `_ic` to comparison operators |

### Example 1: Scope by Environment

```yaml
variables:
  K8S_URL: "https://my-nonprod-k8s.domain"
  scoped__K8S_URL__if__CI_ENVIRONMENT_NAME__equals__production: "https://my-prod-k8s.domain"
```

### Example 2: Scope by Branch

```yaml
variables:
  NG_BUILD_ARGS: "build"
  scoped__NG_BUILD_ARGS__if__CI_COMMIT_REF_NAME__equals__develop: "build --configuration=staging"
  scoped__NG_BUILD_ARGS__if__CI_COMMIT_REF_NAME__equals__master: "build --configuration=production"
```

### Example 3: Scope on Tag

```yaml
variables:
  DOCKER_BUILD_ARGS: "--build-arg IMAGE_TYPE=snapshot"
  scoped__DOCKER_BUILD_ARGS__if__CI_COMMIT_TAG__defined: "--build-arg IMAGE_TYPE=release"
```

**Limitation:** Scoped variables only work in `script` and `before_script` sections, not for image parameters, job enable/disable flags, or artifact/cache/rules sections.

---

## Proxy Configuration

Templates support standard Linux proxy variables:

```yaml
variables:
  http_proxy: "http://my.proxy:8080"
  https_proxy: "http://my.proxy:8080"
  ftp_proxy: "ftp://my.proxy:8080"
  no_proxy: "*.internal.domain"
```

Define globally or per-job, or apply to all jobs via the template's base job.

---

## Certificate Authority Configuration

Add custom certificates via the `CUSTOM_CA_CERTS` variable in PEM format:

```yaml
variables:
  CUSTOM_CA_CERTS: |
    -----BEGIN CERTIFICATE-----
    [certificate content]
    -----END CERTIFICATE-----
```

Templates automatically add these to the system trust store.

---

## Configurable Git References

### Production and Integration Branches

Override default branch patterns using regex:

```yaml
variables:
  PROD_REF: '/^(master|main)$/'
  INTEG_REF: '/^develop$/'
```

### Release Tag Pattern

Control semantic versioning enforcement:

```yaml
variables:
  RELEASE_REF: '/^v?[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9\-\.]+)?(\+[a-zA-Z0-9\-\.]+)?$/'
```

---

## Extended [skip ci] Feature

Selectively skip pipelines using:

```
[ci skip on <keyword>] or [skip ci on <keyword>]
```

### Supported Keywords

| Keyword | Effect |
|---------|--------|
| `tag` | Skip on tag pipelines |
| `mr` | Skip on merge request pipelines |
| `branch` | Skip on branch pipelines |
| `default` | Skip on default project branch |
| `prod` | Skip on production branch |
| `integ` | Skip on integration branch |
| `dev` | Skip on development branches |

**Example commit message:**
```
Bump version [skip ci on tag]
```

---

## Merge Request Workflow

Default strategy: Merge Request pipelines. Switch to branch pipelines by overriding workflow rules:

```yaml
workflow:
  rules:
    - !reference [.tbc-workflow-rules, skip-back-merge]
    - !reference [.tbc-workflow-rules, prefer-branch-pipeline]
    - !reference [.tbc-workflow-rules, extended-skip-ci]
    - when: always
```

---

## Test & Analysis Job Rules (Adaptive Pipeline)

Default behavior implements progressive job execution:

**On tag, production, or integration branches:** Auto-run, must succeed
**On development branch (no MR):** Manual trigger, allowed to fail
**On draft MR:** Auto-run, allowed to fail
**On ready MR:** Auto-run, must succeed

Disable adaptive pipeline by setting:

```yaml
variables:
  ADAPTIVE_PIPELINE_DISABLED: "true"
```

---

## Override YAML (Advanced)

GitLab deep-merges included YAML with `.gitlab-ci.yml`, allowing overrides.

### The Template Base Job

Each template defines a hidden base job extended by all template jobs. Override this to affect all template jobs:

**Example:** Maven template uses `.mvn-base`

### Example 1: Add Service Containers

```yaml
mvn-build:
  services:
    - name: mysql:latest
      alias: mysql_host
  variables:
    MYSQL_DATABASE: "acme"
    MYSQL_ROOT_PASSWORD: "root"
```

### Example 2: Private Runners with Proxy

```yaml
.k8s-base:
  tags:
    - kubernetes
    - private
  variables:
    http_proxy: "http://my.proxy:8080"
    https_proxy: "http://my.proxy:8080"
```

### Example 3: Disable Non-Configurable Job

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/golang/gitlab-ci-golang@4.8.1

go-mod-outdated:
  rules:
    - when: never
```

### Example 4: Allow Test Job to Fail

```yaml
docker-trivy:
  rules:
    - if: '$CI_MERGE_REQUEST_ID == null && $CI_OPEN_MERGE_REQUESTS == null'
      when: manual
      allow_failure: true
    - allow_failure: true
```

---

## Multiple Template Instantiation (Monorepos)

Use `parallel:matrix` syntax for multi-instantiation:

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/python/gitlab-ci-python@8

.python-base:
  parallel:
    matrix:
      - PYTHON_PROJECT_DIR: backends/users-api
        PYTHON_IMAGE: docker.io/library/python:3.13-slim
        PYTEST_ENABLED: true
      - PYTHON_PROJECT_DIR: backends/orders-api
        PYTHON_IMAGE: docker.io/library/python:3.13-slim
        NOSETESTS_ENABLED: true
```

**Note:** `parallel:matrix` requires variables syntax; CI/CD component inputs don't support matrix configuration.

---

## Summary of Best Practices

1. **Pin template versions** for production stability
2. **Override container images** explicitly for build/infrastructure tools
3. **Mask all secrets** and use Base64 encoding for unmaskable values
4. **Scope variables** to limit configuration to specific contexts
5. **Override base jobs** for changes affecting all template jobs
6. **Test configuration** with `TRACE=true` before production deployment
7. **Review adaptive pipeline** rules for your development workflow needs