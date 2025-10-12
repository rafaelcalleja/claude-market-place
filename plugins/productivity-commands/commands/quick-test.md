---
description: Run tests for the current project quickly
allowed-tools: Bash(npm:*), Bash(pytest:*), Bash(go:*), Bash(cargo:*)
---

# Quick Test Command

Run the appropriate test suite based on the project type.

## Context

- Current directory: !`pwd`
- Package manager files: !`ls -la | grep -E "(package\.json|requirements\.txt|go\.mod|Cargo\.toml)"`

## Your Task

1. Detect the project type based on files present
2. Run the appropriate test command:
   - Node.js: `npm test` or `npm run test`
   - Python: `pytest` or `python -m pytest`
   - Go: `go test ./...`
   - Rust: `cargo test`
3. Display the test results clearly
4. If tests fail, provide a brief summary of failures

IMPORTANT: Only use the tools specified in allowed-tools. Do not use any other tools.
