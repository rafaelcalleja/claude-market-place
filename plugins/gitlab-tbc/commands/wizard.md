---
description: Guided 8-step wizard to generate GitLab CI/CD configuration
allowed-tools: ["Read", "AskUserQuestion", "Skill", "Task"]
---

# TBC Wizard - Guided Configuration Generator

**FIRST: Load the building-with-tbc skill** using the Skill tool to access TBC specifications and schemas.

## Overview

This command replicates the TBC Kicker web wizard workflow: an 8-step guided process to generate `.gitlab-ci.yml` configurations.

## Wizard Workflow

### Step 0: Configure Global Options

Before template selection, configure these settings using AskUserQuestion:

#### Question 1: Include Mode

**Question**: "Which include mode do you want to use?"

**Options**:
- **component** (Recommended for GitLab 16.0+)
  - Description: Modern syntax using `$CI_SERVER_FQDN/path/template@version`
- **project** (Self-hosted GitLab)
  - Description: Traditional syntax with project paths and refs
- **remote** (External GitLab)
  - Description: Direct HTTPS URLs to template files

#### Question 2: Version Mode

**Question**: "How do you want to manage template versions?"

**Options**:
- **minor** (@7.5) - Recommended
  - Description: Auto-updates patches, stable features
- **major** (@7) - Latest features
  - Description: Auto-updates major versions, may break
- **full** (@7.5.2) - Maximum stability
  - Description: No auto-updates, fully pinned

#### Question 3: Configuration Detail

**Question**: "What level of configuration detail?"

**Options**:
- **basic** - Essential variables only
  - Description: Show only mandatory and commonly used options
- **advanced** - All configuration options
  - Description: Show all variables including advanced settings

#### Question 4: Custom Stages (Optional)

**Question**: "Do you want to include a custom stages section?"

**Options**:
- **No** (default)
- **Yes** - Will include stages definition in output

Store these settings for use in later steps.

---

### Step 1: Build (Language)

**Question**: "Select your build template (language/framework):"

**Instructions**: Read `${CLAUDE_PLUGIN_ROOT}/skills/building-with-tbc/references/build-templates.md` to get the complete list.

**Options** (using AskUserQuestion, multiSelect: false):
- Angular
- Bash
- DBT (Data Build Tool)
- GitLab Package
- Go
- Gradle
- GNU Make
- Maven
- MkDocs
- Node.js
- PHP
- pre-commit
- Python
- Scala/SBT
- Sphinx
- **None** (no build template)

**After selection**:
- If NOT "None": Read the schema for the selected template
- Ask for mandatory variables
- Store selection and configuration

---

### Step 2: Code Analysis

**Question**: "Select code analysis tools (you can select multiple):"

**Instructions**: Read `${CLAUDE_PLUGIN_ROOT}/skills/building-with-tbc/references/analysis-templates.md`.

**Options** (using AskUserQuestion, multiSelect: true):
- DefectDojo - Security report aggregation
- Dependency Track - SBOM & vulnerability tracking
- Gitleaks - Secret detection in code
- MobSF - Mobile app security testing
- SonarQube - Code quality & security analysis
- Spectral - OpenAPI/AsyncAPI linting
- SQLFluff - SQL linting

**After selections**:
- For each selected tool: Read its schema
- Ask for mandatory variables for each
- Store all selections and configurations

---

### Step 3: Packaging

**Question**: "Select your packaging method:"

**Options** (using AskUserQuestion, multiSelect: false):
- Docker - Build Docker images (kaniko/buildah/dind)
- Cloud Native Buildpacks - Paketo buildpacks
- Source-to-Image - OpenShift S2I
- **None** (no packaging)

**After selection**:
- If NOT "None": Read schema and configure
- For Docker: Ask about image name, registry, Dockerfile path
- Store selection and configuration

---

### Step 4: Infrastructure

**Question**: "Do you need Infrastructure as Code?"

**Options** (using AskUserQuestion, multiSelect: false):
- Terraform - Manage infrastructure with Terraform
- **None** (no IaC)

**After selection**:
- If Terraform: Read schema and configure
- Common variables: version, working directory, cloud provider
- Store selection and configuration

---

### Step 5: Deployment

**Question**: "Select your deployment target:"

**Instructions**: Read `${CLAUDE_PLUGIN_ROOT}/skills/building-with-tbc/references/deployment-templates.md`.

**Options** (using AskUserQuestion, multiSelect: false):
- Ansible - Configuration management
- AWS - Amazon Web Services
- Azure - Microsoft Azure
- Cloud Foundry - Cloud Foundry PaaS
- Docker Compose - Docker Compose/Stack
- Google Cloud - Google Cloud Platform
- Helm - Kubernetes Helm charts
- Helmfile - Helmfile deployments
- Kubernetes - kubectl deployments
- OpenShift - OpenShift deployments
- S3 - S3-compatible storage
- **None** (no deployment)

**After selection**:
- If NOT "None": Read schema and configure
- Ask for environment-specific variables
- Consider variants (OIDC for cloud providers)
- Store selection and configuration

---

### Step 6: Acceptance Tests

**Question**: "Select acceptance test frameworks (you can select multiple):"

**Options** (using AskUserQuestion, multiSelect: true):
- Bruno - API testing
- Cypress - E2E web testing
- Hurl - HTTP testing
- k6 - Load testing
- Lighthouse - Web performance testing
- Playwright - E2E testing
- Postman - API testing
- Puppeteer - Browser automation
- Robot Framework - Test automation
- TestSSL - TLS/SSL testing

**After selections**:
- For each selected framework: Read schema
- Configure test-specific variables
- Store all selections and configurations

---

### Step 7: Other Templates

**Question**: "Select utility templates (you can select multiple):"

**Options** (using AskUserQuestion, multiSelect: true):
- GitLab Butler - Project cleanup automation
- Renovate - Automated dependency updates
- Semantic Release - Automated version management

**After selections**:
- For each selected utility: Read schema
- Configure utility-specific variables
- Store all selections and configurations

---

### Step 8: Generate Configuration

Now generate the `.gitlab-ci.yml` file with all selections.

#### Generation Process

1. **Collect all selections** from steps 1-7

2. **Build the include section** based on global options (step 0):

   **If component mode**:
   ```yaml
   include:
     - component: $CI_SERVER_FQDN/to-be-continuous/[category]/[template]@[version]
       inputs:
         [transformed-variable-names]: [values]
   ```

   **If project mode**:
   ```yaml
   include:
     - project: "to-be-continuous/[category]"
       ref: "[version]"
       file: "templates/gitlab-ci-[template].yml"

   variables:
     [ORIGINAL_VARIABLE_NAMES]: [values]
   ```

   **If remote mode**:
   ```yaml
   include:
     - remote: "https://[host]/to-be-continuous/[category]/-/raw/[version]/templates/gitlab-ci-[template].yml"

   variables:
     [ORIGINAL_VARIABLE_NAMES]: [values]
   ```

3. **Transform variable names** if using component mode:
   - Remove template prefix (e.g., PYTHON_IMAGE → IMAGE)
   - Convert to lowercase (IMAGE → image)
   - Replace underscores with hyphens (BUILD_SYSTEM → build-system)

4. **Separate secret variables**:
   - Add comment section listing all secret variables
   - Do NOT include secret variable values in the file
   - Explain they must be set in GitLab UI

5. **Add custom stages** if user requested in step 0

#### Validation Step

**CRITICAL**: Before presenting the configuration:

1. Use Task tool to invoke the `tbc-validator` agent
2. Pass the generated configuration for validation
3. Wait for validation results

**If validation passes**:
- Present the configuration to user
- Include secret variables list
- Provide next steps

**If validation fails**:
- Review the errors
- Fix the configuration
- Re-validate
- Only present after successful validation

#### Output Format

Present to user:

```
✓ TBC Configuration Generated Successfully

Here's your .gitlab-ci.yml configuration:

[Generated YAML content]

---

Secret Variables Required:
Configure these in GitLab → Settings → CI/CD → Variables:

- VARIABLE_NAME_1: Description of what this is
- VARIABLE_NAME_2: Description of what this is

---

Next Steps:
1. Copy this configuration to your repository's .gitlab-ci.yml
2. Configure the secret variables in GitLab UI
3. Commit and push to trigger your first pipeline

Would you like me to explain any part of this configuration?
```

## Variable Configuration Pattern

For each template selected, follow this pattern:

1. **Read schema** from `${CLAUDE_PLUGIN_ROOT}/skills/building-with-tbc/schemas/[template-name].json`

2. **Extract variables**:
   ```
   For each variable in schema:
     - Check if mandatory
     - Check if secret
     - Check if advanced (skip if not in advanced mode)
     - Get default value
     - Get type (text, boolean, enum, number, url)
   ```

3. **Ask user** using AskUserQuestion:
   - Only ask for mandatory variables in basic mode
   - Ask for all non-secret variables in advanced mode
   - Never ask for secret variables (list them for GitLab UI setup)

4. **Store values** for final generation

## Features and Variants

When configuring templates, also check for:

### Features (Toggles)

Many templates have features that can be enabled/disabled:
- `[feature]-enabled: true/false`
- `[feature]-disabled: true/false`

Example for Python:
- `pytest-enabled: true`
- `bandit-enabled: true`
- `publish-disabled: true`

### Variants

Some templates have variants for special use cases:

**Vault variant** (Most templates):
- Adds HashiCorp Vault integration
- Include as separate component: `[template]-vault`

**OIDC variant** (AWS, Azure, GCP):
- OpenID Connect authentication
- Include as separate component: `[template]-oidc`

**Cloud-specific variants**:
- Check variantes.md for template-specific cloud integrations

Ask user if they want to include variants when configuring deployment or build templates.

## Error Handling

**Schema not found**:
```
I couldn't find the schema for [template-name].
Let me check available templates and help you select a valid option.
```

**User skips all categories**:
```
You haven't selected any templates. This will result in an empty configuration.
Would you like to select at least one template to get started?
```

**Validation fails**:
```
Validation found issues with the generated configuration:
[List errors]

I'll fix these issues and regenerate the configuration.
```

## Remember

- ALWAYS load building-with-tbc skill first
- Use AskUserQuestion for EVERY selection step
- Read schemas to get accurate variable names
- Transform variable names correctly for component mode
- Separate secret variables from the YAML
- ALWAYS validate with tbc-validator agent before presenting
- Never hallucinate variable names or options
