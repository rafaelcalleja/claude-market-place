---
description: Get help with TBC plugin commands
allowed-tools: ["Read"]
---

# TBC Plugin Help

## Overview

Generate, validate, and manage GitLab CI/CD configurations using To-Be-Continuous (TBC) - 62 modular templates across 8 categories.

## Commands

| Command | Purpose |
|---------|---------|
| `/tbc [description]` | Generate configurations (main command) |
| `/tbc:wizard` | Guided 8-step wizard |
| `/tbc:templates [filter]` | Browse template catalog |
| `/tbc:validate [file]` | Validate configurations |
| `/tbc:help` | This help |

## Quick Start

**New project:**
```
/tbc:wizard
```

**Specific request:**
```
/tbc create Python pipeline with Docker and Kubernetes
```

**Migrate existing:**
```
/tbc migrate my .gitlab-ci.yml to TBC
```

**Explore templates:**
```
/tbc:templates deployment
```

## Template Categories

| Category | Count | Selection |
|----------|-------|-----------|
| Build | 15 | Single |
| Code Analysis | 7 | Multiple |
| Packaging | 3 | Single |
| Infrastructure | 1 | Single |
| Deployment | 11 | Single |
| Acceptance | 10 | Multiple |
| Other | 3 | Multiple |

## Configuration Modes

- **component** (GitLab 16.0+) - Recommended
- **project** (Self-hosted)
- **remote** (External GitLab)

## Troubleshooting

**Pipeline fails:**
1. Run `/tbc:validate`
2. Check secret variables in GitLab UI
3. Review error messages

**Unknown input error:**
- Check for typos
- Verify variable name transformation

**Component not found:**
- Verify GitLab version (16.0+ for component mode)
- Consider project/remote mode

## Plugin Architecture

```
building-with-tbc (skill)     ← Knowledge base
    ↓
/tbc, /tbc:wizard, etc.       ← Commands (orchestration)
    ↓
validate-inputs.py            ← Validation script
```

## Resources

All knowledge is in the `building-with-tbc` skill:
- `references/` - Template documentation
- `schemas/` - JSON schemas (51 files)
- `examples/` - Working configurations

## Version

Plugin: 0.6.0 | TBC Framework: Current templates
