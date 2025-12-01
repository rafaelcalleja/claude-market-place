---
name: building-with-tbc
description: This skill should be used when the user asks to "generate gitlab-ci.yml",
  "create GitLab CI pipeline", "configure GitLab CI/CD", "use To-Be-Continuous templates",
  "setup TBC templates", "create CI/CD for Python/Node/Go/Java project", "configure
  Docker build in GitLab", "setup Kubernetes deployment in GitLab", "add SonarQube
  to GitLab CI", "configure Terraform with GitLab", or mentions "TBC", "To-Be-Continuous",
  "Kicker".
version: 1.0.0
---

# Building with To-Be-Continuous (TBC)

Knowledge base for generating GitLab CI/CD configurations using the To-Be-Continuous framework.

## CRITICAL: Framework-First Principle

**NEVER assume a solution. ALWAYS evaluate the framework first.**

Before taking any action, follow this priority hierarchy:

```
┌─────────────────────────────────────────────────────────────┐
│                 SOLUTION PRIORITY HIERARCHY                 │
├─────────────────────────────────────────────────────────────┤
│ 1. TBC template exists and covers use case completely       │
│    → Use TBC component directly                             │
├─────────────────────────────────────────────────────────────┤
│ 2. TBC template exists, variant covers use case             │
│    → Use TBC component + existing variant                   │
├─────────────────────────────────────────────────────────────┤
│ 3. Different TBC template's variant fits better             │
│    → Use alternative component + create variant             │
├─────────────────────────────────────────────────────────────┤
│ 4. TBC template needs extension                             │
│    → Use TBC component + custom script                      │
├─────────────────────────────────────────────────────────────┤
│ 5. No TBC template fits                                     │
│    → Custom job (MUST document why TBC doesn't fit)         │
└─────────────────────────────────────────────────────────────┘
```

**Mandatory Process:**
1. Identify user's core need (action + target + triggers)
2. Read `references/component-decision.md` and follow the decision flowchart
3. Search templates in `references/templates-catalog.md`
4. Read `schemas/_meta.json` + `schemas/{template}.json` for exact capabilities
5. Check `references/variantes.md` for variants
6. Perform Deep Research if partial match (see `references/component-decision.md`)
7. Only after exhausting framework options, consider custom solutions

**The user may request something and be incorrect about the approach.** This skill disciplines correct framework usage.

## Overview

To-Be-Continuous (TBC) is a framework of 62 modular templates organized into 8 categories for building GitLab CI/CD pipelines.

### Template Categories

| Category | Count | Selection |
|----------|-------|-----------|
| Build | 15 | Single |
| Code Analysis | 7 | Multiple |
| Packaging | 3 | Single |
| Infrastructure | 1 | Single |
| Deployment | 11 | Single |
| Acceptance | 10 | Multiple |
| Other | 3 | Multiple |

**Selection Rules:**
- Build, Packaging, Infrastructure, Deployment: SELECT ONE or NONE
- Code Analysis, Acceptance, Other: SELECT MULTIPLE (including none)

## Configuration Modes

| Mode | GitLab Version | Syntax |
|------|----------------|--------|
| component | 16.0+ (recommended) | `$CI_SERVER_FQDN/path/template@version` |
| project | Self-hosted | `project: "path"` + `ref` + `file` |
| remote | External | HTTPS URL to template |

## Version Modes

| Mode | Syntax | Updates |
|------|--------|---------|
| major | `@7` | Auto major (less stable) |
| minor | `@7.5` | Auto patch (recommended) |
| full | `@7.5.2` | None (most stable) |

## Generating Configurations

When generating a TBC configuration, read and follow `references/create-component.md`.

## Evaluating Component Fit

Before generating, determine if TBC components fit the use case. Read `references/component-decision.md` for the decision process with flowcharts.

## Reference Files

| Need | Reference |
|------|-----------|
| Decide if component fits | `references/component-decision.md` |
| Complete template catalog | `references/templates-catalog.md` |
| Build templates (15) | `references/build-templates.md` |
| Deployment templates (11) | `references/deployment-templates.md` |
| Analysis templates (7) | `references/analysis-templates.md` |
| Variants (Vault, OIDC) | `references/variantes.md` |
| Common presets | `references/presets.md` |
| Best practices | `references/best-practices.md` |
| Configuration formats | `references/configuration-formats.md` |

## Schemas

All templates have JSON schemas in `schemas/`. Read schema to get valid inputs, components, and versions:

```
schemas/{template-name}.json
```

## Example Configurations

Working examples in `examples/`:
- `python-docker-k8s.yml`
- `node-sonar-docker.yml`
- `terraform-aws.yml`
- `java-maven-cf.yml`

## Validation

Use SlashCommand tool with `tbc:validate`.

## Key Principles

1. Read schemas first - templates have specific variables, don't hallucinate
2. Transform names for component mode - lowercase with hyphens
3. Validate before presenting - use `tbc:validate`
4. Respect selection rules - single vs multiple per category
5. Document secret variables - they go in GitLab CI/CD settings
6. Use `$CI_SERVER_FQDN` for component mode
