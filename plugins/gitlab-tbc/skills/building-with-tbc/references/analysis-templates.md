# Code Analysis, Packaging & Testing Templates Reference

Complete configuration for TBC analysis (7), packaging (3), acceptance testing (10), and miscellaneous (3) templates.

---

## Code Analysis Templates (7)

### SonarQube

**Template**: `to-be-continuous/sonar`
**Prefix**: `SONAR_`
**Latest Version**: 5.x

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SONAR_IMAGE` | sonar-scanner Docker image | - |
| `SONAR_HOST_URL` | SonarQube server URL | - |
| `SONAR_PROJECT_KEY` | Project key | - |
| `SONAR_PROJECT_NAME` | Project name | - |
| `SONAR_ARGS` | Analysis arguments | - |
| `SONAR_QUALITY_GATE_ENABLED` | Enable quality gate | `false` |
| `SONAR_TOKEN` | Authentication token (secret) | - |

### Variants

| Variant | Description |
|---------|-------------|
| Vault | Retrieve token from Vault |

### Example

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/sonar/sonar@5
    inputs:
      sonar-url: "https://sonarqube.example.com"
      project-key: "my-project"
      quality-gate-enabled: true

variables:
  SONAR_TOKEN: $SONAR_TOKEN  # From CI/CD variables
```

---

### Gitleaks

**Template**: `to-be-continuous/gitleaks`
**Prefix**: `GITLEAKS_`

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `GITLEAKS_IMAGE` | Gitleaks Docker image | - |
| `GITLEAKS_CONFIG` | Configuration rules | - |
| `GITLEAKS_OPTS` | Gitleaks options | - |

Detects hardcoded secrets in Git repositories.

---

### DefectDojo

**Template**: `to-be-continuous/defectdojo`
**Prefix**: `DEFECTDOJO_`

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DEFECTDOJO_IMAGE` | Import Docker image | - |
| `DEFECTDOJO_URL` | DefectDojo server URL | - |
| `DEFECTDOJO_DIR` | Working directory | `.` |
| `DEFECTDOJO_UPLOAD_NONPROD` | Upload non-prod reports | `false` |
| `DEFECTDOJO_TIMEZONE` | Timezone for imports | - |
| `DEFECTDOJO_SMTP_SERVER` | SMTP for notifications | - |
| `DEFECTDOJO_SEVERITIES` | Notification severities | - |

### Report Paths

Configure paths for each scanner type:
- `DEFECTDOJO_BANDIT_PATH`
- `DEFECTDOJO_DEPENDENCY_CHECK_PATH`
- `DEFECTDOJO_GITLEAKS_PATH`
- `DEFECTDOJO_HADOLINT_PATH`
- `DEFECTDOJO_MOBSF_PATH`
- `DEFECTDOJO_TRIVY_PATH`
- `DEFECTDOJO_ZAP_PATH`
- `DEFECTDOJO_SEMGREP_PATH`

---

### Dependency Track

**Template**: `to-be-continuous/dependency-track`
**Prefix**: `DEPTRACK_`
**CI/CD Component**: Yes

#### Variants

| Variant | Purpose |
|---------|---------|
| **Vault** | HashiCorp Vault secrets |

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DEPTRACK_SBOM_SCANNER_IMAGE` | SBOM Scanner image | - |
| `DEPTRACK_BASE_API_URL` | Dependency Track API URL | - |
| `DEPTRACK_PROJECT_PATH` | Target project path | `$CI_PROJECT_NAMESPACE//$CI_PROJECT_NAME` |
| `DEPTRACK_PATH_SEPARATOR` | Path separator | `//` |
| `DEPTRACK_MERGE` | Merge SBOM files | `false` |
| `DEPTRACK_SBOM_PATTERNS` | SBOM file patterns | - |
| `DEPTRACK_SHOW_FINDINGS` | Wait and display vulnerabilities | `false` |
| `DEPTRACK_RISK_SCORE_THRESHOLD` | Fail threshold | `-1` |

#### Secret Variables

- `DEPTRACK_API_KEY`: Dependency Track API key

#### Features

| Feature | Toggle Variable | Default |
|---------|-----------------|---------|
| Quality Gate | `DEPTRACK_QUALITY_GATE_ENABLED` | disabled |

---

### MobSF (Mobile Security Framework)

**Template**: `to-be-continuous/mobsf`
**Prefix**: `MOBSF_`

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `MOBSF_IMAGE` | MobSF request image | - |
| `MOBSF_URL` | MobSF server URL | - |
| `MOBSF_PACKAGE_FILE` | APK/IPA file | - |

### Features

| Feature | Enable Variable | Description |
|---------|----------------|-------------|
| Static Scan | `MOBSF_SCAN_ENABLED` | mobsfscan analysis |

---

### Spectral

**Template**: `to-be-continuous/spectral`
**Prefix**: `SPECTRAL_`

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SPECTRAL_IMAGE` | Spectral Docker image | - |
| `SPECTRAL_DOCUMENTS` | JSON/YAML files to lint | - |
| `SPECTRAL_OPTS` | CLI options | - |
| `SPECTRAL_DISABLED` | Disable job | `false` |

Lints OpenAPI and AsyncAPI specifications.

---

### SQLFluff

**Template**: `to-be-continuous/sqlfluff`
**Prefix**: `SQLFLUFF_`

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SQLFLUFF_IMAGE` | SQLFluff Docker image | - |
| `SQLFLUFF_DIR` | Working directory | `.` |
| `SQLFLUFF_LINT_OPTS` | Lint options | - |

---

## Packaging Templates (3)

### Docker

**Template**: `to-be-continuous/docker`
**Prefix**: `DOCKER_`
**CI/CD Component**: Yes

#### Variants

| Variant | Purpose |
|---------|---------|
| **Vault** | HashiCorp Vault secrets |
| **Google Cloud** | GCP Artifact Registry auth |
| **Amazon ECR** | AWS ECR authentication |

#### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DOCKER_BUILD_TOOL` | `kaniko`, `buildah`, `dind` | - |
| `DOCKER_KANIKO_IMAGE` | Kaniko image | - |
| `DOCKER_BUILDAH_IMAGE` | Buildah image | - |
| `DOCKER_DIND_IMAGE` | Docker client image | - |
| `DOCKER_DAEMON_IMAGE` | Docker daemon image | - |
| `DOCKER_SKOPEO_IMAGE` | Skopeo image | - |
| `DOCKER_FILE` | Dockerfile path | `Dockerfile` |
| `DOCKER_CONTEXT_PATH` | Build context | - |
| `DOCKER_CONFIG_FILE` | Config file path | - |
| `DOCKER_SNAPSHOT_IMAGE` | Snapshot image name | - |
| `DOCKER_RELEASE_IMAGE` | Release image name | - |
| `DOCKER_RELEASE_EXTRA_TAGS_PATTERN` | Extra tags pattern (regex) | - |
| `DOCKER_RELEASE_EXTRA_TAGS` | Extra tags | - |
| `DOCKER_BUILD_ARGS` | Build arguments | - |
| `DOCKER_LABELS` | Metadata labels | - |
| `DOCKER_SKOPEO_ARGS` | Skopeo copy arguments | - |
| `DOCKER_PROD_PUBLISH_STRATEGY` | `manual` or `auto` | `manual` |
| `DOCKER_REGISTRY_MIRROR` | Registry mirror URL | - |
| `DOCKER_REGISTRIES_CONF` | registries.conf (buildah) | - |
| `DOCKER_BUILD_CACHE_DISABLED` | Disable cache | `false` |
| `DOCKER_BUILD_CACHE_LOCATION` | Cache location | - |
| `DOCKER_PUSH_ARGS` | Push arguments | - |

### Features

| Feature | Enable Variable | Description |
|---------|----------------|-------------|
| Hadolint | `DOCKER_HADOLINT_DISABLED` to disable | Dockerfile linting |
| Health Check | `DOCKER_HEALTHCHECK_ENABLED` | Test image |
| Trivy | `DOCKER_TRIVY_ENABLED` | Vulnerability scan |
| SBOM | `DOCKER_SBOM_DISABLED` to disable | Syft SBOM |
| Cosign | `DOCKER_COSIGN_WHEN` | Image signing |

### Example

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/docker/docker@6
    inputs:
      build-tool: "kaniko"
      snapshot-image: "$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA"
      release-image: "$CI_REGISTRY_IMAGE:$CI_COMMIT_TAG"
      trivy-enabled: true
      cosign-when: "onrelease"
```

---

### Cloud Native Buildpacks

**Template**: `to-be-continuous/cnb`
**Prefix**: `CNB_`

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `CNB_BUILDER_IMAGE` | Builder image | - |
| `CNB_APP_ROOT` | App root in image | - |
| `CNB_APP_DIR` | Source directory | `.` |
| `CNB_PLATFORM_API` | Platform API version | - |
| `CNB_SNAPSHOT_IMAGE` | Snapshot image | - |
| `CNB_RELEASE_IMAGE` | Release image | - |

### Features

| Feature | Enable Variable | Description |
|---------|----------------|-------------|
| Trivy | `CNB_TRIVY_ENABLED` | Vulnerability scan |
| Publish | `CNB_PUBLISH_ENABLED` | Promote to release |

---

### Source-to-Image (S2I)

**Template**: `to-be-continuous/s2i`
**Prefix**: `S2I_`

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `S2I_DAEMON_IMAGE` | Docker daemon image | - |
| `S2I_SKOPEO_IMAGE` | Skopeo image | - |
| `S2I_VERSION` | S2I version | - |
| `S2I_PLATFORM` | Target platform | - |
| `S2I_BUILDER_IMAGE` | Builder image | - |
| `S2I_APP_DIR` | Source directory | `.` |
| `S2I_BUILD_FLAGS` | Build flags | - |
| `S2I_SNAPSHOT_IMAGE` | Snapshot image | - |
| `S2I_RELEASE_IMAGE` | Release image | - |

---

## Acceptance Testing Templates (10)

### Bruno

**Template**: `to-be-continuous/bruno`
**Prefix**: `BRUNO_`

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `BRUNO_IMAGE` | Bruno CLI image | - |
| `BRUNO_COLLECTION_PATTERN` | Collection directories | - |
| `BRUNO_BASE_URL` | Base URL to test | - |
| `BRUNO_OPTS` | Run options | - |
| `BRUNO_REVIEW_ENABLED` | Enable on review | `false` |

---

### Cypress

**Template**: `to-be-continuous/cypress`
**Prefix**: `CYPRESS_`

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `CYPRESS_IMAGE` | Cypress included image | - |
| `CYPRESS_PROJECT_DIR` | Project directory | - |
| `CYPRESS_OPTS` | Run options | - |
| `CYPRESS_REVIEW_ENABLED` | Enable on review | `false` |

---

### Hurl

**Template**: `to-be-continuous/hurl`
**Prefix**: `HURL_`

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `HURL_IMAGE` | Hurl Docker image | - |
| `HURL_FILES` | Test files | - |
| `HURL_OPTS` | Run options | - |
| `HURL_REVIEW_ENABLED` | Enable on review | `false` |

---

### k6

**Template**: `to-be-continuous/k6`
**Prefix**: `K6_`

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `K6_IMAGE` | k6 CLI image | - |
| `K6_TESTS_DIR` | Tests directory | - |
| `K6_OPTS` | Command-line options | - |
| `K6_REVIEW_ENABLED` | Enable on review | `false` |

---

### Lighthouse CI

**Template**: `to-be-continuous/lighthouse`
**Prefix**: `LIGHTHOUSE_`

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `LIGHTHOUSE_IMAGE` | Browser image | - |
| `LIGHTHOUSE_VERSION` | Lighthouse CI version | - |
| `LIGHTHOUSE_OPTS` | Autorun options | - |
| `LIGHTHOUSE_REVIEW_ENABLED` | Enable on review | `false` |

---

### Playwright

**Template**: `to-be-continuous/playwright`
**Prefix**: `PLAYWRIGHT_`

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PLAYWRIGHT_IMAGE` | Playwright image | - |
| `PLAYWRIGHT_PROJECT_DIR` | Project directory | - |
| `PLAYWRIGHT_EXTRA_REPORTERS` | Additional reporters | - |
| `PLAYWRIGHT_OPTS` | Run options | - |
| `PLAYWRIGHT_REVIEW_ENABLED` | Enable on review | `false` |
| `PLAYWRIGHT_INSTALL_EXTRA_OPTS` | npm ci options | - |

---

### Postman

**Template**: `to-be-continuous/postman`
**Prefix**: `POSTMAN_`

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `POSTMAN_IMAGE` | Postman CLI image | - |
| `POSTMAN_COLLECTION_PATTERN` | Collection files | - |
| `POSTMAN_OPTS` | Newman run options | - |
| `POSTMAN_REVIEW_ENABLED` | Enable on review | `false` |

---

### Puppeteer

**Template**: `to-be-continuous/puppeteer`
**Prefix**: `PUPPETEER_`

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PUPPETEER_IMAGE` | Puppeteer image | - |
| `PUPPETEER_PROJECT_DIR` | Project directory | - |
| `PUPPETEER_OPTS` | Jest options | - |
| `PUPPETEER_REVIEW_ENABLED` | Enable on review | `false` |

---

### Robot Framework

**Template**: `to-be-continuous/robotframework`
**Prefix**: `ROBOT_`
**CI/CD Component**: Yes

#### Variants

| Variant | Purpose |
|---------|---------|
| **Vault** | HashiCorp Vault secrets |

#### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ROBOT_IMAGE` | Robot Framework image | - |
| `ROBOT_TESTS_DIR` | Tests directory | - |
| `ROBOT_BROWSER` | Browser to use | - |
| `ROBOT_OPTS` | Additional options | - |
| `ROBOT_THREADS` | Number of threads | `1` |
| `ROBOT_PABOT_OPTS` | Pabot options | - |
| `ROBOT_XVFB_DEPTH` | Screen color depth | - |
| `ROBOT_XVFB_HEIGHT` | Screen height | - |
| `ROBOT_XVFB_WIDTH` | Screen width | - |
| `ROBOT_REVIEW_ENABLED` | Enable on review | `false` |

### Features

| Feature | Enable Variable | Description |
|---------|----------------|-------------|
| Lint | `ROBOT_LINT_DISABLED` to disable | robotframework-lint |

---

### TestSSL

**Template**: `to-be-continuous/testssl`
**Prefix**: `TESTSSL_`

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `TESTSSL_IMAGE` | TestSSL image | - |
| `TESTSSL_OPTS` | Command-line options | - |
| `TESTSSL_URL` | Server URL to test | - |
| `TESTSSL_REVIEW_ENABLED` | Enable on review | `false` |

---

## Other Templates (3)

### GitLab Butler (misc)

**Template**: `to-be-continuous/gitlab-butler`
**Prefix**: `BUTLER_`

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `BUTLER_IMAGE` | GitLab Butler image | - |
| `BUTLER_GROUP` | GitLab group to process | - |
| `BUTLER_PIPELINE_MAX_AGE` | Max pipeline age (days) | - |

Automates project cleanup.

---

### Renovate (misc)

**Template**: `to-be-continuous/renovate`
**Prefix**: `RENOVATE_`

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `RENOVATE_IMAGE` | Renovate image | - |
| `RENOVATE_ONBOARDING_CONFIG` | Onboarding config | - |
| `RENOVATE_AUTODISCOVER` | Enable autodiscovery | - |
| `RENOVATE_AUTODISCOVER_FILTER` | Filter pattern | - |

Automates dependency updates.

---

### Semantic Release (publish)

**Template**: `to-be-continuous/semantic-release`
**Prefix**: `SEMREL_`
**CI/CD Component**: Yes

#### Variants

| Variant | Purpose |
|---------|---------|
| **Vault** | HashiCorp Vault secrets |

#### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SEMREL_IMAGE` | semantic-release image | - |
| `SEMREL_VERSION` | semantic-release version | - |
| `SEMREL_EXEC_VERSION` | @semantic-release/exec version | - |
| `SEMREL_CONFIG_DIR` | Configuration directory | - |
| `SEMREL_TAG_FORMAT` | Tag format | - |
| `SEMREL_PLUGINS_FILE` | Required plugins file | - |
| `SEMREL_RELEASE_ENABLED` | Enable release | - |
| `SEMREL_CHANGELOG_ENABLED` | Enable changelog | `false` |
| `SEMREL_CHANGELOG_FILE` | Changelog file | - |
| `SEMREL_CHANGELOG_TITLE` | Changelog title | - |
| `SEMREL_DRYRUN_ENABLED` | Dry run mode | `false` |
| `SEMREL_EXTRA_OPTS` | Extra options | - |
| `SEMREL_AUTO_RELEASE` | Auto-start job | `false` |
| `SEMREL_REF_PATTERN` | Release branch pattern | - |
| `SEMREL_SCRIPTS_DIR` | Hook scripts directory | - |

### Variants

| Variant | Description |
|---------|-------------|
| Vault | Retrieve tokens from Vault |

#### Features

| Feature | Toggle Variable | Default |
|---------|-----------------|---------|
| Semantic Release | `SEMREL_RELEASE_DISABLED` | disabled |
| semantic-release-info | - | disabled |

#### Example

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/semantic-release/semantic-release@5
    inputs:
      changelog-enabled: true
      auto-release: true
      ref-pattern: "^(main|master|develop)$"
```

---

## Variants Summary

Templates with variant support in this file:

| Template | Category | Vault | GCP | ECR |
|----------|----------|:-----:|:---:|:---:|
| SonarQube | analyse | Yes | - | - |
| DefectDojo | analyse | Yes | - | - |
| Dependency Track | analyse | Yes | - | - |
| Docker | package | Yes | Yes | Yes |
| Robot Framework | acceptance | Yes | - | - |
| Semantic Release | publish | Yes | - | - |

---

## Acceptance Test Environment Pattern

All acceptance test templates support enabling tests on specific environments:

```yaml
inputs:
  # Run on review environments
  review-enabled: true

  # Run on integration environment
  integ-enabled: true

  # Run on staging environment
  staging-enabled: true

  # Run on production (usually disabled)
  prod-enabled: false
```

The `{PREFIX}_REVIEW_ENABLED` pattern applies to:
- Bruno, Cypress, Hurl, k6, Lighthouse
- Playwright, Postman, Puppeteer, Robot Framework, TestSSL
