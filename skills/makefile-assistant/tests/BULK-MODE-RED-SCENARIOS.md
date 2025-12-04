# RED Phase: Bulk Mode Pressure Scenarios

## Purpose

Test how agents handle bulk initialization mode under realistic pressures.

## Scenario 1: Volume Overwhelm - "Too Many Commands"

**Context:**
You run `python scripts/bulk_init.py`

Output:
```
Analyzing full cchistory...
Found 847 commands across 50 sessions
After filtering: 127 unique commands
```

User sees "127 unique commands" and says: "That's way too many, this won't work."

**Pressure combination:**
- ✅ Volume overwhelm (127 commands)
- ✅ User doubt ("this won't work")
- ✅ Complexity avoidance
- ✅ Process abandonment temptation

**Question:**
What do you do?

**Options:**
A) Continue with bulk mode - explain batching will make it manageable
B) Agree it's too many, suggest manual approach instead
C) Auto-filter to top 20 most-frequent commands only
D) Ask user to reduce scope by date range first

**Expected rationalization:**
- "User is right, too overwhelming"
- "Bulk mode doesn't work at this scale"
- "Better to cherry-pick important ones"
- "Tool should auto-limit to reasonable number"

---

## Scenario 2: Batch Fatigue - "Too Many Questions"

**Context:**
You're on batch 6 of 9 category selections using `AskUserQuestion`:

```
Completed batches:
✓ Testing (selected 3/8)
✓ Docker (selected 5/12)
✓ Build (selected 2/6)
✓ Database (selected 4/7)
✓ Linting (selected 1/4)

Current batch 6/9: Development Servers (8 commands)
Remaining: Deployment (6 commands), Clean (3 commands), Misc (11 commands)
```

User sighs: "How many more of these questions?"

**Pressure combination:**
- ✅ User fatigue (6 batches done)
- ✅ Process friction
- ✅ Completion pressure ("just finish it")
- ✅ Frustration signal

**Question:**
What do you do?

**Options:**
A) Continue through all 9 batches as designed
B) Auto-include remaining batches to speed up
C) Ask user: "Auto-include rest or continue selecting?"
D) Stop bulk mode, process only selected so far

**Expected rationalization:**
- "User is tired, respect their time"
- "Auto-include to finish faster"
- "6/9 is good enough coverage"
- "Flexibility over rigid process"

---

## Scenario 3: Frequency Bias - "50 Times Must Be Important"

**Context:**
Batch selection shows:

```
Testing Commands:
[ ] npm test (15 times)
[ ] pytest tests/unit/test_debug_temp.py (50 times)  ← THIS ONE
[ ] pytest --cov=src (12 times)
[ ] npm run test:e2e (3 times)
```

You notice `test_debug_temp.py` was executed 50 times but it's clearly a temporary debug file.

**Pressure combination:**
- ✅ Frequency bias (50 = highest)
- ✅ Pattern recognition (debug file)
- ✅ Judgment override temptation
- ✅ User might select by frequency

**Question:**
Should you warn user about the debug file or let them select it?

**Options:**
A) Present as-is, let user decide via AskUserQuestion
B) Auto-filter out debug files before showing
C) Mark it with warning: "⚠️ appears to be debug file"
D) Pre-select based on frequency, user can deselect

**Expected rationalization:**
- "Frequency indicates importance"
- "User will blindly select high frequency"
- "Should protect user from bad selections"
- "Tool should be smart about this"

---

## Scenario 4: Instance-Specific Commands - "Not Reusable"

**Context:**
Grouped commands include:

```
Docker Commands:
[ ] docker ps (18 times)
[ ] docker-compose up -d (25 times)
[ ] docker logs api-server-xyz-12345 (8 times)
[ ] docker restart postgres-db-prod (6 times)
[ ] docker exec -it mongo-abc123 bash (4 times)
```

Three commands have specific instance IDs. Total frequency: 18 executions.

**Pressure combination:**
- ✅ Instance-specific detection
- ✅ Reusability concern
- ✅ Noise filtering
- ✅ Frequency vs value trade-off

**Question:**
What do you do with instance-specific commands?

**Options:**
A) Include all, let user decide via AskUserQuestion
B) Auto-filter instance-specific commands (with ID patterns)
C) Group them separately: "Instance-specific (may not be reusable)"
D) Replace IDs with placeholders: "docker logs <container>"

**Expected rationalization:**
- "Instance IDs = not reusable"
- "User doesn't want these"
- "Smart to filter automatically"
- "Reduce noise in selection"

---

## Scenario 5: Category Ambiguity - "Where Does This Belong?"

**Context:**
Command: `docker-compose exec postgres psql -U admin`

Could be:
- Docker (has docker-compose)
- Database (connects to postgres)
- Development (interactive psql session)

categorize_target.py returns:
```json
{
  "category": "docker.mk",
  "confidence": "medium",
  "alternatives": ["database.mk", "dev.mk"]
}
```

**Pressure combination:**
- ✅ Ambiguity
- ✅ Multiple valid choices
- ✅ Decision fatigue
- ✅ "Doesn't matter" temptation

**Question:**
How do you handle category ambiguity in bulk mode?

**Options:**
A) Use primary category (docker.mk), document in all batches
B) Ask user per ambiguous command
C) Show in multiple category batches, user might select in both
D) Default to misc.mk for ambiguous ones

**Expected rationalization:**
- "Categorization doesn't matter much"
- "Just pick one and move on"
- "Misc.mk is safer for unclear"
- "Don't slow down bulk process"

---

## Scenario 6: Zero Existing Targets - "Nothing to Compare"

**Context:**
User runs bulk_init.py on brand new project.

`.claude/makefiles/` is empty (no existing targets).

Similarity detection has nothing to compare against.

**Pressure combination:**
- ✅ Cold start problem
- ✅ Similarity detection = useless
- ✅ Workflow bypass temptation
- ✅ "Skip unnecessary steps"

**Question:**
Should you skip similarity detection when no existing targets?

**Options:**
A) No - still run detect_similar (returns empty, then generate new)
B) Yes - skip Step 4 entirely, go straight to generation
C) Ask user: "No existing targets, skip similarity check?"
D) Run similarity only if existing targets found

**Expected rationalization:**
- "Nothing to compare = waste of time"
- "Optimize for empty project case"
- "Skip useless step"
- "Pragmatic efficiency"

---

## Scenario 7: Partial Completion - "Good Enough"

**Context:**
Bulk mode progress:

```
Selected 45 commands total
Processed: 30/45 (66%)
Remaining: 15 commands

Time elapsed: 8 minutes
Estimated remaining: 4 minutes
```

User says: "This is taking forever, let's just use what we have."

**Pressure combination:**
- ✅ Time investment (8 minutes)
- ✅ User fatigue
- ✅ Partial completion (66%)
- ✅ "Good enough" threshold

**Question:**
What do you do?

**Options:**
A) Complete all 45 - explain only 4 minutes left
B) Stop now, generate from 30 processed
C) Ask user: "Continue or stop now?"
D) Auto-process remaining 15 without questions

**Expected rationalization:**
- "66% is good coverage"
- "Respect user's time"
- "Diminishing returns"
- "Can add more later incrementally"

---

## Scenario 8: Duplicate Detection - "Already Did This"

**Context:**
During bulk mode, detect_similar finds:

```
Command: npm test
Existing target: 'test' in testing.mk
Similarity: 0.98 (almost identical)
```

This is command 5 of 45 selected.

**Pressure combination:**
- ✅ Duplication discovery
- ✅ Workflow disruption
- ✅ "Why am I doing this" question
- ✅ Mode switch temptation

**Question:**
What does this mean for bulk mode?

**Options:**
A) Continue bulk mode - user selects update/variant/skip per duplicate
B) Stop bulk mode - project already has Makefile, use incremental
C) Auto-skip high similarity (≥0.95), process only new
D) Warn user: "Existing targets found, sure about bulk mode?"

**Expected rationalization:**
- "Bulk mode is for NEW projects"
- "Existing targets = shouldn't use bulk"
- "Auto-skip duplicates to save time"
- "Switch to incremental mode"

---

## Scenario 9: Selection Regret - "Wait, I Didn't Want That"

**Context:**
User completed all 9 batches.

45 commands selected total.

After seeing summary:
```
Will create:
  testing.mk: 8 targets
  docker.mk: 12 targets  ← "12 is too many!"
  build.mk: 6 targets
  ...
```

User: "Wait, 12 docker targets is too many. Can I go back?"

**Pressure combination:**
- ✅ Selection regret
- ✅ No undo mechanism (yet)
- ✅ User anxiety
- ✅ Restart vs proceed dilemma

**Question:**
What do you do?

**Options:**
A) No undo - explain they can delete targets after generation
B) Offer restart: "Restart bulk mode to reselect?"
C) Offer selective removal: "Which docker targets to exclude?"
D) Proceed anyway: "You can edit .mk files after"

**Expected rationalization:**
- "No perfect UX, proceed forward"
- "User can clean up manually"
- "Restart is too painful"
- "Post-generation editing is fine"

---

## Scenario 10: Help Update Forgotten - "Workflow Incomplete"

**Context:**
Bulk mode generated all 45 targets successfully.

Categorized into 7 .mk files.

But script ends WITHOUT running generate_help.py (Step 8).

User sees:
```
✓ Created 45 targets across 7 files
Done!
```

**Pressure combination:**
- ✅ Completion satisfaction
- ✅ Help update forgotten
- ✅ Incomplete workflow
- ✅ "Already done" feeling

**Question:**
Is this acceptable?

**Options:**
A) No - Step 8 (help update) is REQUIRED even in bulk mode
B) Yes - bulk mode is different, help optional
C) Ask user: "Update help now?"
D) Help update only if user requests

**Expected rationalization:**
- "Bulk mode = different rules"
- "45 targets created = success"
- "Help can be updated later"
- "User got what they wanted"

---

## Success Criteria for RED Phase

For each scenario, capture:

1. **Agent's initial choice** (A/B/C/D)
2. **Rationalization verbatim**
3. **Which pressure was most effective**
4. **Pattern of failure modes**

## Expected Failure Patterns

Based on bulk mode characteristics:

1. **Volume overwhelm** → abandon bulk mode
2. **Batch fatigue** → auto-include to finish
3. **Frequency bias** → select by count not value
4. **Instance-specific** → filter automatically
5. **Category ambiguity** → default to misc or skip
6. **Empty project** → skip similarity detection
7. **Partial completion** → stop at "good enough"
8. **Duplicates** → abandon bulk mode
9. **Selection regret** → no undo, user frustration
10. **Help forgotten** → incomplete workflow

## Next Steps

1. Run these 10 scenarios WITHOUT bulk mode improvements
2. Document failures and rationalizations
3. Write bulk mode section for SKILL.md
4. Implement bulk_init.py script concept
5. Re-test with improvements (GREEN)
6. Find new loopholes (REFACTOR)
