# TBC Kicker Presets Reference

Pre-configured variable sets for common services and platforms used with TBC templates.

---

## Available Presets

### SonarCloud

Pre-configured settings for using SonarCloud instead of self-hosted SonarQube.

**Applies to**: SonarQube template

| Variable | Preset Value |
|----------|--------------|
| `SONAR_HOST_URL` | `https://sonarcloud.io` |

**Usage (Component Mode):**

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/sonar/sonar@5
    inputs:
      host-url: "https://sonarcloud.io"
      project-key: "your-org_your-project"
      quality-gate-enabled: true

# secret variables
# SONAR_TOKEN: Your SonarCloud token
```

**Notes:**
- Create organization on sonarcloud.io
- Project key format: `organization_project-name`
- Token must have `Administer Quality Profiles` permission for quality gate

---

### OpenShift Sandbox

Pre-configured settings for Red Hat OpenShift Developer Sandbox.

**Applies to**: OpenShift template, Kubernetes template

| Variable | Preset Value |
|----------|--------------|
| `OS_URL` | `https://api.sandbox-m2.ll9k.p1.openshiftapps.com:6443` |
| `K8S_URL` | `https://api.sandbox-m2.ll9k.p1.openshiftapps.com:6443` |

**Usage (Component Mode):**

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/openshift/openshift@5
    inputs:
      url: "https://api.sandbox-m2.ll9k.p1.openshiftapps.com:6443"
      review-project: "your-username-dev"
      staging-project: "your-username-stage"

# secret variables
# OS_TOKEN: Service account token from OpenShift
```

**Notes:**
- Register at developers.redhat.com/developer-sandbox
- Each sandbox has a unique URL - update `URL` accordingly
- Sandbox accounts have resource limits
- Idle namespaces are stopped after 12 hours

---

## Custom Presets

Create custom presets for your organization by pre-configuring common variables.

### Example: Corporate SonarQube

```yaml
# .gitlab-ci.yml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/sonar/sonar@5
    inputs:
      host-url: "https://sonarqube.mycompany.com"
      # Company standard configuration
      base-args: >
        -Dsonar.qualitygate.wait=true
        -Dsonar.coverage.exclusions=**/test/**
      quality-gate-enabled: true
```

### Example: Internal Kubernetes Cluster

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/kubernetes/kubernetes@5
    inputs:
      url: "https://k8s.internal.mycompany.com:6443"
      auto-create-namespace: true
      review-namespace: "review-$CI_COMMIT_REF_SLUG"
      staging-namespace: "staging"
      prod-namespace: "production"

# Organization-wide secret variables (set at group level)
# K8S_TOKEN: Service account token
```

### Example: AWS with OIDC

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/aws/aws@5
    inputs:
      review-enabled: true
      staging-enabled: true
      prod-enabled: true
  - component: $CI_SERVER_FQDN/to-be-continuous/aws/aws-oidc@5

# Organization-wide OIDC configuration (set at group level)
# AWS_OIDC_ROLE_ARN: arn:aws:iam::123456789012:role/GitLabCICD
```

---

## Preset Best Practices

### 1. Group-Level Configuration

Set common variables at GitLab group level for consistency:

- SonarQube URL and organization settings
- Kubernetes cluster URLs
- Cloud provider configurations
- Registry URLs

### 2. Environment-Specific Overrides

Use environment-specific variables to override defaults:

```yaml
variables:
  # Default for all environments
  HELM_NAMESPACE: "default"

# Override per environment in CI/CD variables
# HELM_PROD_NAMESPACE: "production" (protected variable)
```

### 3. Secret Management

Use CI/CD variables for secrets:

```yaml
# NOT in .gitlab-ci.yml
# Store in Settings > CI/CD > Variables
# - SONAR_TOKEN (masked)
# - AWS_OIDC_ROLE_ARN
# - K8S_TOKEN (masked)
```

### 4. Template Extensions

Create project templates that include your presets:

```yaml
# templates/company-defaults.yml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/sonar/sonar@5
    inputs:
      host-url: "https://sonarqube.mycompany.com"
```

Then in projects:

```yaml
include:
  - project: "company/templates"
    ref: main
    file: "templates/company-defaults.yml"
  - component: $CI_SERVER_FQDN/to-be-continuous/python/python@7
```

---

## Preset Variables Quick Reference

| Preset | Template | Key Variable | Value |
|--------|----------|--------------|-------|
| SonarCloud | sonar | `SONAR_HOST_URL` | `https://sonarcloud.io` |
| OpenShift Sandbox | openshift | `OS_URL` | `https://api.sandbox-m2...` |
| OpenShift Sandbox | kubernetes | `K8S_URL` | `https://api.sandbox-m2...` |
