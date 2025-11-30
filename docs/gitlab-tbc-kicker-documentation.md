# GitLab TBC Kicker - Configuration Tool Documentation

> **Source:** https://to-be-continuous.gitlab.io/kicker
>
> **Description:** This tool helps you generate the `.gitlab-ci.yml` file for your project using the To-Be-Continuous (TBC) framework.

---

## Table of Contents

1. [Build Templates](#1-build-templates)
2. [Code Analysis](#2-code-analysis)
3. [Packaging](#3-packaging)
4. [Infrastructure](#4-infrastructure)
5. [Deployment](#5-deployment)
6. [Acceptance Tests](#6-acceptance-tests)
7. [Other Tools](#7-other-tools)

---

## 1. Build Templates

### Angular

**Docker Image:**
- The Docker image used to run Angular-CLI (`ng`) - **set the version required by your project**

**Registry Configuration:**
- NPM [registry](https://docs.npmjs.com/configuring-your-registry-settings-as-an-npm-enterprise-user)
- Space separated list of NPM [scoped registries](https://docs.npmjs.com/cli/v8/using-npm/scope#associating-a-scope-with-a-registry)
  - Format: `@somescope:https://some.npm.registry/some/repo @anotherscope:https://another.npm.registry/another/repo`

**Workspace:**
- Angular workspace directory
- Extra options to install project dependencies (with [`npm ci`](https://docs.npmjs.com/cli/ci.html/))

**Build & Test:**
- Angular [ng build](https://angular.io/cli/build) arguments
- Angular [ng test](https://angular.io/cli/test) arguments

**Linting:**
- Angular lint analysis
- Angular [ng lint](https://angular.io/cli/lint) arguments

**Publishing:**
- [Publishes](https://docs.npmjs.com/cli/v6/commands/npm-publish) the project packages to an npm registry
- npm [publish](https://docs.npmjs.com/cli/v6/commands/npm-publish) arguments
- Space separated list of projects to publish (if none specified, all workspace projects are published)

**E2E Testing:**
- Run [e2e tests](https://angular.io/cli/e2e) on your Angular project
- ng [e2e](https://angular.io/cli/e2e) arguments

**Dependency Management:**
- Outdated analysis ([npm outdated](https://docs.npmjs.com/cli/v8/commands/npm-outdated))
- npm [outdated](https://docs.npmjs.com/cli/v8/commands/npm-outdated) arguments
- Allow job to fail and not block the pipeline

**Security:**
- Audit using ([npm audit](https://docs.npmjs.com/cli/v8/commands/npm-audit))
- npm [audit](https://docs.npmjs.com/cli/v8/commands/npm-audit) arguments

**SBOM (Software Bill of Materials):**
- Generates dependency file using [@cyclonedx/cyclonedx-npm](https://www.npmjs.com/package/@cyclonedx/cyclonedx-npm)
- Controls when SBOM reports are generated (`onrelease`: only on integration/production/release pipelines; `always`: any pipeline)
- Version of @cyclonedx/cyclonedx-npm
- Options for @cyclonedx/cyclonedx-npm

---

### Bash/Shell

**ShellCheck:**
- Analyse shell scripts with [ShellCheck](https://github.com/koalaman/shellcheck)
- Docker image for ShellCheck
- Shell file(s) or pattern(s) to analyse
- ShellCheck [options](https://github.com/koalaman/shellcheck/blob/master/shellcheck.1.md)

**Bats (Bash Automated Testing):**
- Test shell scripts with [Bats](https://bats-core.readthedocs.io/)
- Docker image for Bats
- Path to Bats test file or directory
- Bats [options](https://bats-core.readthedocs.io/en/stable/usage.html)
- Comma separated list of [libraries and add-ons](https://bats-core.readthedocs.io/en/stable/writing-tests.html#libraries-and-add-ons)
  - Format: `lib_name_1@archive_url_1 lib_name_2@archive_url_2`
  - Example: `bats-support@https://github.com/bats-core/bats-support/archive/v0.3.0.zip`

**Code Coverage:**
- Enable code coverage (uses [Bashcov](https://github.com/infertux/bashcov))
- Glob pattern of files to track coverage
- Comma separated list of [formatters](https://github.com/simplecov-ruby/simplecov/blob/main/doc/alternate-formatters.md)
  - Format: `package-name1@formatter-class1, package-name2@formatter-class2`
- Files/directories to filter out from coverage data

---

### DBT (Data Build Tool)

**Configuration:**
- Docker image for dbt CLI
- The [dbt_project.yml](https://docs.getdbt.com/reference/dbt_project.yml) directory
- dbt [profile](https://docs.getdbt.com/dbt-cli/configure-your-profile) location
- dbt [adapter](https://docs.getdbt.com/docs/available-adapters)
- dbt [target](https://docs.getdbt.com/reference/dbt-jinja-functions/target)
- [CLI arguments](https://docs.getdbt.com/reference/global-configs#command-line-flags)

**Code Quality:**
- Lint SQL with sqlfluff
- Lint [options and arguments](https://docs.sqlfluff.com/en/stable/reference/cli.html#sqlfluff-lint)
- Working directory scope

**Testing:**
- Unit testing on dbt project
- dbt test [options](https://docs.getdbt.com/reference/commands/test)

**Best Practices:**
- [dbt_project_evaluator](https://dbt-labs.github.io/dbt-project-evaluator)
- CLI arguments for evaluator

**Execution:**
- Execute generated SQL from models on target

**Environments:**
- **Review:** Dynamic review environments for topic branches
- **Integration:** CI environment for integration branch (`develop` by default)
- **Staging:** Iso-prod environment for testing
- **Production:** Production environment

Each environment supports:
- Custom dbt target
- Deployment strategy configuration

---

### .NET

**Configuration:**
- Docker image for .NET SDK - **set the version required by your project**
- [Build](https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-build) arguments
- Solution/project folder location
- Build output folder path

**NuGet:**
- Space separated list of [sources](https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-nuget-add-source)
  - Format: `somename:https://some.nuget.registry anothername:https://another.nuget.registry`

**Testing:**
- Enable/disable tests execution
- Unit tests folder location
- [Test](https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-test) extra arguments

**Code Analysis:**
- [Dotnet Sonar](https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/scanners/dotnet/using) analysis
- SonarQube server URL
- SonarQube Project Key
- [SonarScanner](https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/scanners/dotnet/using/#analysis-steps) extra arguments

**Publishing:**
- Docker image for package publishing
- Glob patterns for files to include (⚠️ does not support double star)
- Package name

---

### Go

**Configuration:**
- Docker image for Go (build+test or build only) - **set version required**
- Project root directory
- URL of Go module proxy (see [Go env](https://golang.org/cmd/go/#hdr-Environment_variables))
- Specific Docker image for Go tests

**Build:**
- [go build](https://pkg.go.dev/cmd/go#hdr-Compile_packages_and_dependencies) flags
- Build mode: `application`, `modules`, or `auto`
- Linker flags for `-ldflags`
- Packages to build
- Target `$GOOS` ([available values](https://gist.github.com/asukakenji/f15ba7e588ac42795f421b48b8aede63))
- Target `$GOARCH` ([available values](https://gist.github.com/asukakenji/f15ba7e588ac42795f421b48b8aede63))

**Testing:**
- [go test](https://pkg.go.dev/cmd/go#hdr-Test_packages) flags
- Packages to test
- List command arguments
- Build flags for gocover-cobertura

**Code Generation:**
- Generate code with [go generate](https://go.dev/blog/generate)
- Space separated list of generator modules (e.g., `stringer mockery`)

**Code Quality:**
- [GolangCI-Lint](https://github.com/golangci/golangci-lint) analysis
- Docker image for golangci-lint
- [Command line arguments](https://github.com/golangci/golangci-lint#command-line-options)

**Dependency Management:**
- [Go-mod-outdated](https://github.com/psampaz/go-mod-outdated) analysis
- Command line arguments

**SBOM:**
- Generates file using [cyclonedx-gomod](https://github.com/CycloneDX/cyclonedx-gomod)
- Controls when reports are generated
- Docker image for cyclonedx-gomod
- Options for SBOM analysis

**Security:**
- [Semgrep](https://semgrep.dev/docs/) analysis
- Docker image for Semgrep
- [Scan options](https://semgrep.dev/docs/cli-reference#semgrep-scan-command-options)
- Space-separated list of [rules](https://semgrep.dev/docs/running-rules)
- Download remote rules option

**Vulnerability Management:**
- [Govulncheck](https://go.dev/blog/vuln)
- Command line arguments

---

### Gradle

**Configuration:**
- Docker image for Gradle - **set version required**
- Additional Gradle command line options
- Gradle binary location (or [gradle wrapper](https://docs.gradle.org/current/userguide/gradle_wrapper.html))
- Gradle user home
- Enable/disable gradle daemon
- Build & test arguments
- Project root directory

**Coverage:**
- Code coverage report name

**Code Quality:**
- [SonarQube](https://www.sonarqube.org/) analysis
- SonarQube server URL
- [Analysis arguments](https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/analysis-parameters/)
- Enable [Quality Gate](https://docs.sonarsource.com/sonarqube-server/latest/quality-standards-administration/managing-quality-gates/introduction/) verification

**Dependency Check:**
- Run dependency check
- Dependency-check task to invoke

**SBOM:**
- Generates file using [cyclonedx-gradle-plugin](https://github.com/CycloneDX/cyclonedx-gradle-plugin)
- Controls when reports are generated
- Plugin version
- Maven Repository for plugin download

**Publishing:**
- Enable publishing to artifacts repository
- Publish task to invoke
- Version value (propagated as gradle property)

---

### Make

**Configuration:**
- Docker image for GNU Make - **set image required** (see doc)
- Make [options](https://www.gnu.org/software/make/manual/html_node/Options-Summary.html) and [goals](https://www.gnu.org/software/make/manual/html_node/Goals.html)
- Makefile root directory

---

### Maven

**Configuration:**
- Docker image for Maven - **set version required**
- Project root directory
- Maven configuration directory
- `settings.xml` file path
- [Global Maven options](http://maven.apache.org/configure.html#maven_opts-environment-variable) (MAVEN_OPTS)
- Additional [command line options](https://maven.apache.org/ref/3-LATEST/maven-embedder/cli.html)
- Build & test arguments

**Code Quality:**
- [SonarQube](https://www.sonarqube.org/) analysis
- SonarQube server URL
- [Analysis arguments](https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/analysis-parameters/)
- Enable [Quality Gate](https://docs.sonarsource.com/sonarqube-server/latest/quality-standards-administration/managing-quality-gates/introduction/) verification

**Security:**
- [Dependency-Check](https://jeremylong.github.io/DependencyCheck/dependency-check-maven/configuration.html) analysis
- Maven arguments for Dependency Check

**Dependency Management:**
- Verify no snapshot dependencies
- Failure allowed in feature branches

**SBOM:**
- Generates file using [cyclonedx-maven-plugin](https://github.com/CycloneDX/cyclonedx-maven-plugin)
- Controls when reports are generated
- Maven command for SBOM analysis

**Publishing:**
- Publish [Snapshots](https://maven.apache.org/plugins/maven-deploy-plugin/) & [Releases](http://maven.apache.org/maven-release/maven-release-plugin)
- Deploy job arguments
- Limit snapshot publication to protected branches
- Inject Git branch slug in SNAPSHOT versions

**Release:**
- Release job arguments
- Explicit version for triggered release
- [scmCommentPrefix](https://maven.apache.org/maven-release/maven-release-plugin/prepare-mojo.html#scmCommentPrefix)
- [scmReleaseCommitComment](https://maven.apache.org/maven-release/maven-release-plugin/prepare-mojo.html#scmReleaseCommitComment)
- [scmDevelopmentCommitComment](https://maven.apache.org/maven-release/maven-release-plugin/prepare-mojo.html#scmDevelopmentCommitComment)
- Disable semantic-release integration

---

### MkDocs

**Configuration:**
- Docker image for MkDocs
- Build job arguments
- Sources directory
- Generated site directory
- Requirements file path
- Space separated requirements (if no file found)

**Hooks:**
- Pre-build hook script
- pip extra [options](https://pip.pypa.io/en/stable/cli/pip/#general-options)

**Link Checking:**
- Check broken links/emails with [lychee](https://github.com/lycheeverse/lychee)
- Docker image for lychee
- [lychee arguments](https://github.com/lycheeverse/lychee#commandline-parameters)

---

### Node.js/npm

**Configuration:**
- npm [registry](https://docs.npmjs.com/cli/v8/using-npm/registry)
- Docker image for Node.js - **set version required**
- Package manager: npm, yarn, or pnpm (auto-detect if undefined)
- Project root directory
- Sources directory
- Space separated list of [scoped registries](https://docs.npmjs.com/cli/v8/using-npm/scope#associating-a-scope-with-a-registry)

**Build:**
- Disable build option
- npm/yarn/pnpm [run script](https://docs.npmjs.com/cli/v8/commands/npm-run-script) arguments
- Build directory
- Install dependencies extra options

**Testing:**
- npm/yarn/pnpm [test](https://docs.npmjs.com/cli/v8/commands/npm-test) arguments

**Code Quality:**
- [ESLint](https://eslint.org/) analysis
- Run script arguments for lint

**Security:**
- npm/yarn/pnpm [audit](https://docs.npmjs.com/cli/v8/commands/npm-audit) arguments
- npm/yarn/pnpm [outdated](https://docs.npmjs.com/cli/v8/commands/npm-outdated) arguments

**Semgrep:**
- [Semgrep](https://semgrep.dev/docs/) analysis
- Docker image
- [Scan options](https://semgrep.dev/docs/cli-reference#semgrep-scan-command-options)
- Space-separated list of rules
- Semgrep Registry base URL
- Download remote rules

**SBOM:**
- Generates file using [@cyclonedx/cyclonedx-npm](https://www.npmjs.com/package/@cyclonedx/cyclonedx-npm)
- Controls when reports are generated
- Version of cyclonedx-npm
- Options for SBOM analysis

**Publishing:**
- [Publishes](https://docs.npmjs.com/cli/v8/commands/npm-publish) to npm registry
- npm/yarn/pnpm [publish](https://docs.npmjs.com/cli/v8/commands/npm-publish) extra arguments

---

### PHP

**Configuration:**
- Docker image for PHP - **set version required**
- Project root directory

**Testing:**
- [PHPUnit](https://docs.phpunit.de/) tests
- Auto-enabled if [XML configuration file](https://docs.phpunit.de/en/11.5/configuration.html#appendixes-configuration) found
- Additional [options](https://docs.phpunit.de/en/11.5/textui.html#command-line-options)

**Code Quality:**
- [PHP_CodeSniffer](https://github.com/squizlabs/PHP_CodeSniffer) analysis
- [Options](https://github.com/squizlabs/PHP_CodeSniffer/wiki/Configuration-Options)
- Use variable or [XML configuration file](https://github.com/squizlabs/PHP_CodeSniffer/wiki/Advanced-Usage#using-a-default-configuration-file)

**SBOM:**
- Generates file using [@cyclonedx/cyclonedx-php](https://github.com/CycloneDX/cyclonedx-php-composer)
- Controls when reports are generated
- Version of cyclonedx-php-composer
- Options for SBOM analysis

**Dependency Management:**
- Show outdated packages ([composer outdated](https://getcomposer.org/doc/03-cli.md#outdated))
- [composer outdated options](https://getcomposer.org/doc/03-cli.md#outdated)

**Security:**
- Scan dependencies with [composer audit](https://getcomposer.org/doc/03-cli.md#audit)
- [composer audit options](https://getcomposer.org/doc/03-cli.md#audit)

---

### Pre-commit

**Configuration:**
- Docker image for pre-commit
- ℹ️ Build pre-configured image to speed up (see documentation)
- [pre-commit](https://pre-commit.com/) analysis
- Additional arguments for `pre-commit run`
- `SKIP` environment variable to disable hooks
- Config file path

---

### Python

**Configuration:**
- Docker image for Python - **set version required**
- Project root directory
- Build-system: Requirements Files, Setuptools, or Poetry
- Main requirements file
- Extra dev requirements files
- [`compileall` CLI options](https://docs.python.org/3/library/compileall.html)
- pip extra [options](https://pip.pypa.io/en/stable/cli/pip/#general-options)
- Extra sets of dependencies (Setuptools/Poetry extras)

**Building & Publishing:**
- Build [distribution packages](https://packaging.python.org/en/latest/glossary/#term-Distribution-Package)
- Publish to PyPI compatible repository
- Target PyPI repository (defaults to GitLab packages)

**Code Quality:**
- [pylint](http://pylint.pycqa.org/en/latest/) analysis
- Additional [CLI options](http://pylint.pycqa.org/en/latest/user_guide/run.html#command-line-options)
- Files/directories to analyse
- Minimum [message level](https://pylint.readthedocs.io/en/latest/user_guide/messages/#messages-categories) to fail job

**Testing:**
- [unittest](https://docs.python.org/3/library/unittest.html) framework
- [pytest](https://docs.pytest.org/) framework
  - Additional [pytest](https://docs.pytest.org/en/stable/usage.html) or [pytest-cov](https://github.com/pytest-dev/pytest-cov#usage) options
- [nose](https://nose.readthedocs.io/) framework
  - Additional [nose options](https://nose.readthedocs.io/en/latest/usage.html#options)

**Security:**
- [Bandit](https://pypi.org/project/bandit/) analysis (SAST)
  - Additional [CLI options](https://github.com/PyCQA/bandit#usage)
- [Trivy](https://aquasecurity.github.io/trivy) vulnerability detection
  - URL to tar.gz package
  - Additional [CLI options](https://aquasecurity.github.io/trivy/latest/docs/references/configuration/cli/trivy_filesystem/)

**SBOM:**
- Generates file using [syft](https://github.com/anchore/syft)
- Controls when reports are generated
- URL to tar.gz package for Syft
- Component name
- Syft options

**Release:**
- Manual release trigger using [bump-my-version](https://github.com/callowayproject/bump-my-version)
- Auto-start when set
- Version part to increase: `major`, `minor`, or `patch`
- Disable semantic-release integration
- Git commit message template
- Additional patterns to commit

**Additional Tools:**
- [black](https://black.readthedocs.io) code formatting
- [isort](https://pycqa.github.io/isort) imports ordering
- [Ruff](https://docs.astral.sh/ruff/) linter and formatter
  - [Linter CLI options](https://docs.astral.sh/ruff/configuration/#full-command-line-interface)
- [mypy](https://mypy.readthedocs.io/) type checking
  - Additional [CLI options](https://mypy.readthedocs.io/en/stable/command_line.html)
- [basedpyright](https://docs.basedpyright.com/) type checking
  - Additional [CLI options](https://docs.basedpyright.com/latest/configuration/command-line/)
  - Minimum message level to fail

---

### Scala/sbt

**Configuration:**
- Docker image for sbt - **set version required**
- sbt arguments for [build/packaging](https://www.scala-sbt.org/1.x/docs/Running.html#Common+commands)
- sbt arguments for [test phase](https://www.scala-sbt.org/1.x/docs/Running.html#Common+commands)
- Global [sbt options](https://www.scala-sbt.org/1.x/docs/Command-Line-Reference.html#sbt+JVM+options+and+system+properties)
- Additional command line options

**SBOM:**
- Generates file using [syft](https://github.com/anchore/syft)
- Controls when reports are generated
- Syft image
- Syft options

**Publishing:**
- Enable publishing to Nexus repository
- Publish mode: `snapshot`, `ontag`, or `release`
- Global Maven repository host
- Release artifacts Maven repository URL
- Snapshot artifacts Maven repository URL

---

### Sphinx

**Configuration:**
- Docker image for Sphinx
- [`sphinx-build` options](https://www.sphinx-doc.org/en/master/man/sphinx-build.html)
- Project root directory
- Source directory (containing `conf.py`)
- Build output directory
- Requirements file
- Space separated requirements (if no file found)
- Pre-build hook script
- pip extra [options](https://pip.pypa.io/en/stable/cli/pip/#general-options)

**Link Checking:**
- Check broken links/emails with [lychee](https://github.com/lycheeverse/lychee)
- Docker image for lychee
- [lychee arguments](https://github.com/lycheeverse/lychee#commandline-parameters)

---

## 2. Code Analysis

### DefectDojo

**Configuration:**
- Import security reports into [DefectDojo](https://www.defectdojo.org/)
- Variants: Vault integration for secrets
- Docker image for import
- DefectDojo server URL
- Working directory
- Upload reports from non-production branches
- Time zone for naming imports
- SMTP server for notifications (name:port)
- Severity list for notifications

**Report Paths:**
- Bandit JSON reports
- Dependency Check reports
- Gradle Dependency Check reports
- Gitleaks reports
- Hadolint reports
- MobSF reports
- MobSF scan reports
- NodeJSScan reports
- NPMAudit reports
- TestSSL reports
- Trivy reports
- Zap reports
- Zap template
- Semgrep reports
- Semgrep template

**SonarQube Export:**
- Enable delta analysis
- Support for versions < 7.3 (no security hotspots)
- Export all bugs or only vulnerabilities

---

### Dependency Track

**Configuration:**
- Identify and reduce software supply chain risk with [Dependency Track](https://dependencytrack.org/)
- Variants: Vault integration
- Container image with [SBOM Scanner](https://gitlab.com/to-be-continuous/tools/dt-sbom-scanner)
- Server base API URL (includes `/api`)
- Target project path
- Path separator
- Parent aggregation logic: ALL, TAG, LATEST, NONE
- Aggregation tag
- Project tags (comma separated)

**SBOM Processing:**
- Merge all SBOM files
- Output merged SBOM file (debugging)
- PURLs max length (`-1`: auto, `0`: no trim, `>0`: trim to size)
- SBOM file patterns (glob support)

**Analysis:**
- Wait for analysis and display vulnerabilities
- Risk score threshold to fail job (`<0`: disabled)

**Acceptance Stage:**
- Enable blocking job at acceptance
- Override server API URL
- Override target project path
- Merge SBOMs
- Wait for analysis
- Risk score threshold

**VEX (Vulnerability Exploitability eXchange):**
- Upload VEX files
- VEX file location

---

### Gitleaks

**Configuration:**
- Detect and prevent hardcoded secrets with [Gitleaks](https://github.com/zricethezav/gitleaks/wiki)
- Docker image for Gitleaks
- [Configuration rules](https://github.com/zricethezav/gitleaks/wiki/Configuration) (or use `.gitleaks.toml`)
- [Options](https://github.com/zricethezav/gitleaks/wiki/Options) for full analysis

---

### MobSF (Mobile Security Framework)

**Configuration:**
- Pen-testing, malware analysis, security assessment for mobile apps
- [Mobile Security Framework](https://github.com/MobSF/Mobile-Security-Framework-MobSF)
- Docker image for MobSF requests
- MobSF server URL
- Application package file (APK or IPA)

**Static Analysis:**
- Perform static analysis with [mobsfscan](https://github.com/MobSF/mobsfscan)
- Source code folder path
- Docker image for mobsfscan

---

### ORT (OSS Review Toolkit)

**Configuration:**
- Enforce open-source compliance with [OSS Review Toolkit](https://github.com/oss-review-toolkit/ort)
- Docker image for ort
- Configuration files directory
- Root directory to scan
- Config file location
- Curations file location
- Auto-run on integration/production branches

**Scan Types:**
- BASIC: analyse, report
- LICENSING: analyse, scan, report
- SECURITY: analyse, advise, report
- CUSTOM: analyse, advise, scan, evaluate, report

**Custom Options:**
- Enable SCAN phase
- Enable ADVISE phase
- Security advisories providers
- Enable EVALUATE phase
- Path to rules.kts file
- Path to license-classifications.yml
- Path to copyright-garbage.yml

---

### SonarQube

**Configuration:**
- Continuously inspect codebase with [SonarQube](https://www.sonarqube.org/)
- Variants: Vault integration
- Docker image for [sonar-scanner](https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/scanners/sonarscanner/)
- SonarQube server URL
- Project Key (or in `sonar-project.properties`)
- Project Name (or in `sonar-project.properties`)
- [Analysis arguments](https://docs.sonarsource.com/sonarqube-server/latest/analyzing-source-code/analysis-parameters/)
- Enable [Quality Gate](https://docs.sonarsource.com/sonarqube-server/latest/quality-standards-administration/managing-quality-gates/introduction/) verification

---

### Spectral

**Configuration:**
- JSON/YAML Linter with custom rulesets for OpenAPI and AsyncAPI
- [Spectral](https://docs.stoplight.io/docs/spectral)
- Docker image for spectral
- Location of JSON/YAML documents
- Extra [CLI options](https://docs.stoplight.io/docs/spectral/docs/guides/2-cli.md)
- Disable job option

---

### SQLFluff

**Configuration:**
- Lint SQL files (any dialect) with [SQLFluff](https://docs.sqlfluff.com)
- Docker image for SQLFluff
- Working directory scope
- Lint [options and arguments](https://docs.sqlfluff.com/en/stable/reference/cli.html#sqlfluff-lint)

---

## 3. Packaging

### Cloud Native Buildpacks (CNB)

**Configuration:**
- CNB builder image ([choose appropriate one](https://paketo.io/docs/concepts/builders/#what-paketo-builders-are-available))
- Absolute root directory in final image
- Relative path to application source
- [Platform API version](https://github.com/buildpacks/spec/blob/main/platform.md#platform-api-version)
- CNB snapshot image
- CNB release image

**Security:**
- [Trivy](https://aquasecurity.github.io/trivy) vulnerability analysis
- Docker image for Trivy scans
- Additional [`trivy image` options](https://aquasecurity.github.io/trivy/latest/docs/references/configuration/cli/trivy_image/#options)

**Publishing:**
- Promote snapshot to release using [skopeo](https://github.com/containers/skopeo)
- Docker image for Skopeo
- Additional [`skopeo copy` arguments](https://github.com/containers/skopeo/blob/master/docs/skopeo-copy.1.md#options)
- Deployment strategy

---

### Docker

**Build Tools:**
- Build tool selection: kaniko, buildah, or Docker-in-Docker
- Kaniko image
- Buildah image
- Docker client image
- Docker daemon image (DinD)
- Skopeo image for publishing

**Configuration:**
- Path to Dockerfile
- [Context path](https://docs.docker.com/engine/reference/commandline/build/#build-with-path)
- [Configuration file](https://docs.docker.com/engine/reference/commandline/cli/#sample-configuration-file) path (JSON)
- Snapshot image
- Release image

**Release Tagging:**
- Tag pattern for extra tags ([SemVer](https://semver.org/) by default)
- Extra tags definition (supports capturing groups)
  - Example: `latest \g<major>.\g<minor> \g<major>`

**Build Arguments:**
- Additional build arguments
- Labels as metadata
- [`skopeo copy` arguments](https://github.com/containers/skopeo/blob/master/docs/skopeo-copy.1.md#options)
- Deployment strategy
- Disable semantic-release integration

**Registry:**
- Docker registry mirror URL
- [registries.conf](https://www.redhat.com/sysadmin/manage-container-registries) (buildah only)
- Build cache control
- Cache location (kaniko/buildah)
- Additional push arguments

**Quality:**
- [Hadolint](https://github.com/hadolint/hadolint) Dockerfile linting
- Docker image for Hadolint
- Hadolint arguments

**Health Check:**
- [Health Check](https://docs.docker.com/engine/reference/builder/#healthcheck) analysis
- Wait time for HealthCheck status (seconds)
- Docker options for health check
- Container arguments

**Security:**
- [Trivy](https://aquasecurity.github.io/trivy) vulnerability analysis
- Docker image for Trivy scans
- Additional [`trivy image` options](https://aquasecurity.github.io/trivy/latest/docs/references/configuration/cli/trivy_image/#options)

**SBOM:**
- Generates file using [syft](https://github.com/anchore/syft)
- Controls when reports are generated
- Syft options

**Signing:**
- Sign images using [cosign](https://github.com/sigstore/cosign)
- When to sign: never, onrelease, always
- [`cosign sign`](https://docs.sigstore.dev/cosign/signing/signing_with_containers/) options
- [`cosign attest`](https://docs.sigstore.dev/cosign/verifying/attestation/) options
- Cosign binary URL

---

### RPM

**Configuration:**
- Docker base image for RPM tools
- RPM SPEC file path
- Docker image for rpmbuild
- RPM sourcedir path
- [`rpmbuild` options](https://man7.org/linux/man-pages/man8/rpmbuild.8.html)

**Quality:**
- [rpmlint](https://linux.die.net/man/1/rpmlint) analysis
- Docker image for rpmlint
- [`rpmlint` options](https://linux.die.net/man/1/rpmlint)

---

### Source-to-Image (S2I)

**Configuration:**
- Docker daemon image
- Skopeo image for publishing
- S2I version to install/use
- S2I platform to install/use
- [Builder image](https://github.com/openshift/source-to-image/blob/master/docs/builder_image.md)
- Relative path to application source
- Build [extra flags](https://github.com/openshift/source-to-image/blob/master/docs/cli.md#s2i-build)

**Images:**
- S2I snapshot image
- S2I release image
- Additional [`skopeo copy` arguments](https://github.com/containers/skopeo/blob/master/docs/skopeo-copy.1.md#options)
- Deployment strategy

**Release Tagging:**
- Tag pattern for extra tags ([SemVer](https://semver.org/) by default)
- Extra tags definition (supports capturing groups)
- Disable semantic-release integration

**Security:**
- [Trivy](https://aquasecurity.github.io/trivy) vulnerability analysis
- Docker image for Trivy scans
- Additional [`trivy image` options](https://aquasecurity.github.io/trivy/latest/docs/references/configuration/cli/trivy_image/#options)

---

## 4. Infrastructure

### Terraform

**Configuration:**
- Docker image for Terraform CLI - **set version required**
- Disable [GitLab managed Terraform State](https://docs.gitlab.com/user/infrastructure/iac/terraform_state/)
- Project root directory
- (Hook) scripts base directory
- Output directory (kept as artifacts)

**Terraform Options:**
- Default extra options (all commands)
- Default extra [init options](https://developer.hashicorp.com/terraform/cli/commands/init)
- Default project [workspace](https://developer.hashicorp.com/terraform/language/state/workspaces)
- Default extra [plan options](https://developer.hashicorp.com/terraform/cli/commands/plan)
- Default extra [apply options](https://developer.hashicorp.com/terraform/cli/commands/apply)
- Default extra [destroy options](https://developer.hashicorp.com/terraform/cli/commands/destroy)
- Extra [`apk add` options](https://www.mankier.com/8/apk)

**Security Analysis:**
- [tfsec](https://github.com/tfsec/tfsec) security issues
  - Docker image
  - [Options and args](https://aquasecurity.github.io/tfsec/latest/guides/usage/)
- [trivy config](https://aquasecurity.github.io/trivy/latest/docs/scanner/misconfiguration/)
  - Docker image
  - [Options and args](https://aquasecurity.github.io/trivy/latest/docs/references/configuration/cli/trivy_config/)
- [checkov](https://www.checkov.io/) static code analysis
  - Docker image
  - [Options and args](https://www.checkov.io/2.Basics/CLI%20Command%20Reference.html)

**Cost Analysis:**
- [Infracost](https://www.infracost.io/) cloud cost estimates
  - Docker image
  - [CLI options](https://www.infracost.io/docs/#usage)
  - [Usage file](https://www.infracost.io/docs/usage_based_resources/#infracost-usage-file)

**Code Quality:**
- [tflint](https://github.com/terraform-linters/tflint)
  - Docker image
  - [Options and args](https://github.com/terraform-linters/tflint/#usage)
- [tffmt](https://developer.hashicorp.com/terraform/cli/commands/fmt#usage)
  - Extra [options](https://developer.hashicorp.com/terraform/cli/commands/fmt#usage)
- [tfvalidate](https://developer.hashicorp.com/terraform/cli/commands/validate#usage)

**Documentation:**
- [terraform docs](https://terraform-docs.io/)
  - Container image
  - Extra [options](https://terraform-docs.io/reference/terraform-docs/)
  - [Configuration file](https://terraform-docs.io/user-guide/configuration/)
  - Output directory

**Testing:**
- Terraform test strategy: `disabled`, `single`, or `cascading`
- Extra options for terraform native test feature

**Publishing:**
- Publish to GitLab's [Terraform Module Registry](https://docs.gitlab.com/user/packages/terraform_module_registry/)
  - Container image
  - Module name (no spaces/underscores)
  - Module system/provider (e.g., `local`, `aws`, `google`)
  - Module version ([semantic versioning](https://semver.org/))
  - Glob patterns for files (⚠️ no double star)

**Environments:**
Each environment (review, integration, staging, production) supports:
- Terraform extra options
- Extra init options
- Project workspace
- Enable separate plan job
- Extra plan options
- Extra apply options
- Extra destroy options
- Auto-stop timeout (for review/integration/staging)

---

## 5. Deployment

### Ansible

**Configuration:**
- Docker image for Ansible - **set version required**
- Project root directory
- Base application name
- Default environments URL (supports late variable expansion: `https://%{environment_name}.acme.com`)
- Ansible SSH public key
- Default inventory
- Default tags
- Optional default args for ansible-playbook
- Force color on output
- File for `ansible-galaxy install`
- `ansible-galaxy install` [extra options](https://docs.ansible.com/ansible/latest/cli/ansible-galaxy.html#role-install)
- Ansible scripts base directory
- Enable/disable SSH host key checking

**Code Quality:**
- [Ansible Lint](https://docs.ansible.com/ansible-lint/) static code analysis
- Docker image for Ansible Lint

**Environments:**
Each environment (review, integration, staging, production) supports:
- Application name override
- Environment URL (static declaration)
- Inventory
- Tags
- Cleanup tags
- Command line extra args
- Auto-stop timeout
- Playbook filename
- Cleanup playbook filename
- SSH public key

---

### AWS

**Configuration:**
- Docker image for AWS CLI
- Base application name
- Default environments URL (supports late variable expansion)
- Scripts directory (deploy & cleanup)

**Environments:**
Each environment (review, integration, staging, production) supports:
- Application name override
- Auto-stop timeout (review only)
- Environment URL (static declaration)
- Deployment strategy (production only)

---

### Azure

**Configuration:**
- Docker image for Azure CLI
- Base application name
- Default environments URL (supports late variable expansion)
- Scripts directory (deploy & cleanup)
- Default Service Principal client ID
- Default Service Principal tenant ID

**Environments:**
Each environment (review, integration, staging, production) supports:
- Application name override
- Auto-stop timeout (review only)
- Environment URL (static declaration)
- Service Principal client ID override
- Service Principal tenant ID override
- Deployment strategy (production only)

---

### Cloud Foundry

**Configuration:**
- Docker image for CF CLI - **set version for CF server**
- CF manifest file basename
- Global CF API URL
- Global CF organization
- Global CF default domain
- Global CF default route path
- Global additional cf push arguments
- Base application name
- Scripts directory
- Use CF native zero-downtime deployment

**Environments:**
Each environment (review, integration, staging, production) supports:
- CF organization override
- CF space
- Application name override
- Host name
- Domain
- Protocol scheme
- Environment domain
- Route path
- Additional cf push arguments
- Blue-green temporary app domain
- Enable zero-downtime deployment
- CF API URL override
- Old version suffix (if not deleted)
- Auto-stop timeout
- Environment URL (complex format)
- Deployment strategy (production only)

**Cleanup:**
- Enable manual cleanup job for all review envs
- Can be [scheduled](https://docs.gitlab.com/ci/pipelines/schedules/)

---

### Docker Compose

**Configuration:**
- Docker image for Docker Compose CLI - **set version required**
- Compose or stack command (auto if empty)
- Base application name
- Default environments URL (supports late variable expansion)
- Compose files/dotenv/hook scripts directory
- [`compose up` options](https://docs.docker.com/reference/cli/docker/compose/up/#options)
- [`compose down` options](https://docs.docker.com/reference/cli/docker/compose/down/#options)
- [`stack deploy` options](https://docs.docker.com/reference/cli/docker/stack/deploy/)
- SSH known_hosts (file or text)

**Validation:**
- Run [`compose config`](https://docs.docker.com/reference/cli/docker/compose/config/)
- [`compose config` options](https://docs.docker.com/reference/cli/docker/compose/config/#options)
- [`stack config` options](https://docs.docker.com/reference/cli/docker/stack/config/)
- Silence standard output

**Environments:**
Each environment (review, integration, staging, production) supports:
- Docker Host (e.g., `ssh://docker@host:2375`)
- Application name override
- Auto-stop timeout
- Environment URL (static declaration)
- Deployment strategy (production only)

---

### Google Cloud

**Configuration:**
- Docker image for Google Cloud CLI
- Default [Workload Identity Provider](https://docs.gitlab.com/ci/cloud_services/google_cloud/)
  - Format: `projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_ID/providers/PROVIDER_ID`
- Default Service Account for WIF impersonation
- Base application name
- Default environments URL (supports late variable expansion)
- Scripts directory (deploy & cleanup)

**Environments:**
Each environment (review, integration, staging, production) supports:
- Google Cloud project ID
- Application name override
- Auto-stop timeout (review only)
- Environment URL (static declaration)
- Deployment strategy (production only)

---

### Helm

**Configuration:**
- Docker image for GitOps (git + yq)
- Docker image for Helm - **set version for Kubernetes**
- Helm chart folder
- Hook scripts folder
- Common values file (all environments)
- Helm [chart](https://helm.sh/docs/topics/charts/) to deploy (external)
- [Chart repositories](https://helm.sh/docs/topics/chart_repository/)
  - Format: `repo_name_1@repo_url_1 repo_name_2@repo_url_2`
- Default Kubernetes namespace
- Base application name
- Default environments URL (supports late variable expansion)

**Helm Commands:**
- [upgrade command](https://helm.sh/docs/helm/helm_upgrade/) with options
- [uninstall command](https://helm.sh/docs/helm/helm_uninstall/) with options
- [dependency update](https://helm.sh/docs/helm/helm_dependency_update/) with options

**Helm Values:**
- Value name for environment type
- Value name for environment hostname

**Code Quality:**
- [Helm Lint](https://helm.sh/docs/helm/helm_lint/) static analysis
  - [Command with options](https://helm.sh/docs/helm/helm_lint/)

**Testing:**
- [Helm Test](https://helm.sh/docs/helm/helm_test/) acceptance test
  - [Command with options](https://helm.sh/docs/helm/helm_test/)

**YAML Linting:**
- [Yaml Lint](https://github.com/adrienverge/yamllint) for values file
  - Docker image
  - Config for yamllint
  - Arguments for lint job

**Resource Validation:**
- Run [Kube-Score](https://kube-score.com/)
  - Docker image
  - Arguments for kube-score
  - Kubernetes version (format: `vX.YY`)

**Packaging:**
- [Package](https://helm.sh/docs/helm/helm_package/) Helm chart
  - [Command with options](https://helm.sh/docs/helm/helm_package/)
  - Enable publishing snapshot chart
  - Snapshot suffix
  - Disable semantic-release integration

**Publishing:**
- Publish to [Helm repository](https://helm.sh/docs/topics/chart_repository/) or [OCI registry](https://helm.sh/docs/topics/registries/)
  - Repository URL
  - HTTP method for push
  - Git reference(s) to enable: `prod`, `protected`, `all`, `tag`
  - Publish strategy
  - cm-push plugin version

**Environments:**
Each environment (review, integration, staging, production) supports:
- Application name override
- Auto-stop timeout
- Environment URL (static declaration)
- Values file
- Kubernetes namespace override
- Deployment strategy (production only)

---

### Helmfile

**Configuration:**
- Docker image for helmfile - **set version for Kubernetes**
- Hook scripts folder
- Path to helmfile config file(s)
- Default Kubernetes namespace
- Base application name
- Default environments URL (supports late variable expansion)
- [helmfile apply](https://helmfile.readthedocs.io/en/latest/#apply) command with options
- [helmfile destroy](https://helmfile.readthedocs.io/en/latest/#destroy) command with options
- docker-registry k8s secret name (for GitLab deploy token)

**Testing:**
- [helm lint](https://helm.sh/docs/helm/helm_lint/) across all charts/releases
  - [Command with options](https://helmfile.readthedocs.io/en/latest/#lint)
- [Helm tests](https://helm.sh/docs/topics/chart_tests/) acceptance testing
  - [Command with options](https://helmfile.readthedocs.io/en/latest/#test)

**Environments:**
Each environment (review, integration, staging, production) supports:
- Application name override
- Auto-stop timeout
- Environment URL (static declaration)
- Kubernetes namespace override
- Deployment strategy (production only)

---

### Kubernetes (kubectl)

**Configuration:**
- Docker image for `kubectl` - **set version for Kubernetes**
- Global Kubernetes API URL (exploded kubeconfig)
- Base application name
- Default environments URL (supports late variable expansion)
- Scripts directory (templates, hooks)
- Enable [Kustomize](https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/)
- Additional [`kubectl kustomize` options](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#kustomize)
- Enable automatic namespace creation

**Code Quality:**
- [kube-score](https://github.com/zegl/kube-score) static analysis
  - Docker image
  - Additional [options](https://github.com/zegl/kube-score#configuration)

**Environments:**
Each environment (review, integration, staging, production) supports:
- Kubernetes namespace
- Application name override
- Auto-stop timeout (review only)
- Environment URL (static declaration)
- Kubernetes API URL override (exploded kubeconfig)
- Deployment strategy (production only)

---

### OpenShift

**Configuration:**
- Docker image for OpenShift Client (OC) CLI - **set version required**
- Global OpenShift API URL
- Base application name
- Base OpenShift template name
- Default environments URL (supports late variable expansion)
- Scripts directory (templates, hooks)
- [Label](https://docs.openshift.com/container-platform/3.11/dev_guide/templates.html#writing-labels) for environment_name
- [Label](https://docs.openshift.com/container-platform/3.11/dev_guide/templates.html#writing-labels) for environment_type

**Environments:**
Each environment (review, integration, staging, production) supports:
- OpenShift project
- Application name override
- Auto-stop timeout (review only)
- Environment URL (static declaration)
- OpenShift API URL override
- Deployment strategy (production only)

**Cleanup:**
- Enable manual cleanup job for all review envs
- Can be [scheduled](https://docs.gitlab.com/ci/pipelines/schedules/)

---

### S3

**Configuration:**
- Docker image for [s3cmd](https://s3tools.org/usage)
- Default S3 endpoint hostname (with port)
- Default DNS-style bucket+hostname:port template
- Default region for bucket creation
- Base bucket name
- [s3cmd](https://s3tools.org/usage) command for deployment
- Pattern(s) of files to deploy
- Disable WebSite hosting
- Default WebSite endpoint URL pattern (supports placeholders)
- [s3cmd](https://s3tools.org/usage) command to enable WebSite hosting
- Default S3 prefix for upload destination
- Hook scripts directory

**Environments:**
Each environment (review, integration, staging, production) supports:
- S3 endpoint hostname override
- Region for bucket creation
- Bucket name override
- S3 prefix override
- Auto-stop timeout (review only)

**Cleanup:**
- Enable manual cleanup job for all review envs
- Can be [scheduled](https://docs.gitlab.com/ci/pipelines/schedules/)

---

## 6. Acceptance Tests

### Bruno

**Configuration:**
- Test APIs with [Bruno](https://www.usebruno.com/)
- Docker image for [Bruno CLI](https://docs.usebruno.com/cli/overview.html)
- Matcher to select collection directory(ies)
- Explicit base URL environment (auto-evaluated by default)
- Bruno extra [run options](https://docs.usebruno.com/cli/overview.html#options)
- Enable tests on review environments

---

### Cypress

**Configuration:**
- Automated (web) tests with [Cypress](https://www.cypress.io/)
- Docker image for Cypress (use [included images](https://github.com/cypress-io/cypress-docker-images/tree/master/included) only)
- Cypress project directory (contains `cypress.config.js` or `cypress.config.ts`)
- Cypress extra [run options](https://docs.cypress.io/guides/guides/command-line.html#cypress-run)
- Enable tests on review environments

---

### Hurl

**Configuration:**
- Automated tests with [Hurl](https://hurl.dev/)
- Docker image for Hurl
- Hurl test files to run
- Hurl extra [run options](https://hurl.dev/docs/manual.html#options)
- Enable tests on review environments

---

### k6

**Configuration:**
- Automated load-testing with [k6](https://k6.io/)
- Docker image for k6 CLI
- k6 tests directory
- k6 extra [command-line options](https://k6.io/docs/getting-started/running-k6)
- Enable tests on review environments

---

### Lighthouse CI

**Configuration:**
- Analyse web apps/pages performance with [Lighthouse CI](https://github.com/GoogleChrome/lighthouse-ci)
- Docker image for Lighthouse CI (use [browser images](https://github.com/cypress-io/cypress-docker-images/tree/master/browsers) only)
- Lighthouse CI version
- Lighthouse CI [autorun options](https://github.com/GoogleChrome/lighthouse-ci/blob/main/docs/configuration.md#autorun)
- Enable tests on review environments

---

### Playwright

**Configuration:**
- Automated tests with [Playwright](https://playwright.dev/docs/intro)
- Docker image for Playwright
- Playwright root project directory (contains `playwright.config.ts`)
- Playwright extra [reporters](https://playwright.dev/docs/test-reporters#built-in-reporters)
  - Comma separated: `list`, `line`, `dot`, `json`, `html`
- Playwright extra [run options](https://playwright.dev/docs/test-cli)
- Enable tests on review environments
- Extra [`npm ci`](https://docs.npmjs.com/cli/ci.html/) options

---

### Postman

**Configuration:**
- Automated (API) tests with [Postman](https://www.postman.com/automated-testing)
- Docker image for Postman CLI
- Matcher to select collection file(s)
- Newman extra [run options](https://github.com/postmanlabs/newman#command-line-options)
- Enable tests on review environments

---

### Puppeteer

**Configuration:**
- Automated (web) tests with [Puppeteer](https://pptr.dev/)
- Docker image for [Puppeteer](https://hub.docker.com/r/ghcr.io/puppeteer/puppeteer)
- Puppeteer project directory (contains `package.json`)
- Testing framework extra options ([Jest](https://jestjs.io/docs/en/cli))
- Enable tests on review environments

---

### Robot Framework

**Configuration:**
- Automated tests with [Robot Framework](https://robotframework.org/)
- Variants: Vault integration
- Docker image for Robot Framework CLI
- Path to tests directory
- Browser to use
- Robot Framework [additional options](http://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#all-command-line-options)
- Number of threads ([Pabot](https://pabot.org/) if > 1)
- Pabot [additional options](https://github.com/mkorpela/pabot#command-line-options)
- Screen colour depth for X Window Virtual Framebuffer
- Screen height for X Window Virtual Framebuffer
- Screen width for X Window Virtual Framebuffer
- Enable tests on review environments

**Code Quality:**
- [Lint](https://github.com/boakley/robotframework-lint/) analysis

---

### Test SSL

**Configuration:**
- Test TLS/SSL server compliance with [Test SSL](https://testssl.sh/)
- Docker image for Test SSL
- Test SSL [command-line options](https://testssl.sh/#usage)
- Server URL to test against (leave unset if using deployment templates)
- Enable tests on review environments

---

## 7. Other Tools

### GitLab Butler

**Configuration:**
- Automate project cleaning with [GitLab Butler](https://gitlab.com/to-be-continuous/tools/gitlab-butler)
- Docker image for GitLab Butler
- GitLab group to process
- Max age (in days) for pipeline deletion

---

### Renovate

**Configuration:**
- Automate dependency updates with [Renovate](https://www.mend.io/renovate/)
- Docker image for Renovate
- Renovate configuration for onboarding PRs
- Enable [repositories autodiscovery](https://docs.renovatebot.com/self-hosted-configuration/#autodiscover)
- [Filter autodiscovered repositories](https://docs.renovatebot.com/self-hosted-configuration/#autodiscoverfilter)

---

### Semantic Release

**Configuration:**
- Automate versioning and release management with [semantic-release](https://github.com/semantic-release/semantic-release)
- Variants: Vault integration
- Docker image for semantic-release
- [semantic-release](https://www.npmjs.com/package/semantic-release) version
- [@semantic-release/exec](https://www.npmjs.com/package/@semantic-release/exec) version
- Directory with [semantic-release configuration](https://semantic-release.gitbook.io/semantic-release/usage/configuration#configuration-file)
- [tagFormat option](https://github.com/semantic-release/semantic-release/blob/master/docs/usage/configuration.md#tagformat) (double `$` character)
- Full path to `semrel-required-plugins.txt`

**Release:**
- Perform semantic release

**Changelog:**
- Add [@semantic-release/changelog](https://github.com/semantic-release/changelog) plugin
- [changelogFile option](https://github.com/semantic-release/changelog#options)
- [changelogTitle option](https://github.com/semantic-release/changelog#options) (markdown format)

**Options:**
- Enable [dryRun option](https://github.com/semantic-release/semantic-release/blob/master/docs/usage/configuration.md#dryrun)
- [Extra options](https://semantic-release.gitbook.io/semantic-release/usage/configuration#options)
- Auto-start job when set (manual by default)
- Regex pattern for release branches
- Hook scripts folder

---

## Environment Configuration

### Common Environment Variables

Most deployment templates support these common environment types:

1. **Review**
   - Dynamic review environments for topic branches
   - See GitLab [Review Apps](https://docs.gitlab.com/ci/review_apps/)
   - Auto-stop timeout configuration

2. **Integration**
   - CI environment for integration branch (`develop` by default)
   - Optional auto-stop timeout

3. **Staging**
   - Iso-prod environment for testing and validation
   - Production branch (`main` or `master` by default)
   - Optional auto-stop timeout

4. **Production**
   - Production environment
   - Deployment strategy configuration

### Deployment Strategies

Production deployment strategies typically include:
- Manual deployment (default)
- Automatic deployment on merge
- Blue-green deployment
- Canary deployment
- Rolling deployment

---

## Notes

- **Version Requirements:** Always set Docker image versions to match your project requirements
- **Security:** Use GitLab CI/CD variables or Vault integration for sensitive credentials
- **Glob Patterns:** Some parameters don't support double-star (`**`) glob patterns
- **Environment URLs:** Support late variable expansion (e.g., `https://%{environment_name}.domain.com`)
- **Auto-stop:** Configure automatic environment cleanup to save resources

---

## References

- **Official Documentation:** https://to-be-continuous.gitlab.io/
- **GitLab CI/CD:** https://docs.gitlab.com/ee/ci/
- **Template Repository:** https://gitlab.com/to-be-continuous

---

*Document generated from: https://to-be-continuous.gitlab.io/kicker*
*Last updated: 2025-11-30*