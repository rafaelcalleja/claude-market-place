---
description: Analyze project dependencies for security vulnerabilities and outdated packages
---

# Dependency Analysis Command

Analyze project dependencies for security issues and version updates.

## Context

- Current directory: !`pwd`
- Package files: !`find . -maxdepth 2 -name "package.json" -o -name "requirements.txt" -o -name "go.mod" -o -name "Cargo.toml" 2>/dev/null`

## Your Task

1. Identify the project's dependency management system
2. Check for:
   - Security vulnerabilities in dependencies
   - Outdated packages
   - Dependency conflicts
3. Provide a clear summary with:
   - Total dependencies
   - Number of vulnerabilities (if any)
   - Critical updates recommended
4. Suggest commands to update or fix issues

Use appropriate tools like `npm audit`, `pip-audit`, or equivalent for the detected project type.
