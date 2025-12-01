---
description: Validate a TBC configuration against schemas
argument-hint: Path to .gitlab-ci.yml file
allowed-tools: ["Read", "Bash", "Skill", "Task"]
---

# TBC Validate - Configuration Validator

**FIRST: Load the building-with-tbc skill** using the Skill tool to access TBC schemas and validation scripts.

## Purpose

Validate GitLab CI/CD configurations that use To-Be-Continuous templates against their JSON schemas to catch errors before running pipelines.

## Workflow

### Step 1: Get Configuration Input

**If user provided file path**:
- Use Read tool to load the file
- Verify it exists and contains YAML

**If user provided inline YAML**:
- Accept the pasted configuration directly

**If no input provided**:
- Check if `.gitlab-ci.yml` exists in current directory
- If yes: offer to validate it
- If no: ask user to provide file path or paste configuration

### Step 2: Invoke Validator Agent

Use the Task tool to invoke the `tbc-validator` agent:

```
Task: Validate this TBC configuration
Agent: tbc-validator
Input: [configuration content or file path]
```

The tbc-validator agent will:
1. Parse the configuration
2. Identify TBC components
3. Run validation against schemas
4. Return detailed results

### Step 3: Present Results

**If validation passes**:

```
✓ TBC Configuration Valid
=========================

Your configuration passed all validations.

Summary:
--------
- Components validated: [count]
- Total inputs checked: [count]
- No errors found

Components:
-----------
✓ to-be-continuous/python@7 - All inputs valid
✓ to-be-continuous/docker@7 - All inputs valid
✓ to-be-continuous/kubernetes@7 - All inputs valid

Your configuration is ready to use!

Next steps:
- Commit and push to trigger your pipeline
- Monitor the pipeline execution in GitLab
```

**If validation fails**:

```
✗ TBC Configuration Errors Found
=================================

Found [count] error(s) that need to be fixed:

[Display errors from validator agent with categories and fix suggestions]

Would you like me to help fix these errors?
```

### Step 4: Offer to Fix Errors

If validation found errors, offer to help:

**Question**: "Would you like me to fix these errors automatically?"

**If yes**:
1. Analyze each error
2. Apply fixes based on error type
3. Re-validate the fixed configuration
4. Show the corrected configuration

**If no**:
- Explain each error in detail
- Provide specific guidance on how to fix manually
- Offer to validate again after user makes changes

## Validation Error Types

The tbc-validator agent identifies these error categories:

### Component Errors
- Invalid component path
- Component not found in registry
- Malformed component reference syntax

**Example Fix**:
```
Error: Component 'to-be-continuous/python-invalid@7' not found
Fix: Did you mean 'to-be-continuous/python@7'?
```

### Version Errors
- Version not available for component
- Invalid version format
- Deprecated version warnings

**Example Fix**:
```
Error: Version v99.0.0 not available for python
Available: v7.0.0, v7.5.0, v7.5.2
Fix: Update to: component: ...python@7.5
```

### Input Errors
- Missing required input parameters
- Invalid input types (string vs number vs boolean)
- Unknown input parameters not in schema
- Value constraint violations (enum, pattern, range)

**Example Fix**:
```
Error: Unknown input 'build-sistem' for python
Did you mean: 'build-system'
Fix: Rename 'build-sistem' to 'build-system'
```

## Advanced Validation Options

### Strict Mode

If user requests strict validation:
- Check for deprecated features
- Warn about non-optimal configurations
- Suggest improvements

### Schema Coverage

Report which templates are being used:
- List all TBC components found
- Show which schemas were applied
- Identify any custom (non-TBC) includes

### Best Practices Check

Optionally check against TBC best practices:
- Version pinning strategy
- Secret variable usage
- Feature flag recommendations

Read `${CLAUDE_PLUGIN_ROOT}/skills/building-with-tbc/references/best-practices.md` for guidance.

## Common Validation Scenarios

### Scenario 1: Pre-commit Check

```
User: "Check if my pipeline config is ready to commit"

Action:
1. Validate configuration
2. If valid: Confirm it's ready
3. If errors: Fix and re-validate
4. Provide commit message suggestion
```

### Scenario 2: Post-generation Validation

```
Context: User just generated config with /tbc

Action:
1. Automatically validate (this should already happen in /tbc)
2. Confirm validation status
3. List any warnings (non-blocking issues)
```

### Scenario 3: Troubleshooting Failed Pipeline

```
User: "My pipeline is failing, can you check my config?"

Action:
1. Read the .gitlab-ci.yml
2. Validate against schemas
3. Check for common issues:
   - Missing secret variables
   - Wrong variable types
   - Invalid component versions
4. Explain errors in context of pipeline failure
```

### Scenario 4: Migration Validation

```
User: "I converted my pipeline to TBC, is it correct?"

Action:
1. Validate TBC configuration
2. Compare with best practices
3. Suggest optimizations if any
4. Confirm migration success
```

## Integration with Other Commands

### From /tbc Command
The `/tbc` command automatically validates before presenting configurations.
This command can be used for:
- Re-validation after manual changes
- Validation with different strictness levels

### After Manual Edits
When user manually edits a TBC configuration:
```
User: "I modified the config, can you validate it again?"

Action:
1. Read updated configuration
2. Re-validate
3. Compare with previous version if available
4. Highlight what changed and if it's still valid
```

## Output Examples

### Example 1: Successful Validation

```
✓ Configuration Validated Successfully
======================================

File: .gitlab-ci.yml
Mode: component
Templates: 3

Components Validated:
---------------------
1. to-be-continuous/python/python@7
   Inputs: 4 configured, 0 errors
   ✓ image: "python:3.12-slim"
   ✓ build-system: "poetry"
   ✓ pytest-enabled: true
   ✓ bandit-enabled: true

2. to-be-continuous/docker/docker@7
   Inputs: 2 configured, 0 errors
   ✓ image-name: "myapp"
   ✓ dockerfile: "Dockerfile"

3. to-be-continuous/kubernetes/kubernetes@7
   Inputs: 2 configured, 0 errors
   ✓ namespace: "production"
   ✓ deployment-file: "k8s/deployment.yml"

Secret Variables Required:
--------------------------
The following variables must be configured in GitLab UI:
• DOCKER_REGISTRY_USER
• DOCKER_REGISTRY_PASSWORD
• KUBE_CONFIG

Status: Ready to use ✓
```

### Example 2: Validation with Errors

```
✗ Validation Found 3 Errors
===========================

File: .gitlab-ci.yml

INPUT ERRORS:
-------------

[1] Component: to-be-continuous/python@7
    Input: 'build-sistem'
    Problem: Unknown input parameter
    ✗ Did you mean: 'build-system'?
    Fix: Rename 'build-sistem' to 'build-system'

[2] Component: to-be-continuous/docker@7
    Input: 'image-name'
    Problem: Missing required input
    Fix: Add 'image-name: "your-app-name"' to inputs

[3] Component: to-be-continuous/kubernetes@7
    Input: 'replicas'
    Problem: Invalid type
    Expected: integer
    Found: string ("3")
    Fix: Change to: replicas: 3 (remove quotes)

---

Would you like me to fix these errors? (yes/no)
```

### Example 3: Validation with Warnings

```
✓ Configuration Valid (with warnings)
=====================================

File: .gitlab-ci.yml
Errors: 0
Warnings: 2

Components validated successfully, but consider these improvements:

WARNINGS:
---------

[1] Component: to-be-continuous/python@7
    Version: @7 (major version pinning)
    ⚠ Consider using minor version pinning (@7.5) for better stability
    Impact: Low - will auto-update to v8.x when released

[2] Component: to-be-continuous/docker@7
    Feature: 'scan-enabled' not set
    ⚠ Consider enabling Docker image scanning
    Recommendation: Add 'scan-enabled: true' to inputs

Configuration is functional but could be improved.
Make changes? (yes/no/explain)
```

## Remember

- ALWAYS load building-with-tbc skill first
- ALWAYS use tbc-validator agent for actual validation
- Provide clear, actionable error messages
- Offer to fix errors automatically
- Explain validation results in user-friendly terms
- List required secret variables
- Suggest improvements when applicable
