# Build Templates Reference

Complete configuration reference for all TBC build/language templates.

---

## Angular

**Template**: `to-be-continuous/angular`
**Prefix**: `NG_`
**Latest Version**: 4.10.2
**CI/CD Component**: Yes

### Variables

| Variable | Description | Default | Type |
|----------|-------------|---------|------|
| `NG_CLI_IMAGE` | Docker image for Angular-CLI (`ng`) - **set version required** | `docker.io/trion/ng-cli-karma:latest` | text |
| `NPM_CONFIG_REGISTRY` | NPM registry URL | - | url |
| `NPM_CONFIG_SCOPED_REGISTRIES` | Space-separated scoped registries (`@scope:url @scope2:url2`) | - | text |
| `NG_WORKSPACE_DIR` | Angular workspace directory | `.` | text |
| `NG_INSTALL_EXTRA_OPTS` | Extra `npm ci` options | - | text |
| `NG_BUILD_ARGS` | ng build arguments | `build` | text |
| `NG_TEST_ARGS` | ng test arguments | `test --code-coverage --reporters progress,junit --watch=false --no-progress` | text |

### Features

| Feature | Toggle Variable | Description |
|---------|----------------|-------------|
| **Angular Lint** | `NG_LINT_DISABLED` | ng lint analysis |
| **Publish** | `NG_PUBLISH_ENABLED` | Publish packages to npm registry |
| **E2E Tests** | `NG_E2E_ENABLED` | Run e2e tests |
| **Outdated** | `NG_OUTDATED_DISABLED` | npm outdated analysis |
| **Audit** | `NG_AUDIT_DISABLED` | npm audit security scan |
| **SBOM** | `NG_SBOM_DISABLED` | CycloneDX SBOM generation |

#### Feature Variables

**Publish:**
- `NG_PUBLISH_ARGS` - npm publish arguments
- `NG_PUBLISH_PROJECTS` - Projects to publish (space-separated)
- `NPM_PUBLISH_REGISTRY` - Target registry (secret)
- `NPM_PUBLISH_TOKEN` - Auth token (secret)

**SBOM:**
- `NG_SBOM_VERSION` - cyclonedx-npm version
- `NG_SBOM_OPTS` - Options (`--omit dev` default)

### Example

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/angular/angular@4
    inputs:
      cli-image: "docker.io/trion/ng-cli-karma:18"
      lint-disabled: false
      publish-enabled: true
      e2e-enabled: true
```

---

## Bash

**Template**: `to-be-continuous/bash`
**Prefix**: `BASH_`
**Latest Version**: 3.5.2
**CI/CD Component**: Yes

### Features

| Feature | Toggle Variable | Description |
|---------|----------------|-------------|
| **ShellCheck** | `BASH_SHELLCHECK_DISABLED` | Static analysis with ShellCheck |
| **Bats** | `BASH_BATS_ENABLED` | Testing with Bats framework |

#### ShellCheck Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `BASH_SHELLCHECK_IMAGE` | ShellCheck Docker image | - |
| `BASH_SHELLCHECK_FILES` | Files/patterns to analyze | - |
| `BASH_SHELLCHECK_OPTS` | ShellCheck options | - |

#### Bats Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `BASH_BATS_IMAGE` | Bats Docker image | - |
| `BASH_BATS_TESTS` | Test file/directory path | - |
| `BASH_BATS_OPTS` | Bats options | - |
| `BASH_BATS_LIBRARIES` | Libraries (`lib@url lib2@url2`) | - |
| `BASH_BATS_COVERAGE_ENABLED` | Enable Bashcov coverage | `false` |
| `BASH_BATS_COVERAGE_FILES` | Coverage file patterns | - |

### Example

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/bash/bash@3
    inputs:
      shellcheck-disabled: false
      bats-enabled: true
      bats-tests: "tests/"
```

---

## DBT (Data Build Tool)

**Template**: `to-be-continuous/dbt`
**Prefix**: `DBT_`
**Latest Version**: 4.1.0
**CI/CD Component**: Yes

### Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `DBT_IMAGE` | dbt Docker image | `ghcr.io/dbt-labs/dbt-core:latest` | No |
| `DBT_PROJECT_DIR` | dbt_project.yml directory | `.` | No |
| `DBT_PROFILES_DIR` | Profile location | `.` | No |
| `DBT_ADAPTER` | Database adapter (postgres, snowflake, etc.) | - | **Yes** |
| `DBT_TARGET` | Target environment | - | No |
| `DBT_BUILD_ARGS` | dbt CLI arguments | - | No |

### Features

| Feature | Toggle Variable | Description |
|---------|----------------|-------------|
| **SQLFluff Lint** | `DBT_SQLFLUFF_ENABLED` | SQL linting |
| **dbt Deploy** | `DBT_DEPLOY_ENABLED` | Execute models on target |
| **Review** | auto | Dynamic review environments |
| **Integration** | auto | Integration environment |
| **Staging** | auto | Staging environment |
| **Production** | auto | Production environment |

#### Environment Variables

| Variable | Description |
|----------|-------------|
| `DBT_REVIEW_TARGET` | dbt target for review env |
| `DBT_INTEG_TARGET` | dbt target for integration env |
| `DBT_STAGING_TARGET` | dbt target for staging env |
| `DBT_PROD_TARGET` | dbt target for production env |
| `DBT_PROD_DEPLOY_STRATEGY` | Deployment strategy (`manual`/`auto`) |

### Variants

| Variant | Description |
|---------|-------------|
| **GitLab Pages** | Publish generated docs to GitLab Pages |
| **Google Cloud** | OAuth access token via Workload Identity |

### Example

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/dbt/dbt@4
    inputs:
      adapter: "postgres"
      sqlfluff-enabled: true
      deploy-enabled: true
```

---

## GitLab Package

**Template**: `to-be-continuous/gitlab-package`
**Prefix**: `GLPKG_`
**Latest Version**: 1.2.2
**CI/CD Component**: Yes

### Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `GLPKG_IMAGE` | Docker image for publishing | `docker.io/curlimages/curl:latest` | No |
| `GLPKG_FILES` | Glob patterns for files to include | - | **Yes** |
| `GLPKG_PACKAGE` | Package name | `$CI_PROJECT_NAME` | No |

### Example

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/gitlab-package/gitlab-package@1
    inputs:
      files: "dist/*.tar.gz"
      package: "my-package"
```

---

## Go

**Template**: `to-be-continuous/golang`
**Prefix**: `GO_`
**Latest Version**: 4.11.1
**CI/CD Component**: Yes

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `GO_IMAGE` | Go Docker image - **set version required** | `docker.io/library/golang:bookworm` |
| `GO_PROJECT_DIR` | Project root directory | `.` |
| `GOPROXY` | Module proxy URL | - |
| `GO_TEST_IMAGE` | Separate test image | - |
| `GO_BUILD_FLAGS` | go build flags | `-mod=readonly` |
| `GO_BUILD_MODE` | `application`, `modules`, `auto` | `auto` |
| `GO_BUILD_LINKER_FLAGS` | Linker flags (-ldflags) | `-s -w` |
| `GO_BUILD_PACKAGES` | Packages to build | `./...` |
| `GO_TARGET_OS` | Target GOOS | - |
| `GO_TARGET_ARCH` | Target GOARCH | - |
| `GO_TEST_FLAGS` | go test flags | `-mod=readonly -v -race` |
| `GO_TEST_PACKAGES` | Packages to test | `./...` |
| `GO_COBERTURA_FLAGS` | Coverage flags | - |

### Features

| Feature | Toggle Variable | Description |
|---------|----------------|-------------|
| **go generate** | auto | Code generation with go generate |
| **GolangCI-Lint** | `GO_CI_LINT_DISABLED` | Linting with golangci-lint |
| **Go-mod-outdated** | auto | Dependency update check |
| **SBOM** | `GO_SBOM_DISABLED` | CycloneDX SBOM |
| **Semgrep** | `GO_SEMGREP_DISABLED` | SAST analysis |
| **Govulncheck** | `GO_VULNCHECK_DISABLED` | Vulnerability scanning |

#### Feature Variables

**go generate:**
- `GO_GENERATE_MODULES` - Generator modules (space-separated)

**GolangCI-Lint:**
- `GO_CI_LINT_IMAGE` - Docker image
- `GO_CI_LINT_ARGS` - CLI arguments

**Semgrep:**
- `GO_SEMGREP_IMAGE` - Docker image
- `GO_SEMGREP_ARGS` - Scan options
- `GO_SEMGREP_RULES` - Rules (space-separated)

### Example

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/golang/golang@4
    inputs:
      image: "golang:1.22"
      build-mode: "application"
      target-os: "linux"
      target-arch: "amd64"
      ci-lint-disabled: false
      vulncheck-disabled: false
```

---

## Gradle

**Template**: `to-be-continuous/gradle`
**Prefix**: `GRADLE_`
**Latest Version**: 2.8.0
**CI/CD Component**: Yes

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `GRADLE_IMAGE` | Gradle Docker image - **set version required** | `docker.io/library/gradle:latest` |
| `GRADLE_CLI_OPTS` | Additional Gradle options | - |
| `GRADLE_CLI_BIN` | Gradle binary location (`gradlew` for wrapper) | `gradle` |
| `GRADLE_USER_HOME` | Gradle user home | `$CI_PROJECT_DIR/.gradle` |
| `GRADLE_DAEMON` | Use Gradle daemon | `false` |
| `GRADLE_BUILD_ARGS` | Build & test arguments | `build` |
| `GRADLE_PROJECT_DIR` | Project root directory | `.` |
| `JACOCO_CSV_REPORT` | Coverage report name | `jacocoTestReport.csv` |

### Features

| Feature | Toggle Variable | Description |
|---------|----------------|-------------|
| **SonarQube** | auto | Code analysis |
| **Dependency Check** | `GRADLE_DEPENDENCY_CHECK_DISABLED` | Security scan |
| **SBOM** | `GRADLE_SBOM_DISABLED` | CycloneDX SBOM |
| **Publish** | `GRADLE_NO_PUBLISH` to disable | Artifact publishing |

#### SonarQube Variables

| Variable | Description |
|----------|-------------|
| `SONAR_HOST_URL` | SonarQube server URL |
| `SONAR_TOKEN` | Authentication token (secret) |
| `SONAR_BASE_ARGS` | Analysis arguments |
| `SONAR_QUALITY_GATE_ENABLED` | Enable quality gate |

### Example

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/gradle/gradle@2
    inputs:
      image: "gradle:8-jdk21"
      cli-bin: "gradlew"
      dependency-check-disabled: false
```

---

## GNU Make

**Template**: `to-be-continuous/make`
**Prefix**: `MAKE_`
**Latest Version**: 1.4.1
**CI/CD Component**: Yes

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `MAKE_IMAGE` | Docker image - **set image required** | `docker.io/alpinelinux/build-base` |
| `MAKE_BUILD_ARGS` | Make options and goals | `all test` |
| `MAKE_PROJECT_DIR` | Makefile directory | `.` |

### Example

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/make/make@1
    inputs:
      image: "ubuntu:22.04"
      build-args: "clean build test"
```

---

## Maven

**Template**: `to-be-continuous/maven`
**Prefix**: `MAVEN_`
**Latest Version**: 4.0.1
**CI/CD Component**: Yes

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `MAVEN_IMAGE` | Maven Docker image - **set version required** | `docker.io/library/maven:latest` |
| `MAVEN_PROJECT_DIR` | Project root directory | `.` |
| `MAVEN_CFG_DIR` | Configuration directory | `.m2` |
| `MAVEN_SETTINGS_FILE` | settings.xml path | `$MAVEN_CFG_DIR/settings.xml` |
| `MAVEN_OPTS` | JVM options | `-Dhttps.protocols=TLSv1.2 ...` |
| `MAVEN_CLI_OPTS` | CLI options | `--no-transfer-progress --batch-mode ...` |
| `MAVEN_BUILD_ARGS` | Build & test arguments | `org.jacoco:jacoco-maven-plugin:prepare-agent verify org.jacoco:jacoco-maven-plugin:report` |

### Features

| Feature | Toggle Variable | Description |
|---------|----------------|-------------|
| **SonarQube** | auto | Code analysis |
| **Dependency-Check** | `MAVEN_DEPENDENCY_CHECK_DISABLED` | Security scan |
| **Snapshot Check** | `MVN_FORBID_SNAPSHOT_DEPENDENCIES_DISABLED` | Verify no snapshots |
| **SBOM** | `MAVEN_SBOM_DISABLED` | CycloneDX SBOM |
| **Publish** | `MAVEN_DEPLOY_ENABLED` | Deploy artifacts |

#### Publish Variables

| Variable | Description |
|----------|-------------|
| `MAVEN_DEPLOY_ARGS` | Deploy job arguments |
| `MAVEN_DEPLOY_FROM_UNPROTECTED_DISABLED` | Limit to protected branches |
| `MAVEN_DEPLOY_SNAPSHOT_WITH_SLUG_ENABLED` | Include branch slug in version |
| `MAVEN_RELEASE_ARGS` | Release job arguments |
| `MAVEN_RELEASE_VERSION` | Explicit release version |

### Variants

| Variant | Description |
|---------|-------------|
| **Jib** | Build Docker/OCI images with Jib |

### Example

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/maven/maven@4
    inputs:
      image: "maven:3.9-eclipse-temurin-21"
      deploy-enabled: true
```

---

## MkDocs

**Template**: `to-be-continuous/mkdocs`
**Prefix**: `MKD_`
**Latest Version**: 2.7.0
**CI/CD Component**: Yes

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `MKD_IMAGE` | MkDocs Docker image | `docker.io/squidfunk/mkdocs-material:latest` |
| `MKD_BUILD_ARGS` | Build arguments | - |
| `MKD_WORKSPACE_DIR` | Sources directory | `.` |
| `MKD_SITE_DIR` | Output directory | `site` |
| `MKD_REQUIREMENTS_FILE` | Requirements file | `requirements.txt` |
| `MKD_REQUIREMENTS` | Space-separated requirements | `mkdocs` |
| `MKD_PREBUILD_SCRIPT` | Pre-build hook script | `mkdocs-pre-build.sh` |
| `PIP_OPTS` | pip extra options | - |

### Features

| Feature | Toggle Variable | Description |
|---------|----------------|-------------|
| **Lychee** | `MKD_LYCHEE_ENABLED` | Link checking |

### Variants

| Variant | Description |
|---------|-------------|
| **GitLab Pages** | Publish to GitLab Pages |

---

## Node.js

**Template**: `to-be-continuous/node`
**Prefix**: `NODE_`
**Latest Version**: 4.1.1
**CI/CD Component**: Yes

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `NODE_IMAGE` | Node.js Docker image - **set version required** | `docker.io/library/node:lts-alpine` |
| `NODE_MANAGER` | Package manager: `npm`, `yarn`, `pnpm`, `auto` | `auto` |
| `NODE_PROJECT_DIR` | Project root directory | `.` |
| `NODE_SOURCE_DIR` | Sources directory | `src` |
| `NODE_CONFIG_REGISTRY` | npm registry URL | - |
| `NODE_CONFIG_SCOPED_REGISTRIES` | Scoped registries | - |
| `NODE_BUILD_DISABLED` | Disable build | `false` |
| `NODE_BUILD_ARGS` | Run script arguments | `run build --prod` |
| `NODE_BUILD_DIR` | Build output directory | `dist` |
| `NODE_TEST_ARGS` | Test arguments | `test -- --coverage` |
| `NODE_INSTALL_EXTRA_OPTS` | Install options | - |

### Features

| Feature | Toggle Variable | Description |
|---------|----------------|-------------|
| **Lint** | `NODE_LINT_ENABLED` | ESLint analysis |
| **Audit** | `NODE_AUDIT_DISABLED` | Security audit |
| **Outdated** | `NODE_OUTDATED_DISABLED` | Dependency check |
| **Semgrep** | `NODE_SEMGREP_DISABLED` | SAST analysis |
| **SBOM** | `NODE_SBOM_DISABLED` | CycloneDX SBOM |
| **Publish** | `NODE_PUBLISH_ENABLED` | npm publish |

### Variants

| Variant | Description |
|---------|-------------|
| **Vault** | Retrieve secrets from Vault |

### Example

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/node/node@4
    inputs:
      image: "node:20-alpine"
      manager: "pnpm"
      lint-enabled: true
      publish-enabled: true
```

---

## PHP

**Template**: `to-be-continuous/php`
**Prefix**: `PHP_`
**Latest Version**: 4.8.0
**CI/CD Component**: Yes

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PHP_IMAGE` | PHP Docker image - **set version required** | `docker.io/library/php:latest` |
| `PHP_PROJECT_DIR` | Project root directory | `.` |

### Features

| Feature | Toggle Variable | Description |
|---------|----------------|-------------|
| **PHPUnit** | `PHP_UNIT_DISABLED` | Unit tests (auto-enabled if phpunit.xml exists) |
| **PHP_CodeSniffer** | `PHP_CODESNIFFER_DISABLED` | Code standards |
| **SBOM** | `PHP_SBOM_DISABLED` | CycloneDX SBOM |
| **Outdated** | auto | composer outdated |
| **Audit** | `PHP_COMPOSER_AUDIT_DISABLED` | Security audit |

---

## pre-commit

**Template**: `to-be-continuous/pre-commit`
**Prefix**: `PRE_COMMIT_`
**Latest Version**: 1.1.1
**CI/CD Component**: Yes

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PRE_COMMIT_IMAGE` | Docker image | `docker.io/library/python:3-alpine` |

### Features

| Feature | Toggle Variable | Description |
|---------|----------------|-------------|
| **pre-commit run** | `PRE_COMMIT_DISABLED` | Run pre-commit hooks |

#### Feature Variables

| Variable | Description |
|----------|-------------|
| `PRE_COMMIT_ARGS` | Additional arguments |
| `PRE_COMMIT_SKIP` | Hooks to skip (SKIP env var) |
| `PRE_COMMIT_FILE` | Config file to use |

### Example

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/pre-commit/pre-commit@1
    inputs:
      disabled: false
```

---

## Python

**Template**: `to-be-continuous/python`
**Prefix**: `PYTHON_`
**Latest Version**: 7.5.2
**CI/CD Component**: Yes

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PYTHON_IMAGE` | Python Docker image - **set version required** | `docker.io/library/python:3-slim` |
| `PYTHON_PROJECT_DIR` | Project root directory | `.` |
| `PYTHON_BUILD_SYSTEM` | `requirements`, `setuptools`, `poetry`, `auto` | `auto` |
| `PYTHON_REQS_FILE` | Main requirements file | `requirements.txt` |
| `PYTHON_EXTRA_REQS_FILES` | Dev requirements files | `requirements-dev.txt` |
| `PYTHON_COMPILE_ARGS` | compileall options | `*` |
| `PIP_OPTS` | pip extra options | - |
| `PYTHON_EXTRA_DEPS` | Extra dependencies (setuptools/poetry extras) | - |

### Features

| Feature | Toggle Variable | Description |
|---------|----------------|-------------|
| **Package** | `PYTHON_PACKAGE_ENABLED` | Build distribution packages |
| **Pylint** | `PYLINT_ENABLED` | Code analysis |
| **Unittest** | `UNITTEST_ENABLED` | unittest framework |
| **Pytest** | `PYTEST_ENABLED` | pytest framework |
| **Nose** | `NOSETESTS_ENABLED` | nose framework |
| **Bandit** | `BANDIT_ENABLED` | SAST analysis |
| **Trivy** | `PYTHON_TRIVY_DISABLED` | Vulnerability scan |
| **SBOM** | `PYTHON_SBOM_DISABLED` | Syft SBOM |
| **Release** | `PYTHON_RELEASE_ENABLED` | bump-my-version release |
| **Black** | `PYTHON_BLACK_ENABLED` | Code formatting |
| **isort** | `PYTHON_ISORT_ENABLED` | Import sorting |
| **Ruff** | `RUFF_ENABLED` | Linter |
| **Ruff Format** | `RUFF_FORMAT_ENABLED` | Formatter |
| **Mypy** | `MYPY_ENABLED` | Type checking |

### Variants

| Variant | Description |
|---------|-------------|
| **Vault** | Retrieve secrets from Vault |
| **Google Cloud** | ADC authentication |
| **AWS CodeArtifact** | AWS CodeArtifact credentials |

### Example

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/python/python@7
    inputs:
      image: "python:3.12-slim"
      build-system: "poetry"
      pytest-enabled: true
      bandit-enabled: true
      ruff-enabled: true
      mypy-enabled: true
```

---

## Scala/SBT

**Template**: `to-be-continuous/sbt`
**Prefix**: `SBT_`
**Latest Version**: 1.7.1
**CI/CD Component**: Yes

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SBT_IMAGE` | sbt Docker image - **set version required** | `docker.io/sbtscala/scala-sbt:17.0.2_1.6.2_3.1.3` |
| `SBT_BUILD_ARGS` | Package arguments | `clean package` |
| `SBT_TEST_ARGS` | Test arguments | `coverage test coverageAggregate` |
| `SBT_OPTS` | Global sbt options | (various cache settings) |
| `SBT_CLI_OPTS` | CLI options | `--batch` |

### Features

| Feature | Toggle Variable | Description |
|---------|----------------|-------------|
| **SBOM** | `SBT_SBOM_DISABLED` | Syft SBOM |
| **Publish** | auto | Snapshot & release publishing |

#### Publish Variables

| Variable | Description |
|----------|-------------|
| `SBT_PUBLISH_MODE` | `snapshot`, `ontag`, `release` |
| `MAVEN_REPOSITORY_HOST` | Repository host |
| `MAVEN_RELEASE_REPOSITORY_URL` | Release repo URL |
| `MAVEN_SNAPSHOT_REPOSITORY_URL` | Snapshot repo URL |

---

## Sphinx

**Template**: `to-be-continuous/sphinx`
**Prefix**: `SPHINX_`
**Latest Version**: 1.2.0
**CI/CD Component**: Yes

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SPHINX_IMAGE` | Sphinx Docker image | `ghcr.io/sphinx-doc/sphinx:latest` |
| `SPHINX_BUILD_ARGS` | sphinx-build options | `-M html` |
| `SPHINX_PROJECT_DIR` | Project root directory | `.` |
| `SPHINX_SOURCE_DIR` | Source directory (relative) | `source` |
| `SPHINX_BUILD_DIR` | Build output directory | `build` |
| `SPHINX_REQUIREMENTS_FILE` | Requirements file | `requirements.txt` |
| `SPHINX_REQUIREMENTS` | Space-separated requirements | - |
| `SPHINX_PREBUILD_SCRIPT` | Pre-build hook script | `sphinx-pre-build.sh` |

### Features

| Feature | Toggle Variable | Description |
|---------|----------------|-------------|
| **Lychee** | `SPHINX_LYCHEE_ENABLED` | Link checking |

### Variants

| Variant | Description |
|---------|-------------|
| **GitLab Pages** | Publish to GitLab Pages |

