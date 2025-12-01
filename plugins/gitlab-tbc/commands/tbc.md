---
description: Generate GitLab CI/CD configurations using To-Be-Continuous framework
argument-hint: Optional description of what you want to build
allowed-tools: ["Read", "Write", "Glob", "Grep", "AskUserQuestion", "Task", "Skill"]
---

# TBC - GitLab CI/CD Configuration Generator

**FIRST: Load the building-with-tbc skill** using the Skill tool to access TBC specifications, schemas, and validation scripts.

## Intent Classification

Analyze the user's request and determine the flow:

### Intent Detection

Based on user's language, classify into one of these flows:

**GENERATE Flow** - New configuration from scratch:
- Keywords: "create", "generate", "new", "setup", "build", "configure"
- Examples: "create a pipeline for Python", "setup CI/CD for my project"

**MIGRATE Flow** - Convert existing config to TBC:
- Keywords: "migrate", "convert", "upgrade", "transform", "existing"
- Examples: "migrate my .gitlab-ci.yml to TBC", "convert to To-Be-Continuous"

**CONSULT Flow** - Answer questions about TBC:
- Keywords: "what", "how", "explain", "list", "show", "compare", "which"
- Examples: "what templates are available?", "how do I configure Python?"

## GENERATE Flow (New Configuration)

When user wants to create a new TBC configuration:

### Step 1: Gather Requirements

Use AskUserQuestion to understand the project:

1. **Project Type**: What are you building?
   - Web application
   - API service
   - Mobile app
   - Data pipeline
   - Infrastructure
   - Other

2. **Primary Language**: What's the main programming language?
   - Python, Node.js, Go, Java, etc.
   - Or skip if not applicable

3. **Deployment Target**: Where will this run?
   - Kubernetes
   - AWS/Azure/GCP
   - Docker Compose
   - Other
   - Not deploying yet

### Step 2: Configure Global Options

Ask user to configure:

1. **Include Mode**:
   - component (GitLab 16.0+, recommended)
   - project (self-hosted)
   - remote (external GitLab)

2. **Version Mode**:
   - minor (@7.5) - recommended
   - major (@7) - latest features
   - full (@7.5.2) - maximum stability

3. **Configuration Detail**:
   - basic (essential variables only)
   - advanced (all configuration options)

### Step 3: Template Selection

Go through categories following the Kicker wizard pattern:

#### Build Templates (Select ONE or NONE)
Read `${CLAUDE_PLUGIN_ROOT}/skills/building-with-tbc/references/build-templates.md` and present options based on user's language choice.

Common templates:
- Python, Node.js, Go, Java (Maven/Gradle), Angular, PHP, etc.

#### Code Analysis (Select MULTIPLE)
Read `${CLAUDE_PLUGIN_ROOT}/skills/building-with-tbc/references/analysis-templates.md`.

Common tools:
- SonarQube (code quality)
- Gitleaks (secret detection)
- DefectDojo (security aggregation)

#### Packaging (Select ONE or NONE)
Options:
- Docker (most common)
- Cloud Native Buildpacks
- Source-to-Image

#### Infrastructure (Select ONE or NONE)
Options:
- Terraform
- None

#### Deployment (Select ONE or NONE)
Read `${CLAUDE_PLUGIN_ROOT}/skills/building-with-tbc/references/deployment-templates.md`.

Based on user's deployment target:
- Kubernetes, Helm, AWS, Azure, GCP, etc.

#### Acceptance Tests (Select MULTIPLE)
Options:
- Cypress, Playwright, Postman, k6, etc.

#### Other Utilities (Select MULTIPLE)
Options:
- Renovate (dependency updates)
- Semantic Release (version management)
- GitLab Butler (cleanup)

### Step 4: Configure Variables

For each selected template:

1. **Read its JSON schema** from `${CLAUDE_PLUGIN_ROOT}/skills/building-with-tbc/schemas/[template-name].json`

2. **Extract variables** from schema with their:
   - name
   - type
   - default value
   - mandatory flag
   - secret flag
   - advanced flag

3. **Ask user for mandatory variables** only (unless advanced mode)

4. **Transform variable names** if using component mode:
   - Strip template prefix
   - Convert to lowercase
   - Replace underscores with hyphens

### Step 5: Generate Configuration

Generate `.gitlab-ci.yml` with this structure:

```yaml
include:
  # [Generated includes based on selections]

# secret variables
# (define the variables below in your GitLab group/project variables)
# [List of secret variables needed]

# Optional: custom variables
variables:
  # [Non-secret variables if any in project/remote mode]
```

### Step 6: CRITICAL - Validate Before Presenting

**MANDATORY STEP**: Before showing the generated configuration to the user, invoke the `tbc-validator` agent using the Task tool:

```
Task: Validate this TBC configuration
Agent: tbc-validator
Input: [the generated .gitlab-ci.yml content]
```

**Never skip validation**. Only present the configuration after validation passes or after explaining validation errors and offering to fix them.

### Step 7: Present Results

Show the user:
1. The validated `.gitlab-ci.yml` configuration
2. List of secret variables they need to configure in GitLab
3. Next steps (how to use the configuration)

## MIGRATE Flow (Convert Existing Config)

When user wants to convert an existing `.gitlab-ci.yml` to TBC:

### Step 1: Read Existing Configuration

Ask for the file path or have user paste their current `.gitlab-ci.yml`.

### Step 2: Analyze Current Configuration

Identify:
1. **Build jobs**: Language, package manager, test frameworks
2. **Docker builds**: Dockerfile, image names
3. **Deployment**: Where and how they deploy
4. **Testing**: What test types they run

### Step 3: Map to TBC Templates

For each aspect identified, suggest equivalent TBC templates:

- Language builds → Build templates
- Code quality tools → Analysis templates
- Docker builds → docker template
- Kubernetes/cloud → Deployment templates

### Step 4: Generate TBC Equivalent

Create a TBC configuration that achieves the same outcome as their current pipeline.

### Step 5: Show Migration Plan

Present:
1. **Current**: Summary of their existing pipeline
2. **Proposed**: TBC configuration
3. **Benefits**: What they gain (standardization, maintenance, features)
4. **Migration steps**: How to transition safely

### Step 6: Validate

Use tbc-validator agent to validate the proposed TBC configuration.

## CONSULT Flow (Answer Questions)

When user has questions about TBC:

### Step 1: Identify Topic

Determine what they're asking about:
- Available templates
- Specific template configuration
- Template comparison
- Best practices
- Examples

### Step 2: Read Relevant References

Based on topic, read the appropriate reference file:

- Templates catalog: `references/templates-catalog.md`
- Build templates: `references/build-templates.md`
- Deployment: `references/deployment-templates.md`
- Analysis: `references/analysis-templates.md`
- Variants: `references/variantes.md`
- Best practices: `references/best-practices.md`
- Presets: `references/presets.md`

### Step 3: Provide Information

Answer the user's question with:
- Clear, concise explanation
- Code examples if relevant
- References to documentation
- Related suggestions

### Step 4: Offer Next Steps

Ask if they want to:
- Generate a configuration
- Learn about related templates
- See examples

## Error Handling

If anything goes wrong:

1. **Schema not found**: Check if template name is correct, list available schemas
2. **Validation fails**: Explain errors clearly, offer to fix
3. **User unclear**: Ask clarifying questions
4. **Missing information**: Request needed details

## Quality Standards

1. **Never hallucinate**: Always read schemas for accurate variable names
2. **Always validate**: Use tbc-validator before presenting configs
3. **Transform names correctly**: Component mode requires specific format
4. **Document secrets**: Always list secret variables needed
5. **Be concise**: Don't overwhelm with options, guide progressively

## Examples

### Example 1: Python Microservice
```
User: "Create a pipeline for my Python FastAPI microservice with Docker and Kubernetes"
Assistant: [Loads skill, asks configuration preferences, selects python + docker + kubernetes templates, configures variables, validates, presents config]
```

### Example 2: Migration
```
User: "Convert my existing .gitlab-ci.yml to use TBC"
Assistant: [Loads skill, reads existing config, analyzes jobs, maps to TBC templates, generates equivalent, validates, shows migration plan]
```

### Example 3: Consultation
```
User: "What deployment options are available in TBC?"
Assistant: [Loads skill, reads deployment-templates.md, explains 11 deployment templates with brief descriptions, offers examples]
```

## Remember

- ALWAYS load building-with-tbc skill first
- ALWAYS validate generated configs with tbc-validator agent
- ALWAYS read schemas - never guess variable names
- ALWAYS transform names for component mode
- ALWAYS document secret variables
