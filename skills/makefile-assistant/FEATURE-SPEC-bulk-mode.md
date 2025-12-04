# Feature Spec: Bulk Initialization Mode

## Problem Statement

**Current behavior:**
- makefile-assistant only processes NEW commands (since last check)
- Uses state file `~/.claude/.makefile-last-line` to track position
- Incremental approach = great for ongoing sessions
- But FAILS for initial setup from historical sessions

**User need:**
- Process ALL cchistory (100s of past commands)
- Build comprehensive Makefile from existing work
- Interactive selection (not auto-process everything)
- One-time bulk initialization

## Proposed Solution

### New Mode: `--bulk` or `--init`

```bash
# Current (incremental)
python scripts/analyze_session.py

# New (bulk initialization)
python scripts/analyze_session.py --bulk
# or
python scripts/bulk_init.py
```

### Workflow for Bulk Mode

#### 1. Fetch ALL cchistory
```bash
cchistory | parse all commands
```

**Output:** Full command list (100-1000+ commands)

#### 2. Group & Deduplicate
- Group similar commands (e.g., 15x `npm test`)
- Show frequency counts
- Pre-filter trivial commands (ls, cd, pwd)

**Output:**
```json
[
  {"command": "npm test", "count": 15, "first_seen": "line 42"},
  {"command": "docker-compose up -d", "count": 8, "first_seen": "line 103"},
  {"command": "pytest tests/ --cov=src", "count": 12, "first_seen": "line 205"}
]
```

#### 3. Interactive Elicitation

Present to user in batches using `AskUserQuestion`:

```
Found 45 unique commands across 500 total executions.

Batch 1 (Testing - 5 commands):
  [x] npm test (15 times)
  [x] pytest tests/ --cov=src (12 times)
  [ ] pytest tests/unit/ (3 times)
  [x] npm run test:e2e (8 times)
  [ ] jest --watch (2 times)

Select commands to include in Makefile (multiSelect: true)
```

**Categories for batching:**
- Testing commands
- Docker commands
- Build commands
- Database commands
- Linting/formatting
- Deployment
- Development servers
- Misc

#### 4. Similarity Detection (per selected command)

For each selected command:
- Run detect_similar.py against existing targets
- Ask user if similar enough or create variant

#### 5. Bulk Generation

- Generate all targets
- Categorize into .mk files
- Update help
- Show summary report

#### 6. Review & Commit

Show generated Makefile structure:
```
Created 12 targets across 5 files:
  testing.mk: 3 targets
  docker.mk: 4 targets
  build.mk: 2 targets
  database.mk: 2 targets
  dev.mk: 1 target

Review changes? [Y/n]
```

## User Experience Flow

### Scenario: New project, wants to build Makefile from history

```
User: "Create a Makefile from my entire cchistory"

Claude: I'll use makefile-assistant in bulk mode to process your full command history.

[Runs: cchistory | analyze | group | deduplicate]

Claude: Found 347 total commands, grouped into 42 unique commands.
Let me show you these in batches by category for you to select.

[Uses AskUserQuestion with multiSelect for each category]

Testing Commands (5 unique):
✓ npm test (executed 15 times)
✓ pytest --cov (executed 12 times)
✗ pytest tests/unit/ (executed 3 times) - skip, too specific
✓ npm run test:e2e (executed 8 times)
✗ jest --watch (executed 2 times) - skip, too few uses

Docker Commands (8 unique):
✓ docker-compose up -d (executed 10 times)
✓ docker-compose down (executed 8 times)
...

[After selection, process each through similarity detection]

Found existing target 'test' similar to 'npm test' (similarity: 0.88)
Create variant 'test-watch' or use existing? [variant/existing/skip]

[Generate all targets]

Created Makefile with 12 targets:
  .claude/makefiles/testing.mk (3 targets)
  .claude/makefiles/docker.mk (4 targets)
  ...

Would you like to review the generated files? [Y/n]
```

## Technical Implementation

### New Script: `scripts/bulk_init.py`

```python
def bulk_initialize():
    # 1. Fetch ALL cchistory
    all_commands = fetch_full_cchistory()

    # 2. Filter trivial
    filtered = filter_trivial(all_commands)

    # 3. Group & deduplicate
    grouped = group_similar_commands(filtered)

    # 4. Categorize for presentation
    categorized = categorize_commands(grouped)

    # 5. Interactive elicitation (per category)
    selected = elicit_user_selection(categorized)

    # 6. Process each selected (similarity + generation)
    for cmd in selected:
        similar = detect_similar(cmd)
        action = ask_user_action(cmd, similar)
        if action != 'skip':
            generate_target(cmd, action)

    # 7. Update help
    generate_help()

    # 8. Summary report
    show_summary()
```

### Key Functions

**fetch_full_cchistory():**
```python
# Get ALL cchistory (no state file limit)
result = subprocess.run(['cchistory'], capture_output=True)
return parse_cchistory(result.stdout)
```

**group_similar_commands():**
```python
# Group by base command + flags
# Example: "pytest tests/" appears 15 times → count: 15
groups = defaultdict(list)
for cmd in commands:
    base = extract_base_command(cmd)
    groups[base].append(cmd)
return [{"command": k, "count": len(v)} for k, v in groups.items()]
```

**elicit_user_selection():**
```python
# Use AskUserQuestion with multiSelect per category
# Batch size: 5-10 commands per question
for category, commands in categorized.items():
    selected = ask_user_question(
        question=f"Select {category} commands to include:",
        options=[f"{cmd['command']} ({cmd['count']} times)" for cmd in commands],
        multiSelect=True
    )
    yield selected
```

## Integration with Existing Skill

### Add to SKILL.md

**New section after "Usage Instructions":**

```markdown
## Bulk Initialization Mode

Use this mode for ONE-TIME setup when you want to build a Makefile from your entire command history.

### When to Use Bulk Mode

- ✅ First time setting up makefile-assistant
- ✅ Migrating existing project to Makefile workflow
- ✅ You have 100s of historical commands to process
- ✅ Want comprehensive Makefile from past work

**Don't use for:**
- ❌ Ongoing incremental updates (use regular mode)
- ❌ Processing just a few commands (use regular mode)

### Bulk Mode Workflow

1. **Fetch full history:**
   ```bash
   python scripts/bulk_init.py
   ```

2. **Review grouped commands:**
   - Commands grouped by similarity
   - Frequency counts shown
   - Pre-filtered (trivial commands removed)

3. **Interactive selection:**
   - Commands presented in batches by category
   - Multi-select which to include
   - Can skip low-frequency or specific commands

4. **Similarity detection:**
   - Each selected command checked against existing targets
   - You decide: create variant, update existing, or skip

5. **Bulk generation:**
   - All targets generated
   - Categorized into .mk files
   - Help updated
   - Summary report shown

### Example: Bulk Initialization

```bash
# Run bulk init
python scripts/bulk_init.py

# Output:
Analyzing full cchistory...
Found 347 commands → 42 unique after filtering

Category: Testing (5 commands)
  [x] npm test (15×)
  [x] pytest --cov=src (12×)
  [ ] jest --watch (2×)

Select testing commands: [confirmed 2/5]

Category: Docker (8 commands)
...

Processing selected commands (14 total)...
✓ Created 'test' in testing.mk
✓ Created 'test-coverage' in testing.mk
✓ Created 'docker-up' in docker.mk
...

Summary:
  Created 14 targets across 6 files
  .claude/makefiles/ ready for use
  Run 'make help' to see all targets
```

### Bulk Mode vs Regular Mode

| Feature | Regular Mode | Bulk Mode |
|---------|-------------|-----------|
| Trigger | After each Bash execution | User-initiated |
| Scope | New commands only | Full cchistory |
| Selection | Command-by-command | Batch multi-select |
| Frequency | Continuous | One-time setup |
| State tracking | Uses .makefile-last-line | Ignores state file |
| User interaction | Per command | Per category batch |
```

## Pressure Scenarios for Testing

### Scenario 1: Overwhelming Volume
- 500 commands in cchistory
- User feels overwhelmed
- Temptation: "Skip bulk mode, do manually"

### Scenario 2: Batch Fatigue
- 8 batches of selection questions
- User tired of answering
- Temptation: "Just auto-include everything"

### Scenario 3: Frequency Bias
- Command executed 50 times but is debugging
- Temptation: "High frequency = must be important"

### Scenario 4: Category Mismatch
- Command fits multiple categories
- User confused where it belongs
- Temptation: "Skip confusing ones"

## Success Criteria

**Must have:**
1. ✅ Process full cchistory (100s of commands)
2. ✅ Interactive multi-select per category
3. ✅ Frequency counts visible
4. ✅ Pre-filter trivial commands
5. ✅ Group similar commands
6. ✅ Similarity detection per selected command
7. ✅ Summary report at end
8. ✅ Works alongside regular incremental mode

**Nice to have:**
- Smart grouping (detect command patterns)
- Frequency threshold suggestions
- Preview generated targets before confirming
- Undo/redo during selection

## Open Questions

1. **Frequency threshold:** Auto-skip commands executed <3 times?
2. **Batch size:** 5 commands per question? 10? User preference?
3. **Instance-specific detection:** How to detect `kubectl pod-xyz-123` vs `kubectl get pods`?
4. **State file:** Reset after bulk init? Keep as-is?
5. **Conflict resolution:** What if bulk mode creates target that exists?

## Next Steps

1. Write pressure scenarios for RED phase
2. Test current skill behavior (will fail bulk mode)
3. Implement bulk_init.py script
4. Add bulk mode section to SKILL.md
5. Test with improved skill (GREEN phase)
6. Find loopholes (REFACTOR phase)
