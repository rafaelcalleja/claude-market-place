---
description: List available TBC templates and their categories
allowed-tools: ["Read", "Skill"]
---

# TBC Templates - Template Catalog

**FIRST: Load the building-with-tbc skill** using the Skill tool to access TBC template catalog.

## Purpose

This command helps users explore available To-Be-Continuous templates, understand their purpose, and find the right templates for their needs.

## Workflow

### Step 1: Determine User Intent

Check if the user specified a filter:

**Show all templates** (default):
- List all templates organized by category

**Filter by category**:
- Keywords: "build", "deployment", "analysis", "packaging", "infrastructure", "acceptance", "other"
- Show only templates in that category

**Search by keyword**:
- Keywords: language names (Python, Node, Go), tools (Docker, Kubernetes), features
- Show matching templates with descriptions

### Step 2: Read Template Catalog

Read `${CLAUDE_PLUGIN_ROOT}/skills/building-with-tbc/references/templates-catalog.md` to get the complete and accurate list of all templates.

### Step 3: Present Templates

#### Format for All Templates

```
To-Be-Continuous Template Catalog
=================================

Total: 62 templates across 8 categories

BUILD TEMPLATES (15) - Select ONE
----------------------------------
1. Angular - Angular CLI projects with ng build
   Variables: NG_IMAGE, NG_VERSION, NG_BUILD_OPTS
   Variants: None

2. Bash - Shell scripts with ShellCheck and Bats testing
   Variables: BASH_IMAGE, SHELLCHECK_ENABLED
   Variants: None

[Continue for all build templates...]

CODE ANALYSIS TEMPLATES (7) - Select MULTIPLE
----------------------------------------------
1. SonarQube - Code quality and security analysis
   Variables: SONAR_URL, SONAR_PROJECT_KEY
   Variants: Vault

[Continue for all analysis templates...]

PACKAGING TEMPLATES (3) - Select ONE
-------------------------------------
[List packaging templates...]

INFRASTRUCTURE TEMPLATES (1) - Select ONE
------------------------------------------
[List infrastructure templates...]

DEPLOYMENT TEMPLATES (11) - Select ONE
---------------------------------------
[List deployment templates...]

ACCEPTANCE TEST TEMPLATES (10) - Select MULTIPLE
-------------------------------------------------
[List acceptance templates...]

OTHER TEMPLATES (3) - Select MULTIPLE
--------------------------------------
[List other templates...]

---
Legend:
- "Select ONE" = Choose one template or none from this category
- "Select MULTIPLE" = Can choose zero, one, or many from this category
- Variants = Additional components for special features (Vault, OIDC, etc.)

Need help? Use /tbc to generate a configuration, or ask me about specific templates.
```

#### Format for Category Filter

When user asks for a specific category (e.g., "show deployment templates"):

```
DEPLOYMENT TEMPLATES - To-Be-Continuous
========================================

Total: 11 templates | Selection: ONE | Category: deployment

1. Ansible - Configuration management and deployment
   Description: Deploy applications using Ansible playbooks
   Key Variables:
   - ANSIBLE_PLAYBOOK: Path to playbook file
   - ANSIBLE_INVENTORY: Inventory file or dynamic inventory
   - ANSIBLE_EXTRA_VARS: Additional variables
   Variants: Vault

2. AWS - Amazon Web Services deployment
   Description: Deploy to AWS services (ECS, Lambda, etc.)
   Key Variables:
   - AWS_REGION: AWS region (e.g., us-east-1)
   - AWS_ACCOUNT_ID: AWS account ID
   Variants: OIDC (for OpenID Connect auth)

3. Azure - Microsoft Azure deployment
   Description: Deploy to Azure services
   Key Variables:
   - AZURE_SUBSCRIPTION_ID: Azure subscription
   - AZURE_RESOURCE_GROUP: Resource group name
   Variants: OIDC

[Continue for all deployment templates...]

---
For detailed configuration, use:
- /tbc wizard - Guided configuration
- /tbc [description] - Generate specific config
- /tbc:help - Full plugin help
```

#### Format for Detailed Template Info

When user asks about a specific template:

```
Template: Python
================

Category: Build
Selection Type: Single (choose one build template)
Description: Build and test Python applications using pip, poetry, or pipenv

Configuration Variables:
------------------------

Essential Variables:
- image: Docker image for Python (default: python:3.12-slim)
  Type: text

- build-system: Package manager to use (default: pip)
  Type: enum [pip, poetry, pipenv]

Features (Toggleable):
- pytest-enabled: Run pytest tests (default: true)
- pylint-enabled: Run pylint linting (default: true)
- bandit-enabled: Security checks with bandit (default: true)
- publish-enabled: Publish to PyPI (default: false)

Advanced Variables (show with --advanced):
- pytest-options: Additional pytest CLI options
- pylint-options: Additional pylint options
- build-directory: Custom build directory

Secret Variables (configure in GitLab UI):
- PYPI_TOKEN: PyPI authentication token (if publish-enabled)

Variants:
- python: Standard Python template
- python-vault: With HashiCorp Vault integration
- python-gcloud: With Google Cloud authentication
- python-aws: With AWS authentication

Examples:
---------
Component mode:
  - component: $CI_SERVER_FQDN/to-be-continuous/python/python@7
    inputs:
      image: "python:3.12-slim"
      build-system: "poetry"
      pytest-enabled: true

Project mode:
  - project: "to-be-continuous/python"
    ref: "7.5"
    file: "templates/gitlab-ci-python.yml"

For full configuration, use: /tbc wizard
```

### Step 4: Offer Next Actions

After showing templates, offer:

```
What would you like to do next?
- Generate a configuration with selected templates (/tbc)
- Run the guided wizard (/tbc:wizard)
- Learn about a specific template (ask me about it)
- Compare templates (e.g., "compare Docker vs Cloud Native Buildpacks")
```

## Detailed Reference Files

### For Build Templates
Read `${CLAUDE_PLUGIN_ROOT}/skills/building-with-tbc/references/build-templates.md`

Contains detailed information on all 15 build templates:
- Angular, Bash, DBT, GitLab Package, Go, Gradle, GNU Make, Maven, MkDocs, Node.js, PHP, pre-commit, Python, Scala/SBT, Sphinx

### For Deployment Templates
Read `${CLAUDE_PLUGIN_ROOT}/skills/building-with-tbc/references/deployment-templates.md`

Contains detailed information on all 11 deployment templates:
- Ansible, AWS, Azure, Cloud Foundry, Docker Compose, Google Cloud, Helm, Helmfile, Kubernetes, OpenShift, S3

### For Analysis Templates
Read `${CLAUDE_PLUGIN_ROOT}/skills/building-with-tbc/references/analysis-templates.md`

Contains detailed information on all 7 analysis templates:
- DefectDojo, Dependency Track, Gitleaks, MobSF, SonarQube, Spectral, SQLFluff

### For Variants
Read `${CLAUDE_PLUGIN_ROOT}/skills/building-with-tbc/references/variantes.md`

Contains information about template variants:
- Vault integration
- OIDC authentication
- Cloud-specific variants

## Comparison Mode

When user asks to compare templates (e.g., "compare Docker and CNB"):

```
Docker vs Cloud Native Buildpacks - Comparison
===============================================

Docker (to-be-continuous/docker)
---------------------------------
Approach: Build from Dockerfile
Tools: kaniko (default), buildah, docker-in-docker
Pros:
+ Full control over build process
+ Works with existing Dockerfiles
+ Widely understood and used
Cons:
- Requires maintaining Dockerfile
- Security best practices needed

Best for: Projects with existing Dockerfiles, custom build requirements

Cloud Native Buildpacks (to-be-continuous/cnb)
-----------------------------------------------
Approach: Auto-detect and build without Dockerfile
Tools: Paketo buildpacks
Pros:
+ No Dockerfile needed
+ Security best practices built-in
+ Auto-updates for base images
Cons:
- Less control over build process
- Learning curve for buildpack configs

Best for: New projects, standardized builds, less maintenance

Recommendation:
- Use Docker if you have existing Dockerfiles or need custom builds
- Use CNB for greenfield projects wanting less maintenance

Generate configuration: /tbc [your choice]
```

## Filter Examples

### By Category
- "show build templates"
- "list deployment options"
- "what analysis tools are available"

### By Technology
- "show Python templates" → Python build template
- "Kubernetes templates" → Kubernetes deployment + Helm
- "Docker templates" → Docker packaging template

### By Feature
- "templates with Vault support" → List all templates with Vault variants
- "templates for cloud deployment" → AWS, Azure, GCP
- "security scanning templates" → SonarQube, Gitleaks, etc.

## Remember

- ALWAYS load building-with-tbc skill first
- ALWAYS read from references (never hallucinate template lists)
- Show selection type (ONE vs MULTIPLE) for each category
- Mention variants when listing templates
- Offer to generate configurations after showing templates
- Use clear formatting for readability
