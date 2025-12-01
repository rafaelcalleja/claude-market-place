---
description: Get help with TBC plugin commands
allowed-tools: ["Read"]
---

# TBC Plugin Help

Complete guide to using the GitLab TBC (To-Be-Continuous) plugin for Claude Code.

## Overview

This plugin helps you generate, validate, and manage GitLab CI/CD configurations using the To-Be-Continuous framework - a collection of 62 modular templates for building production-ready CI/CD pipelines.

## What is To-Be-Continuous?

To-Be-Continuous (TBC) is a framework that provides:
- **62 reusable templates** across 8 categories
- **Standardized CI/CD patterns** for common workflows
- **Modular design** - combine only what you need
- **Best practices built-in** - security, testing, deployment
- **Maintained by experts** - regularly updated templates

## Available Commands

### /tbc [description]
**Main command** - Generate GitLab CI/CD configurations

**Usage:**
```bash
/tbc                          # Interactive mode
/tbc create Python pipeline   # Generate specific config
/tbc migrate existing config  # Convert to TBC
/tbc what templates exist?    # Ask questions
```

**What it does:**
- Analyzes your intent (generate, migrate, consult)
- Guides you through template selection
- Generates validated configurations
- Never hallucinates - reads schemas for accuracy

**Example workflows:**
- "Create a pipeline for my Python FastAPI service with Docker and Kubernetes"
- "Migrate my existing .gitlab-ci.yml to TBC"
- "What's the best way to deploy to AWS with TBC?"

---

### /tbc:wizard
**Guided 8-step wizard** - Replicates the TBC Kicker web wizard

**Usage:**
```bash
/tbc:wizard
```

**What it does:**
1. Configure global options (include mode, version mode)
2. Select build template (language)
3. Select code analysis tools
4. Select packaging method
5. Select infrastructure (Terraform)
6. Select deployment target
7. Select acceptance tests
8. Generate validated configuration

**Best for:**
- First-time TBC users
- Comprehensive pipeline setup
- Learning available options

---

### /tbc:templates [filter]
**Browse templates** - Explore available TBC templates

**Usage:**
```bash
/tbc:templates                    # Show all templates
/tbc:templates deployment         # Filter by category
/tbc:templates Python             # Search by name
/tbc:templates --compare Docker CNB  # Compare templates
```

**What it does:**
- Lists all 62 templates organized by category
- Shows template descriptions and key variables
- Displays selection rules (single vs multiple)
- Explains template variants (Vault, OIDC, etc.)

**Categories:**
- Build (15 templates)
- Code Analysis (7 templates)
- Packaging (3 templates)
- Infrastructure (1 template)
- Deployment (11 templates)
- Acceptance Tests (10 templates)
- Other (3 templates)

---

### /tbc:validate [file]
**Validate configuration** - Check TBC configs against schemas

**Usage:**
```bash
/tbc:validate                     # Validate .gitlab-ci.yml in current dir
/tbc:validate path/to/config.yml  # Validate specific file
/tbc:validate --strict            # Strict mode with warnings
```

**What it does:**
- Validates component references
- Checks input parameters against schemas
- Verifies variable types
- Suggests fixes for errors
- Lists required secret variables

**Use cases:**
- Pre-commit validation
- Troubleshooting failed pipelines
- Post-generation verification
- After manual edits

---

### /tbc:help
**This help** - Show plugin documentation

---

## Quick Start Guide

### For New Projects

1. **Run the wizard:**
   ```bash
   /tbc:wizard
   ```

2. **Answer questions** about your project:
   - Language/framework
   - Deployment target
   - Testing needs

3. **Get validated config:**
   - Copy `.gitlab-ci.yml` to your repo
   - Set secret variables in GitLab UI
   - Commit and push

### For Existing Projects

1. **Migrate existing config:**
   ```bash
   /tbc migrate my existing .gitlab-ci.yml to TBC
   ```

2. **Review suggested config:**
   - Compare with current pipeline
   - Understand the benefits

3. **Test and deploy:**
   - Create new branch
   - Test TBC configuration
   - Switch when ready

### For Exploration

1. **Browse templates:**
   ```bash
   /tbc:templates
   ```

2. **Ask questions:**
   ```bash
   /tbc what's the difference between Docker and Cloud Native Buildpacks?
   ```

3. **Generate samples:**
   ```bash
   /tbc create example Python pipeline
   ```

## Template Categories Explained

### Build Templates (Select ONE)
Languages and frameworks:
- Python, Node.js, Go, Java (Maven/Gradle)
- Angular, PHP, Bash, Scala
- Documentation (MkDocs, Sphinx)
- Utilities (pre-commit, GNU Make)

### Code Analysis Templates (Select MULTIPLE)
Quality and security tools:
- SonarQube - Code quality
- Gitleaks - Secret detection
- DefectDojo - Security aggregation
- Dependency Track - SBOM
- MobSF - Mobile security
- Spectral - API linting
- SQLFluff - SQL linting

### Packaging Templates (Select ONE)
Container building:
- Docker - Build from Dockerfile
- Cloud Native Buildpacks - Auto-detect builds
- Source-to-Image - OpenShift S2I

### Deployment Templates (Select ONE)
Where to deploy:
- Kubernetes, Helm, Helmfile
- AWS, Azure, Google Cloud
- Docker Compose
- OpenShift, Cloud Foundry
- Ansible, S3

### Acceptance Test Templates (Select MULTIPLE)
Testing frameworks:
- Cypress, Playwright - E2E web testing
- Postman, Bruno, Hurl - API testing
- k6 - Load testing
- Lighthouse - Performance
- Robot Framework - Test automation
- TestSSL - SSL/TLS testing

### Other Templates (Select MULTIPLE)
Utilities:
- Renovate - Dependency updates
- Semantic Release - Version management
- GitLab Butler - Project cleanup

## Configuration Modes

### Component Mode (Recommended)
**Requirements:** GitLab 16.0+

**Syntax:**
```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/python/python@7
    inputs:
      image: "python:3.12-slim"
      build-system: "poetry"
```

**Advantages:**
- Modern GitLab syntax
- Type-safe inputs
- Better validation
- Cleaner configuration

### Project Mode
**Use for:** Self-hosted GitLab < 16.0

**Syntax:**
```yaml
include:
  - project: "to-be-continuous/python"
    ref: "7.5"
    file: "templates/gitlab-ci-python.yml"

variables:
  PYTHON_IMAGE: "python:3.12-slim"
```

### Remote Mode
**Use for:** External GitLab instances

**Syntax:**
```yaml
include:
  - remote: "https://gitlab.com/to-be-continuous/python/-/raw/7.5/templates/gitlab-ci-python.yml"

variables:
  PYTHON_IMAGE: "python:3.12-slim"
```

## Common Use Cases

### Python Web Application
```bash
/tbc create pipeline for Python FastAPI app with Docker and Kubernetes
```

**Generates:**
- Python build with pytest
- Docker image build
- Kubernetes deployment
- All validated and ready to use

### Node.js with Quality Checks
```bash
/tbc create Node.js pipeline with SonarQube and security scanning
```

**Generates:**
- Node.js build
- SonarQube analysis
- Gitleaks secret detection
- DefectDojo integration

### Infrastructure as Code
```bash
/tbc create Terraform pipeline with AWS deployment
```

**Generates:**
- Terraform template
- AWS deployment with OIDC
- Validation and planning stages

## Troubleshooting

### Pipeline Fails After Generation

1. **Validate configuration:**
   ```bash
   /tbc:validate
   ```

2. **Check secret variables:**
   - Ensure all secret variables are set in GitLab UI
   - Settings → CI/CD → Variables

3. **Review error messages:**
   - Pipeline errors often indicate missing variables
   - Check schema requirements

### Unknown Input Parameter Error

**Problem:** GitLab shows "unknown input: xyz"

**Solution:**
1. Run validation:
   ```bash
   /tbc:validate
   ```
2. Check for typos in input names
3. Verify variable name transformation for component mode

### Component Not Found

**Problem:** GitLab can't find TBC component

**Solution:**
1. Verify GitLab version (16.0+ for component mode)
2. Check component path syntax
3. Ensure TBC is available on your GitLab instance
4. Consider using project or remote mode

### Want Different Configuration

**Solution:**
- Re-run `/tbc:wizard` with different selections
- Use `/tbc` with specific requirements
- Manually edit and validate with `/tbc:validate`

## Best Practices

### Version Pinning
- **Recommended:** Minor version (`@7.5`) - Balance stability and updates
- **Stable:** Full version (`@7.5.2`) - No surprises
- **Latest:** Major version (`@7`) - Get new features faster

### Secret Variables
- NEVER put secrets in `.gitlab-ci.yml`
- Always configure in GitLab UI: Settings → CI/CD → Variables
- Mark sensitive variables as "Masked" and "Protected"

### Template Selection
- Start simple - add templates as needed
- Don't select templates you don't use
- Multiple analysis tools can run in parallel

### Testing
- Test in feature branch first
- Review generated pipeline jobs
- Validate before committing

## Advanced Features

### Template Variants

**Vault Integration:**
```yaml
- component: $CI_SERVER_FQDN/to-be-continuous/python/python-vault@7
  inputs:
    vault-base-url: "https://vault.example.com"
```

**OIDC Authentication (AWS/Azure/GCP):**
```yaml
- component: $CI_SERVER_FQDN/to-be-continuous/aws/aws-oidc@7
  inputs:
    role-arn: "arn:aws:iam::123456789:role/gitlab-ci"
```

**Cloud-specific Authentication:**
```yaml
- component: $CI_SERVER_FQDN/to-be-continuous/python/python-gcloud@7
  inputs:
    gcp-project-id: "my-project"
```

### Custom Stages

Add custom stages to your pipeline:
```yaml
stages:
  - custom-stage-1
  - build
  - test
  - package
  - deploy
  - custom-stage-2
```

## Getting More Help

### Within Commands
All commands support natural language questions:
```bash
/tbc what templates work with Python?
/tbc how do I deploy to Kubernetes?
/tbc compare Helm and raw Kubernetes
```

### Explore Templates
```bash
/tbc:templates deployment
/tbc:templates --compare Docker CNB
```

### Learn by Example
```bash
/tbc show me an example Python + Docker + Kubernetes pipeline
```

## Plugin Architecture

This plugin follows the hookify pattern:

**Knowledge Base:**
- `building-with-tbc` skill - Shared TBC knowledge
- Schemas for all 62 templates
- Reference documentation
- Validation scripts

**Commands:**
- `/tbc` - Main router and generator
- `/tbc:wizard` - Guided workflow
- `/tbc:templates` - Template browser
- `/tbc:validate` - Configuration validator
- `/tbc:help` - This help

**Agents:**
- `tbc-validator` - Automated validation

## Resources

### Reference Files
Located in the plugin at `skills/building-with-tbc/references/`:
- `templates-catalog.md` - All 62 templates
- `build-templates.md` - Build category details
- `deployment-templates.md` - Deployment category details
- `analysis-templates.md` - Analysis category details
- `variantes.md` - Template variants explained
- `presets.md` - Common configuration presets
- `best-practices.md` - TBC best practices

### Schemas
All templates have JSON schemas in `skills/building-with-tbc/schemas/`

### Examples
Example configurations in `skills/building-with-tbc/examples/`

## Support

For issues or questions:
1. Use `/tbc:help` for this guide
2. Ask specific questions with `/tbc [your question]`
3. Validate configurations with `/tbc:validate`
4. Browse templates with `/tbc:templates`

## Version

Plugin Version: 1.0.0
TBC Framework: Supports all current TBC templates
Last Updated: 2025-12-01
