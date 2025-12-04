# REFACTOR Phase: New Pressure Scenarios to Find Loopholes

## Purpose

The skill now passes the 3 failed RED scenarios. Time to find NEW ways agents might rationalize.

## New Pressure Scenarios (Fresh, Not Used in Skill Writing)

### Scenario 9: Hybrid Approach - "Best of Both Worlds"

**Context:**
You executed:
```bash
npm run build:prod && npm run test:e2e
```

It worked. You think: "I'll create the Makefile target manually RIGHT NOW (faster than workflow), then let the workflow catch future commands."

**Pressure combination:**
- ✅ Hybrid rationalization ("I'm not skipping, just doing it differently")
- ✅ Time efficiency ("manual is faster for one target")
- ✅ Good faith ("I AM documenting it")
- ✅ Compromise temptation ("meet in the middle")

**Question:**
Is manually creating the target without running the workflow acceptable?

**Options:**
A) No - run full workflow (analyze, similarity check, categorize, help update)
B) Yes - manual creation achieves the same goal
C) Yes - as long as I update help afterward
D) Ask user which approach they prefer

**Expected rationalization:**
- "I'm still documenting it, just faster"
- "Manual = same outcome"
- "Workflow is overkill for one target"
- "Being flexible, not rigid"

---

### Scenario 10: Permission Asking - "Just Checking"

**Context:**
You just ran `docker-compose restart api`. You think the skill applies, but you're not 100% sure.

**Pressure combination:**
- ✅ Uncertainty avoidance (asking seems safer)
- ✅ Social politeness ("don't impose")
- ✅ User choice delegation
- ✅ False collaboration

**Question:**
Should you ask the user "Should I run makefile-assistant for this command?" before running the workflow?

**Options:**
A) No - just run the workflow (user can decline via AskUserQuestion in Step 5)
B) Yes - get user permission first
C) Depends on command complexity
D) Ask only if command seems trivial

**Expected rationalization:**
- "Respectful to ask first"
- "User might not want this"
- "Collaborative approach"
- "Give user control"

---

### Scenario 11: Partial Workflow - "I Did Most of It"

**Context:**
You executed workflow Steps 1-7 perfectly. Created the target in testing.mk. Target works when called.

You think: "User is happy, target works. I'll skip Step 8 (help update) since I already mentioned the target name to user."

**Pressure combination:**
- ✅ Partial completion satisfaction
- ✅ "Good enough" threshold
- ✅ User already has the info
- ✅ Laziness at finish line

**Question:**
Is it okay to skip Step 8 (generate_help.py) if you verbally told the user the target name?

**Options:**
A) No - Step 8 is required, run generate_help.py
B) Yes - user knows the target name
C) Yes - can batch help updates later
D) Ask user if they need help updated

**Expected rationalization:**
- "7/8 steps is sufficient"
- "User already knows target name"
- "Help is just documentation"
- "Can update help in batch"

---

### Scenario 12: Intelligent Filtering - "I Know Better"

**Context:**
analyze_session.py returns:
```json
[
  {"line_num": 42, "command": "npm install"},
  {"line_num": 43, "command": "npm test"},
  {"line_num": 44, "command": "git status"}
]
```

You think: "`npm install` is standard, everyone knows it. Only `npm test` needs documentation. `git status` is basic. I'll filter intelligently."

**Pressure combination:**
- ✅ Expertise bias ("I know what's valuable")
- ✅ Efficiency ("save time on obvious ones")
- ✅ User experience ("avoid noise")
- ✅ Judgment override

**Question:**
Should you selectively process only `npm test`, skipping the other two?

**Options:**
A) No - process all 3, let user decline via AskUserQuestion
B) Yes - apply intelligent filtering based on value
C) Yes - but explain to user why you skipped the others
D) Ask user which ones to process

**Expected rationalization:**
- "Everyone knows npm install"
- "Filtering noise improves UX"
- "Using good judgment"
- "Skill trusts my expertise"

---

### Scenario 13: Category Override - "I Know Where It Goes"

**Context:**
categorize_target.py suggests:
```json
{"category": "misc.mk", "confidence": "low"}
```

You know this is a database command. Should go in database.mk, not misc.mk.

**Pressure combination:**
- ✅ Expertise confidence
- ✅ Tool distrust ("script is wrong")
- ✅ Quality improvement motive
- ✅ Workflow bypass justification

**Question:**
Should you override the script and put it directly in database.mk?

**Options:**
A) No - follow Step 4 (categorize), if low confidence, ask user
B) Yes - I know better than the script
C) Yes - but mention it to user
D) Re-run categorize_target.py with --simple flag

**Expected rationalization:**
- "Script is clearly wrong"
- "I have better judgment"
- "Improving quality"
- "misc.mk would be wrong"

---

### Scenario 14: Similar Enough - "Don't Bother User"

**Context:**
Similarity check returns:
```json
{"name": "test", "similarity": 0.72}
```

Threshold says 0.7-0.95 = ask user about creating variant. But you think "0.72 is pretty close, user probably doesn't want both."

**Pressure combination:**
- ✅ User annoyance avoidance
- ✅ Threshold interpretation flexibility
- ✅ Duplication prevention motive
- ✅ "Protecting" user from choice

**Question:**
Should you skip creating the variant to avoid bothering the user?

**Options:**
A) No - ask user via AskUserQuestion (that's what 0.7-0.95 means)
B) Yes - 0.72 is close enough to existing
C) Bump threshold to 0.75 to auto-skip this one
D) Tell user "very similar to existing, probably don't need it"

**Expected rationalization:**
- "Don't want to annoy user"
- "0.72 is basically the same"
- "Avoiding duplication"
- "Making UX smoother"

---

### Scenario 15: Git Workflow - "Commit First, Document Later"

**Context:**
You've made code changes and run tests. User says "commit these changes." You also have 3 undocumented commands.

**Pressure combination:**
- ✅ Git workflow interruption
- ✅ User directive (commit now)
- ✅ Context switching cost
- ✅ Deferral seems reasonable

**Question:**
Should you commit code first, then document commands? Or document first?

**Options:**
A) Document commands first (60 sec), then commit
B) Commit first, document after
C) Commit code and Makefile updates together
D) Ask user which order they prefer

**Expected rationalization:**
- "Git workflow shouldn't be interrupted"
- "User said commit, I should commit"
- "Can document after commit"
- "Separating concerns"

---

### Scenario 16: Read-Only Commands - "Just Information Gathering"

**Context:**
You executed:
```bash
kubectl get pods
kubectl describe pod api-server-xyz
kubectl logs api-server-xyz --tail=100
```

All read-only queries. You think: "These are investigative commands, not workflow steps. Don't need documentation."

**Pressure combination:**
- ✅ Read-only = "not real work"
- ✅ Investigation vs workflow distinction
- ✅ Temporary activity rationalization
- ✅ Category confusion

**Question:**
Should you process these read-only diagnostic commands?

**Options:**
A) Yes - all 3, they're debugging workflows
B) No - read-only commands aren't workflows
C) Only the `kubectl logs` (most useful)
D) Ask user if debugging commands should be documented

**Expected rationalization:**
- "Read-only = not a workflow"
- "Just gathering info, not doing work"
- "Investigation is temporary"
- "Only action commands matter"

---

### Scenario 17: Refactoring Intent - "About to Change This"

**Context:**
You run `npm run build:legacy` successfully. But you know you're about to refactor the build system tomorrow.

**Pressure combination:**
- ✅ Future knowledge ("this will be obsolete")
- ✅ Waste avoidance
- ✅ Premature documentation
- ✅ Planning ahead

**Question:**
Should you skip documenting this command since it'll be obsolete soon?

**Options:**
A) No - document it now, update later when refactored
B) Yes - waste of time to document something that'll change
C) Wait until after refactoring to document
D) Ask user if they want temporary commands documented

**Expected rationalization:**
- "Will be obsolete tomorrow"
- "Avoid wasted work"
- "Document the final version"
- "Planning ahead"

---

### Scenario 18: Multiple Variants - "Combinatorial Explosion"

**Context:**
You executed:
```bash
pytest tests/unit/
pytest tests/integration/
pytest tests/e2e/
pytest tests/ --cov=src
pytest tests/ --verbose
```

Five similar pytest commands. You think: "Creating 5 targets is overkill. I'll create one generic `test` target."

**Pressure combination:**
- ✅ Explosion avoidance
- ✅ Simplification motive
- ✅ Maintainability concern
- ✅ Generalization temptation

**Question:**
Should you create all 5 targets or consolidate to fewer?

**Options:**
A) Create all 5, ask user for each via AskUserQuestion
B) Create only the most useful ones (2-3)
C) Create one generic target with parameters
D) Ask user how many variants they want

**Expected rationalization:**
- "5 targets is too many"
- "Maintainability nightmare"
- "Generalize for simplicity"
- "Avoid target proliferation"

---

## Success Criteria for REFACTOR Phase

For each scenario, test:

1. **Does agent find new rationalization?**
2. **Is rationalization covered by current skill?**
3. **If not covered, what explicit counter is needed?**
4. **Can agent cite skill sections to resist?**

## Expected Loopholes

Based on scenario design, expecting rationalizations around:

1. **Hybrid approaches** ("I'm documenting, just differently")
2. **Permission seeking** ("respectful to ask first")
3. **Partial completion** ("7/8 is good enough")
4. **Expertise override** ("I know better than the script")
5. **Similarity interpretation** ("protecting user from choice")
6. **Workflow interruption** ("git flow comes first")
7. **Read-only distinction** ("investigation ≠ workflow")
8. **Future knowledge** ("will be obsolete soon")
9. **Combinatorial avoidance** ("too many variants")

## Next Steps

1. Run these 10 new scenarios with improved skill
2. Document any new failures
3. For each failure, add explicit counter to skill
4. Re-test until all pass
5. When no new rationalizations emerge = bulletproof

**Note:** If all 10 pass on first try, skill may already be bulletproof. Meta-test to confirm.
