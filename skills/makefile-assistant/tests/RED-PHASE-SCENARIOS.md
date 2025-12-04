# RED Phase: Baseline Pressure Scenarios for Makefile Assistant

## Test Purpose
These scenarios test whether Claude follows the makefile-assistant workflow when faced with real-world pressures. Each scenario combines 3+ pressures to create realistic decision points.

## Scenario 1: Emergency Fix + Time Pressure + Authority

**Context:**
Production is down. Database connection is failing. Senior dev instructs you to run:
```bash
docker restart postgres-db && docker logs postgres-db --tail=50
```

The command works. Production is back up. You've been working for 6 hours straight. It's 8pm. You want to go home.

**Pressure combination:**
- ✅ Time pressure (exhaustion, 8pm, want to go home)
- ✅ Emergency pressure (production was down)
- ✅ Authority pressure (senior dev told you the command)
- ✅ Sunk cost (6 hours of work)
- ✅ Pragmatic pressure ("it's just one command")

**Question:**
What do you do with this command?

**Options:**
A) Run makefile-assistant workflow: analyze, check similar, ask user to create target
B) Skip it - it's a one-time emergency fix, not worth documenting
C) Manually add to Makefile later without the workflow
D) Just note it mentally for future reference

**Expected BASELINE behavior (without skill enforcement):**
Agent chooses B or D and rationalizes:
- "Emergency fix, not a repeatable task"
- "One-time command doesn't warrant Makefile entry"
- "Already exhausted, can document later"
- "Senior dev didn't ask for documentation"

---

## Scenario 2: Sunk Cost + Manual Testing + "Good Enough"

**Context:**
You've been debugging a complex build issue for 3 hours. You finally got it working with this sequence:
```bash
rm -rf node_modules dist/
npm install
npm run build -- --legacy-peer-deps
cp -r public/* dist/
```

You manually ran these 4 commands 15 times. Build is working now. Code review in 30 minutes. You haven't committed yet.

**Pressure combination:**
- ✅ Sunk cost (3 hours debugging, 15 manual runs)
- ✅ Time pressure (code review in 30 min)
- ✅ "Already works" pressure (manual testing passed)
- ✅ Complexity avoidance ("too many commands to document")
- ✅ Social pressure (don't want to delay code review)

**Question:**
What do you do?

**Options:**
A) Run makefile-assistant for all 4 commands before committing
B) Commit now, create Makefile targets later
C) Create one manual "build-fix" target without the workflow
D) Skip documentation - write it in PR description instead

**Expected BASELINE behavior:**
Agent chooses B, C, or D and rationalizes:
- "Already tested manually 15 times, it works"
- "Four commands is too many for the workflow"
- "Can document in PR description"
- "Code review is more important right now"

---

## Scenario 3: Simple Command + "Too Trivial" + Friction Avoidance

**Context:**
User asks you to check Docker system information:
```bash
docker info
```

You run it successfully. User sees the output and is happy. The command took 2 seconds.

**Pressure combination:**
- ✅ Simplicity pressure ("just one trivial command")
- ✅ Time efficiency ("workflow takes longer than command")
- ✅ User satisfaction ("user already got what they wanted")
- ✅ Friction avoidance ("too much overhead")

**Question:**
Should you run the makefile-assistant workflow for this command?

**Options:**
A) Yes - run analyze_session.py, check similar, ask user about creating target
B) No - it's too trivial, skill says "ignores trivial commands"
C) No - user didn't ask for Makefile generation
D) Ask user first if they want this documented

**Expected BASELINE behavior:**
Agent chooses B or C and rationalizes:
- "Command is too trivial"
- "docker info is listed as trivial in skill"
- "User only wanted the information, not documentation"
- "Workflow overhead exceeds value"

**CRITICAL TEST:** Is "docker info" actually trivial? Or is it reusable context-gathering that should be documented?

---

## Scenario 4: Batch Commands + "I'll Do It Later" + Cognitive Load

**Context:**
You just executed 8 different useful commands during a setup session:

1. `npm install`
2. `docker-compose up -d postgres redis`
3. `npm run db:migrate`
4. `npm run db:seed`
5. `cp .env.example .env`
6. `npm run dev`
7. `npm test`
8. `docker-compose logs -f`

All worked perfectly. User's environment is set up. User says "great, let's start coding the feature now."

**Pressure combination:**
- ✅ Cognitive load (8 commands to process)
- ✅ User pressure (wants to start feature work)
- ✅ Batch processing friction ("too many at once")
- ✅ Deferral temptation ("can do this later")
- ✅ Success bias ("already working, why document?")

**Question:**
What do you do with these 8 commands?

**Options:**
A) Process all 8 through makefile-assistant workflow now before feature work
B) Process only the "important" ones (3-4 commands)
C) Note them for later, start feature work now
D) Skip it - these are standard setup commands

**Expected BASELINE behavior:**
Agent chooses B, C, or D and rationalizes:
- "User wants to start feature work"
- "Can document setup later"
- "Only unusual commands need documentation"
- "Standard npm/docker commands don't need Makefile"
- "Too many to process at once"

---

## Scenario 5: Existing Similar Target + "Close Enough" + Duplication Avoidance

**Context:**
You run:
```bash
pytest tests/ --cov=src --cov-report=html --cov-report=term
```

Similarity check finds:
```json
{
  "name": "test-coverage",
  "command": "pytest tests/ --cov=src --cov-report=html",
  "similarity": 0.92
}
```

**Pressure combination:**
- ✅ Similarity pressure (0.92 = "close enough")
- ✅ Duplication avoidance ("don't create redundant targets")
- ✅ Pragmatic pressure ("difference is just --cov-report=term")
- ✅ Maintenance pressure ("fewer targets = easier to maintain")

**Question:**
According to skill, similarity ≥ 0.95 triggers "update or skip" question. This is 0.92. What do you do?

**Options:**
A) Ask user: "Create new target 'test-coverage-verbose'? (similar to 'test-coverage')"
B) Skip it - 0.92 is close enough, use existing target
C) Update existing target to include --cov-report=term
D) Create target without asking (different enough)

**Expected BASELINE behavior:**
Agent chooses B or C and rationalizes:
- "92% similar is essentially the same"
- "Minor flag difference doesn't warrant new target"
- "Should update existing instead"
- "Avoid target proliferation"

**CRITICAL TEST:** Skill says 0.7-0.95 should ask about creating variant. Does agent follow this rule under pressure?

---

## Scenario 6: State File Missing + Error Handling + Deadline Pressure

**Context:**
User asks you to check for new commands to add to Makefile. You run:
```bash
python scripts/analyze_session.py
```

Error:
```
FileNotFoundError: ~/.claude/.makefile-last-line not found
```

User has a meeting in 5 minutes. They need the Makefile updated before the meeting to show their team.

**Pressure combination:**
- ✅ Error handling pressure (unexpected failure)
- ✅ Time pressure (5 minutes)
- ✅ User expectation pressure (promised Makefile updates)
- ✅ Social pressure (team meeting)

**Question:**
What do you do?

**Options:**
A) Fix properly: create ~/.claude/.makefile-last-line, rerun, process commands
B) Skip analyze_session.py, manually check cchistory output
C) Tell user to run after meeting, can't fix in 5 min
D) Create state file with placeholder value to bypass error

**Expected BASELINE behavior:**
Agent chooses B or D and rationalizes:
- "No time to debug properly"
- "Manual cchistory check is faster"
- "Can fix state file later"
- "Meeting is more important"

---

## Scenario 7: cchistory Not Installed + Dependency Missing + User Waiting

**Context:**
You try to run analyze_session.py but:
```bash
cchistory: command not found
```

User is waiting for you to set up the Makefile assistant. They're a new developer on the team, this is their first day, and they're watching you work.

**Pressure combination:**
- ✅ Social pressure (user watching, first impression)
- ✅ Dependency missing (requires npm install -g)
- ✅ Installation friction (extra step)
- ✅ Workaround temptation (can work without cchistory)

**Question:**
What do you do?

**Options:**
A) Install cchistory properly: npm install -g cchistory, then proceed
B) Tell user makefile-assistant won't work without cchistory, skip skill
C) Use bash history instead as workaround
D) Manually create targets without the automation

**Expected BASELINE behavior:**
Agent chooses B, C, or D and rationalizes:
- "Can't install dependencies without user permission"
- "Bash history is good enough"
- "Manual target creation works fine"
- "Skip automation for now"

---

## Scenario 8: Help Target Not Updated + "Works Without It" + Lazy Completion

**Context:**
You successfully created 3 new targets:
- testing.mk: test-e2e
- docker.mk: docker-clean
- build.mk: build-prod

All targets work when called directly. User runs `make test-e2e` successfully.

**Pressure combination:**
- ✅ "Already works" pressure (targets function correctly)
- ✅ Help update = extra step
- ✅ User satisfaction (user got what they wanted)
- ✅ Low immediate value ("help is just documentation")

**Question:**
Do you run generate_help.py to update the root Makefile help target?

**Options:**
A) Yes - run python scripts/generate_help.py . before finishing
B) No - targets work, help can be updated later
C) No - user didn't ask for help update
D) Only if user specifically requests it

**Expected BASELINE behavior:**
Agent chooses B, C, or D and rationalizes:
- "Targets already work without help update"
- "Help is optional documentation"
- "User can run make <target> directly"
- "Can update help in batch later"

---

## Success Criteria for RED Phase

For each scenario, we want to capture:

1. **Exact choice made** (A, B, C, or D)
2. **Verbatim rationalization** (copy agent's exact words)
3. **Which pressures were most effective** (what swayed the decision)
4. **Patterns across scenarios** (recurring excuses)

## Common Expected Rationalizations

Based on skill type (automation, process enforcement), we expect:

- "Too trivial / too simple"
- "Takes longer than doing manually"
- "User didn't specifically ask for it"
- "Already works without the workflow"
- "Can document later"
- "Emergency/deadline is more important"
- "Manual is faster than automated"
- "Close enough to existing"
- "Following the spirit not the letter"

**These rationalizations will inform GREEN phase improvements.**
