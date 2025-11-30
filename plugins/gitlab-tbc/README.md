# GitLab to-be-continuous Plugin

Interactive guide for building GitLab CI/CD pipelines using the [to-be-continuous](https://to-be-continuous.gitlab.io/doc) template ecosystem.

## Overview

This plugin acts as a **conversational expert** that helps you build GitLab CI/CD pipelines step-by-step:
- 💬 **Interactive guidance**: Ask for a template, get configuration + "what else do you need?"
- 🔍 **Discover** templates from 110+ available options
- 📖 **Real examples**: Shows actual configs from GitLab (never invented)
- 🧩 **Build incrementally**: Adds components based on your responses
- 📚 **Learn** from 31 real-world samples with working `.gitlab-ci.yml` files

## Features

### v0.3.0 - Current (Component Creation)

- **Interactive Guidance**: Conversational workflow that builds pipelines step-by-step
- **Template Discovery**: Search templates by technology stack
- **Real Configuration**: Fetches actual docs/examples from GitLab (deterministic, never invented)
- **Modern Syntax**: Shows only `component:` syntax (best practices, no legacy)
- **Incremental Building**: Asks "what else?" to add components interactively
- **Sample Pipelines**: View real `.gitlab-ci.yml` from 31 working examples
- **Intelligent Suggestions**: Recommends complementary templates based on your stack
- **Component Creation**: NEW - Guide for creating to-be-continuous components following ecosystem standards
- **Variant Patterns**: NEW - Learn 70+ variant patterns (vault, oidc, gcp, aws, eks, ecr)
- **Ecosystem Coherence**: If no match exists, guides to create to-be-continuous component (never custom scripts)

### Roadmap

- **Local Template Sync**: Download templates for offline access
- **Pipeline Orchestration**: Create and update `.gitlab-ci.yml` files
- **Template Creation**: Build new templates following TBC patterns
- **Gap Analysis**: Identify missing templates in the ecosystem

## Installation

### Option 1: Local Testing
```bash
cc --plugin-dir /home/rcalleja/github/nalanda/documents_stored_procedures/gitlab-tbc
```

### Option 2: Install to Claude plugins directory
```bash
cp -r gitlab-tbc ~/.claude/plugins/
```

## Usage

### Interactive Conversational Guide

The plugin guides you through building your pipeline step-by-step:

```
You: /discover semantic-release

Plugin:
✅ Sí, tenemos semantic-release en to-be-continuous

📖 Configuración:
Añade esto a tu .gitlab-ci.yml:

include:
  - component: $CI_SERVER_FQDN/to-be-continuous/semantic-release/gitlab-ci-semrel@4.0.1
    inputs:
      changelog-enabled: true

📚 Ejemplos Reales:
- python-on-kubernetes [link]
- node-on-azure [link]

💬 ¿Necesitas algo más para tu pipeline?
- 🔐 Autenticación (npm, PyPI, Maven Central)
- 🔒 Seguridad (Gitleaks, SonarQube)
- 🧪 Testing (Postman, Cypress)

You: autenticación npm

Plugin:
Perfecto, para semantic-release + npm:
[shows npm template config]

💬 ¿Algo más?
- Testing (Jest, Mocha)
- Linting (ESLint)

You: ya está gracias

Plugin:
Perfecto! 🎯 Tu pipeline tendrá:
✓ semantic-release
✓ npm publish
```

### Quick Commands

Find templates for your technology stack:

```bash
/discover python docker kubernetes
```

Ask naturally:
```
"What templates exist for Python with Docker and Kubernetes?"
"How do I use the semantic-release template?"
"Show me the real configuration for Docker template"
"I need a pipeline for testing with Playwright"
"Show me templates for deploying to AWS"
"Show me the pipeline for python-on-kubernetes sample"
```

View real working pipelines from samples:
```bash
# After getting sample recommendations
"Show me the pipeline for python-on-kubernetes"
"How is python-serverless-on-aws configured?"
```

**Features:**
- 🔍 Search 110+ templates by technology
- 📚 Fetch real README documentation from GitLab
- 🔧 **View real `.gitlab-ci.yml` from sample projects**
- ✅ Only shows official examples (never invents)
- 🔗 Direct links to template repositories
- 💡 Intelligent suggestions for complementary templates
- 📋 See how templates compose together in practice

## Components

### Commands

- `/discover [technologies...]` - Search for templates by technology stack

### Skills

- `template-discovery` - Intelligent template search and recommendation with 70+ variant catalog
- `component-creator` - Guide for creating to-be-continuous components following ecosystem standards

## to-be-continuous Ecosystem

The plugin integrates with 110 templates across:

- **62 Main Templates**: Build, test, deploy, and security templates
- **31 Sample Projects**: Real-world examples and combinations
- **17 Tools**: Utilities and helper projects

### Popular Templates

- **Build**: Python, Node.js, Maven, Gradle, Go, Rust, .NET
- **Containerization**: Docker, Cloud Native Buildpacks
- **Testing**: Cypress, Playwright, Postman, Robot Framework
- **Deployment**: Kubernetes, Helm, AWS, Azure, GCP
- **Security**: SonarQube, Gitleaks, DefectDojo
- **Release**: semantic-release, Renovate

## Documentation

- [to-be-continuous Documentation](https://to-be-continuous.gitlab.io/doc)
- [Template Catalog](./skills/template-discovery/references/catalog.md)
- [GitLab Group](https://gitlab.com/to-be-continuous)

## Contributing

This plugin follows to-be-continuous philosophy:
- Component-based architecture
- Composable templates
- Best practices by default

## License

MIT

---

*Built with ❤️ for the GitLab CI/CD community*
