---
description: Generate comprehensive project statistics including LOC, file counts, and language breakdown
---

# Project Statistics Command

Generate detailed statistics about the current project.

## Context

- Current directory: !`pwd`
- Git status: !`git status --short 2>/dev/null || echo "Not a git repository"`

## Your Task

Provide comprehensive project statistics:

1. **File Statistics**
   - Total number of files
   - Breakdown by file type
   - Largest files (top 5)

2. **Code Metrics**
   - Lines of code by language
   - Total LOC
   - Comment ratio (if detectable)

3. **Git Information** (if available)
   - Current branch
   - Number of commits
   - Contributors
   - Last commit date

4. **Project Health**
   - Presence of README, LICENSE, tests
   - Configuration files present

Present the information in a clean, organized format using tables or lists.
