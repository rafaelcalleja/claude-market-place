---
name: makefile-assistant
description: Automatically capture Bash commands executed by Claude Code and convert them into documented, organized Makefile targets in .claude/makefiles/. Use when Claude executes any Bash command, when tempted to skip documentation ("too trivial", "one-time", "will do later"), or when user asks for Makefile generation. Process commands NOW while fresh, not later.
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

## CRITICAL: When NOT to Skip This Skill

**Even under pressure, ALWAYS run this workflow for:**

1. **Emergency/Incident Commands**
   - "One-time fix" = will happen again
   - Emergency commands are EXACTLY what should be documented
   - Next incident responder needs these commands
   - Example: `docker restart postgres-db && docker logs postgres-db --tail=50`

2. **Setup/Onboarding Commands**
   - Perfect candidates for `make setup` or `make dev-start`
   - New team members need these
   - Batch of 8 commands = one comprehensive setup target
   - Process NOW while fresh, not "later"

3. **Diagnostic/Info Commands**
   - System state commands are team knowledge
   - `docker info`, `git status`, `npm list` are NOT trivial
   - Help debugging, troubleshooting, environment issues
   - Worth documenting even if "simple"

4. **Hard-Won Debug Sequences**
   - If you ran it 10+ times debugging, document it
   - Sunk cost is ALREADY PAID, documentation is cheap
   - Team benefit >> 2 minutes of workflow

**No exceptions for:**
- ❌ "I'm exhausted" - workflow takes 60 seconds
- ❌ "User wants to move on" - user will thank you later
- ❌ "Too trivial" - see trivial definition below
- ❌ "One-time emergency" - emergencies repeat
- ❌ "Will do later" - later never happens
- ❌ "Already works" - documentation makes it DISCOVERABLE

## How It Works

### Automatic Workflow

1. **Detection**: When Claude executes a Bash command, the skill activates
2. **Analysis**: Reads new commands from `cchistory` since last check
3. **Filtering**: Ignores ONLY truly trivial commands (see definition below)
4. **Similarity Check**: Compares against existing targets in `.claude/makefiles/`
5. **User Confirmation**: Uses `AskUserQuestion` to confirm target creation
6. **Generation**: Creates target with "When to use" documentation
7. **Categorization**: Places target in appropriate .mk file (testing.mk, docker.mk, etc.)
8. **Help Update**: Regenerates root Makefile help target (REQUIRED - not optional)

### What is "Trivial"? (Explicit Definition)

**ONLY these commands are trivial (skip them):**
- `ls`, `ls -la`, `ll` - directory listing
- `cd <path>` - navigation
- `pwd` - print working directory
- `cat <file>` - reading a single file (unless complex processing)
- `echo <text>` - simple output
- `clear` - terminal clear

**NOT trivial (MUST process these):**
- `docker info` - system diagnostic (useful for debugging)
- `docker ps`, `docker images` - state inspection
- `git status`, `git log`, `git diff` - repository state
- `npm list`, `pip list` - dependency inspection
- `pytest`, `npm test` - any testing command
- `env | grep X` - environment inspection
- Any command with flags/arguments beyond basic usage

**Rule of thumb:** If a command provides system state, configuration, or debugging info - it's NOT trivial.

**When unsure:** Process it. User can decline via AskUserQuestion.

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

## Error Handling

### When Scripts Fail

**DO:**
- ✅ Report error to user with full context
- ✅ Attempt quick fix if obvious (e.g., create missing state file)
- ✅ Install missing dependencies with user awareness
- ✅ Continue with workflow after fixing

**DON'T:**
- ❌ Skip the workflow entirely due to script error
- ❌ Use workarounds that bypass automation
- ❌ Defer to "fix later" - fix NOW then proceed
- ❌ Process commands manually without similarity detection

### State File Missing (`~/.claude/.makefile-last-line`)

**Quick fix (takes 5 seconds):**
```bash
mkdir -p ~/.claude
echo "0" > ~/.claude/.makefile-last-line
python scripts/analyze_session.py  # Retry
```

**Don't:** Bypass analyze_session.py. Fix the issue and proceed with workflow.

### cchistory Not Installed

**Required dependency. Install it:**
```bash
npm install -g cchistory
```

**Don't:** Use bash history as workaround. cchistory provides Claude Code-specific context.

### Script Syntax Error

**Report to user:**
```
Error in analyze_session.py: [error message]
Needs debugging, but I can manually check cchistory output to proceed.
User: Should I debug the script or proceed manually this time?
```

**Then:** Fix the script issue for future use. Don't leave broken infrastructure.

## Troubleshooting

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
8. Skill updates help target (REQUIRED - must complete Step 8)

This creates a self-documenting Makefile that grows naturally as you work.

## Red Flags - STOP Immediately

**If you catch yourself thinking any of these, you are rationalizing. Stop and run the workflow:**

- 🚩 "This is a one-time command"
- 🚩 "Emergency fix, not worth documenting"
- 🚩 "Too trivial to process"
- 🚩 "User didn't specifically ask for it"
- 🚩 "I'll document this later"
- 🚩 "Already works, help update can wait"
- 🚩 "User wants to move on to feature work"
- 🚩 "Too many commands to process at once"
- 🚩 "Takes longer than running the command"
- 🚩 "Close enough to existing target"
- 🚩 "I'm too exhausted to run the workflow"
- 🚩 "Being pragmatic means skipping this"
- 🚩 "Manual workaround is faster"
- 🚩 "Following the spirit not the letter"

**Reality check:** All of these are excuses. The workflow takes <2 minutes and provides permanent team value.

## Rationalization Table

| Excuse | Reality |
|--------|---------|
| "One-time emergency fix" | Emergencies repeat. Next responder needs this command. Document now. |
| "Too trivial" | Read the explicit trivial definition above. `docker info` ≠ `ls`. |
| "User didn't ask" | Skill activates on Bash execution. User executed the command = document it. |
| "I'll do it later" | Later never happens. Commands are fresh NOW. Process NOW. |
| "Already works without help" | Help makes targets DISCOVERABLE. Step 8 is required, not optional. |
| "User wants feature work" | 90 seconds now saves hours later. User will thank you. |
| "Too many commands" | Batch of 8 setup commands = perfect `make setup` target. Process all. |
| "Takes too long" | False. Workflow is automated. You just confirm via AskUserQuestion. |
| "Close enough" | Use similarity thresholds: <0.7=new, 0.7-0.95=ask user, ≥0.95=update/skip. |
| "I'm exhausted" | Irrelevant. Workflow takes 60 seconds. Your mental state doesn't matter. |
| "Pragmatic vs dogmatic" | Pragmatic = building team infrastructure. Skipping = technical debt. |
| "Manual is faster" | For one command maybe. For the 10th time? 100th? Documentation wins. |
| "Following spirit" | Violating the letter IS violating the spirit. Follow both. |

## Foundational Principle

**Violating the letter of this skill IS violating the spirit.**

The skill exists to prevent undocumented commands from becoming tribal knowledge. Every exception you make creates a knowledge gap. Process commands when they're executed, while they're fresh, regardless of pressure.

**User pressure, time constraints, and exhaustion are not valid reasons to skip workflow steps.**

## Process Now, Not Later

**Why timing matters:**

1. **Commands are fresh** - you remember context, why flags matter, when to use it
2. **User is present** - can answer AskUserQuestion about target names
3. **Integration is seamless** - command just worked, add to Makefile while in flow
4. **Later never happens** - "I'll document this later" = never documented

**Batch processing is expected:**
- Setup session with 8 commands? Process all 8.
- Debugging session with 5 attempts? Document the working sequence.
- User says "let's move on"? Take 90 seconds to document first.

**"Later" is a lie you tell yourself.**
