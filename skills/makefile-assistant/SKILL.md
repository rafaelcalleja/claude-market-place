---
name: makefile-assistant
description: Automatically capture Bash commands executed by Claude Code and convert them into documented, organized Makefile targets in .claude/makefiles/. This skill activates when Claude Code executes any Bash command, analyzes it for reusability, detects similar existing targets, and interactively creates maintainable Makefile infrastructure.
---

# Makefile Assistant

## Overview

Makefile Assistant automatically captures interesting Bash commands executed by Claude Code (via `cchistory`) and transforms them into well-documented, categorized Makefile targets. This eliminates manual Makefile maintenance and creates a living documentation of your project's common commands.

## When to Use This Skill

Use this skill when:
- Claude Code executes a Bash command (automatically triggers)
- User explicitly requests Makefile generation or updates
- User asks to document, organize, or simplify repetitive project tasks
- User requests analysis of existing Makefiles

## How It Works

### Automatic Workflow

1. **Detection**: When Claude executes a Bash command, the skill activates
2. **Analysis**: Reads new commands from `cchistory` since last check
3. **Filtering**: Ignores trivial commands (ls, cd, pwd, etc.)
4. **Similarity Check**: Compares against existing targets in `.claude/makefiles/`
5. **User Confirmation**: Uses `AskUserQuestion` to confirm target creation
6. **Generation**: Creates target with "When to use" documentation
7. **Categorization**: Places target in appropriate .mk file (testing.mk, docker.mk, etc.)
8. **Help Update**: Regenerates root Makefile help target

### Generated Structure

```
project/
├── Makefile (root - includes all .mk files)
└── .claude/
    ├── .makefile-last-line (state tracking)
    └── makefiles/
        ├── testing.mk
        ├── linting.mk
        ├── docker.mk
        ├── build.mk
        ├── database.mk
        ├── deploy.mk
        ├── dev.mk
        ├── clean.mk
        └── misc.mk
```

## Usage Instructions

### Step 1: Analyze Recent Commands

Execute the analysis script to check for new commands since last run:

```bash
python scripts/analyze_session.py
```

This returns JSON with interesting commands:
```json
[
  {
    "line_num": 42,
    "command": "pytest tests/ --cov=src"
  }
]
```

### Step 2: Check for Similar Targets

For each command, check if similar targets already exist:

```bash
python scripts/detect_similar.py "pytest tests/ --cov=src" .claude/makefiles
```

Returns similarity analysis:
```json
[
  {
    "name": "test",
    "command": "pytest tests/",
    "when_to_use": "Run all tests",
    "file": "testing.mk",
    "similarity": 0.95
  }
]
```

### Step 3: Ask User for Confirmation

Use `AskUserQuestion` to confirm action based on similarity:

**If similarity ≥ 0.95 (almost identical):**
```
Question: "Target 'test' is very similar to 'pytest tests/ --cov=src'. What should I do?"
Options:
  - Update existing target
  - Create new variant
  - Skip
```

**If similarity 0.7-0.95 (similar):**
```
Question: "Create new target 'test-coverage'? (similar to existing 'test')"
Options:
  - Yes
  - Yes with different name
  - No
```

**If similarity < 0.7 (different):**
```
Question: "Add 'pytest tests/ --cov=src' as a Makefile target?"
Options:
  - Yes
  - Yes with custom name
  - No
```

### Step 4: Categorize Target

Determine the appropriate .mk file:

```bash
python scripts/categorize_target.py "pytest tests/ --cov=src"
```

Returns:
```json
{
  "category": "testing.mk",
  "confidence": "high",
  "alternatives": []
}
```

If confidence is low or user prefers, ask for category confirmation.

### Step 5: Generate Target

Create the target using the template:

```bash
python scripts/generate_target.py \
  "pytest tests/ --cov=src" \
  "test-coverage" \
  "Run tests with HTML coverage report" \
  assets/templates/makefile_target.template
```

Outputs:
```makefile
# test-coverage
# When to use: Run tests with HTML coverage report
test-coverage:
	pytest tests/ --cov=src
```

### Step 6: Append to Category File

Append the generated target to the appropriate .mk file:

```bash
echo "\n$(python scripts/generate_target.py ...)" >> .claude/makefiles/testing.mk
```

Ensure `.PHONY` declaration is updated:
```makefile
.PHONY: test test-unit test-coverage

# ... targets ...
```

### Step 7: Update Help Target

Regenerate the root Makefile help:

```bash
python scripts/generate_help.py .
```

This updates the `help` target with all available targets from all .mk files.

## Decision Tree

```
┌─────────────────────────────┐
│  Bash command executed      │
└──────────┬──────────────────┘
           │
           ▼
┌─────────────────────────────┐
│  Is command trivial?        │
│  (ls, cd, pwd, etc.)        │
└──────────┬──────────────────┘
           │
    ┌──────┴──────┐
    │             │
   YES           NO
    │             │
    ▼             ▼
 [Skip]   ┌──────────────────┐
          │ Find similar     │
          │ targets          │
          └─────────┬────────┘
                    │
         ┌──────────┴──────────┐
         │  Similarity score?  │
         └──────────┬──────────┘
                    │
      ┌─────────────┼─────────────┐
      │             │             │
   ≥ 0.95       0.7-0.95       < 0.7
      │             │             │
      ▼             ▼             ▼
 ┌─────────┐  ┌──────────┐  ┌───────────┐
 │ Update  │  │ Create   │  │ Create    │
 │ or      │  │ variant? │  │ new       │
 │ Skip?   │  │          │  │ target?   │
 └────┬────┘  └────┬─────┘  └─────┬─────┘
      │            │              │
      └────────────┼──────────────┘
                   │
                   ▼
          ┌────────────────┐
          │ Ask user via   │
          │ AskUserQuestion│
          └────────┬───────┘
                   │
                   ▼
          ┌────────────────┐
          │ User confirms? │
          └────────┬───────┘
                   │
            ┌──────┴──────┐
            │             │
           YES           NO
            │             │
            ▼             ▼
      ┌──────────┐    [Skip]
      │ Generate │
      │ target   │
      └─────┬────┘
            │
            ▼
      ┌──────────┐
      │ Categorize│
      └─────┬────┘
            │
            ▼
      ┌──────────┐
      │ Append to│
      │ .mk file │
      └─────┬────┘
            │
            ▼
      ┌──────────┐
      │ Update   │
      │ help     │
      └──────────┘
```

## Script Reference

### scripts/analyze_session.py
Analyzes `cchistory` for new interesting commands.
- **Input**: None (reads from cchistory)
- **Output**: JSON array of {line_num, command}
- **State**: Tracks last processed line in `~/.claude/.makefile-last-line`

### scripts/detect_similar.py
Finds existing targets similar to a command.
- **Input**: `<command> <makefiles_dir> [threshold]`
- **Output**: JSON array of similar targets with similarity scores
- **Algorithm**: Fuzzy matching + base command filtering

### scripts/generate_target.py
Generates a Makefile target from a command.
- **Input**: `<command> [target_name] [when_to_use] [template_path]`
- **Output**: Formatted Makefile target
- **Template**: Uses `assets/templates/makefile_target.template`

### scripts/categorize_target.py
Determines the appropriate .mk file for a command.
- **Input**: `<command> [--simple]`
- **Output**: Category filename (testing.mk, docker.mk, etc.)
- **Method**: Keyword matching with confidence scoring

### scripts/generate_help.py
Updates root Makefile with help target.
- **Input**: `<project_dir> [makefiles_dir]`
- **Output**: Updates Makefile with categorized target list
- **Format**: Grouped by category with descriptions

## Advanced Usage

### Custom Threshold

Adjust similarity detection sensitivity:

```bash
# Strict (fewer matches)
python scripts/detect_similar.py "command" .claude/makefiles 0.85

# Relaxed (more matches)
python scripts/detect_similar.py "command" .claude/makefiles 0.6
```

### Manual Target Creation

Generate a target without automation:

```bash
python scripts/generate_target.py \
  "docker build -t myapp:latest ." \
  "docker-build-latest" \
  "Build latest Docker image for production" \
  > .claude/makefiles/docker.mk
```

### Batch Processing

Process multiple commands at once:

```bash
python scripts/analyze_session.py | jq -r '.[].command' | while read cmd; do
  python scripts/detect_similar.py "$cmd" .claude/makefiles
done
```

## References

This skill includes comprehensive reference documentation:

### references/advanced_patterns.md
Advanced Makefile techniques:
- Variables (basic, automatic, conditional)
- Conditionals (ifdef, ifeq)
- Functions (built-in, custom)
- Pattern rules
- Multi-line commands
- Recursive make

### references/composition_guide.md
How to organize `.claude/makefiles/`:
- Directory structure
- Category file conventions
- Root Makefile setup
- Naming conventions
- When to split files
- Variable sharing strategies

### references/best_practices.md
Makefile best practices:
- `.PHONY` declaration
- Nomenclature (target, variable, file naming)
- Portability (POSIX compliance, shell compatibility)
- Tabs vs spaces
- Output and verbosity
- Error handling
- Performance optimization

### references/similarity_detection.md
Detailed algorithm explanation:
- Base command extraction
- Command normalization
- Fuzzy string matching
- Threshold filtering
- Parsing existing targets
- Decision logic
- Performance considerations

## Target Format

All generated targets follow this format:

```makefile
# <target-name>
# When to use: <clear description of when to run this target>
<target-name>:
	<command>
```

Example:

```makefile
# test-coverage
# When to use: Run tests with HTML coverage report for local development
test-coverage:
	pytest tests/ --cov=src --cov-report=html
```

## Category Mappings

Commands are automatically categorized based on keywords:

| Category | Keywords | Example Commands |
|----------|----------|------------------|
| testing.mk | pytest, test, jest, coverage | `pytest tests/` |
| linting.mk | pylint, eslint, black, format | `black .` |
| docker.mk | docker, docker-compose, container | `docker build` |
| build.mk | build, compile, webpack | `npm run build` |
| database.mk | psql, migrate, alembic | `alembic upgrade head` |
| deploy.mk | deploy, release, kubectl | `kubectl apply` |
| dev.mk | serve, dev, watch | `npm run dev` |
| clean.mk | clean, rm -rf, purge | `rm -rf dist/` |
| misc.mk | (uncategorized) | Any unmatched command |

## Common Patterns

### Testing Targets

```makefile
.PHONY: test test-unit test-integration test-coverage

# test
# When to use: Run all tests quickly without coverage
test:
	pytest tests/

# test-unit
# When to use: Run only unit tests for fast feedback
test-unit:
	pytest tests/unit/ -v

# test-integration
# When to use: Run integration tests against local services
test-integration:
	pytest tests/integration/ -v

# test-coverage
# When to use: Generate HTML coverage report for detailed analysis
test-coverage:
	pytest tests/ --cov=src --cov-report=html
```

### Docker Targets

```makefile
.PHONY: docker-build docker-run docker-stop

# docker-build
# When to use: Build Docker image for local development
docker-build:
	docker build -t myapp:dev -f Dockerfile.dev .

# docker-run
# When to use: Run application in Docker container on port 8000
docker-run:
	docker run -p 8000:8000 myapp:dev

# docker-stop
# When to use: Stop all running containers for this project
docker-stop:
	docker-compose down
```

## Troubleshooting

### cchistory not found

Ensure `cchistory` is installed:
```bash
# Install cchistory
npm install -g cchistory
# or follow installation instructions from https://github.com/eckardt/cchistory
```

### State file issues

Reset state tracking:
```bash
rm ~/.claude/.makefile-last-line
```

### Similarity detection too strict/loose

Adjust threshold in detect_similar.py call (default: 0.7).

### Category mismatch

Override automatic categorization by manually specifying the .mk file when appending targets.

## Best Practices

1. **Review generated targets** before committing
2. **Customize "When to use" descriptions** for clarity
3. **Keep misc.mk small** - recategorize targets periodically
4. **Use .PHONY** for all generated targets
5. **Run generate_help.py** after adding targets
6. **Commit .claude/makefiles/** to version control
7. **Add Makefile to .gitignore if auto-generated**
8. **Periodically review and consolidate** similar targets

## Integration with Claude Code

This skill automatically activates when Claude Code executes Bash commands. The typical flow:

1. User asks Claude to run tests: "Run pytest with coverage"
2. Claude executes: `Bash(command="pytest tests/ --cov=src")`
3. Skill detects Bash execution, activates
4. Skill analyzes command, checks for similars
5. Skill uses `AskUserQuestion`: "Add this as 'test-coverage' target?"
6. User confirms
7. Skill generates and appends target to testing.mk
8. Skill updates help target

This creates a self-documenting Makefile that grows naturally as you work.
