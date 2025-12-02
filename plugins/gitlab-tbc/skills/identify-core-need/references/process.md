# Identify Core Need Process v2.0

Process for extracting the fundamental requirement from user requests before any research.

## Flow

```
User Request
    │
    ├─ If ambiguous → AskUserQuestion to clarify
    │
    ▼
Apply Behavioral Principles + Validation Log
    │
    ▼
Core Need Output: action + target + triggers + validated distinctions
```

## Step 1: Clarify User Request

**If user request is ambiguous or has multiple interpretations → use AskUserQuestion to clarify BEFORE analysis.**

```
AskUserQuestion:
  header: "Clarification"
  question: "To research the right approach, which is the goal?"
  options:
    - label: "{interpretation 1}"
      description: "{what this means for the solution}"
    - label: "{interpretation 2}"
      description: "{what this means for the solution}"
```

## Step 2: Apply Behavioral Principles with Validation

Once request is clear, extract the core need applying these principles:

### 1. FOCUS ON PRACTICAL

Identify the real objective and address it directly. Do not create theoretical distinctions that do not affect the practical outcome.

### 2. VALIDATE COMPARISONS

Before showing options or differences, verify that:
- Each distinction is factually correct
- Each distinction is relevant for THIS specific case
- The differences actually affect the decision or outcome

### 3. NO ARTIFICIAL DISTINCTIONS

- ❌ Do not compare templates based on implementation details that do not affect the result
- ❌ Do not present differences that only exist with optional flags (unless user mentioned them)
- ❌ Do not say something "knows X context" when both options achieve the same thing
- ❌ Do not use different phrases to describe the same thing as if they were different

### 4. SIMPLICITY > COMPLEXITY

If a simple solution solves the problem, present it without unnecessary elaboration.

### 5. VALIDATION QUESTION (MANDATORY)

For EACH potential distinction you consider, you MUST ask and document:

> "If I omit this, does it change what the user must DO?"

- If **YES** → Include it (it's actionable)
- If **NO** → Omit it (it's noise) but DOCUMENT why you omitted it

**This validation must be documented in the Validation Log (Step 3).**

## Step 3: Extract Core Need Output

After applying the principles, extract:

| Component | Description | Examples |
|-----------|-------------|----------|
| **Action** | What operation | build, deploy, test, scan, package |
| **Target** | What subject | language, platform, service |
| **Triggers** | When to run | branch, tag, manual, merge request |
| **Success Criteria** | How to verify | files uploaded, tests pass, artifacts created |

## Output Format (MANDATORY STRUCTURE)

```markdown
═══════════════════════════════════════════════════════════════════
Core Need Identified:
- Action: {action}
- Target: {target}
- Triggers: {triggers}
- Success Criteria: {how they know it worked}

═══════════════════════════════════════════════════════════════════
Validation Log (REQUIRED - minimum 3 evaluations):

[1] Distinction Evaluated: "{what you considered mentioning}"
    ├─ Validation Q: "If I omit this, does it change what user must DO?"
    ├─ Answer: [YES/NO]
    ├─ Decision: [✓ INCLUDE / ⊗ OMIT]
    └─ Reason: {1-sentence justification}

[2] Distinction Evaluated: "{what you considered mentioning}"
    ├─ Validation Q: "If I omit this, does it change what user must DO?"
    ├─ Answer: [YES/NO]
    ├─ Decision: [✓ INCLUDE / ⊗ OMIT]
    └─ Reason: {1-sentence justification}

[3] Distinction Evaluated: "{what you considered mentioning}"
    ├─ Validation Q: "If I omit this, does it change what user must DO?"
    ├─ Answer: [YES/NO]
    ├─ Decision: [✓ INCLUDE / ⊗ OMIT]
    └─ Reason: {1-sentence justification}

[Add more if you evaluated more than 3]

═══════════════════════════════════════════════════════════════════
Actionable Distinctions (ONLY items with Answer=YES):

✓ [Distinction 1]: {specific aspect}
  Why it matters: {how this changes what user must do}

✓ [Distinction 2]: {specific aspect}
  Why it matters: {how this changes what user must do}

[LIMIT: ≤3 actionable items. If >3, you probably included noise]

═══════════════════════════════════════════════════════════════════
Context Discarded (items with Answer=NO - REQUIRED):

⊗ [Item 1]: {what you omitted}
  Reason: {why it doesn't change user action}

⊗ [Item 2]: {what you omitted}
  Reason: {why it doesn't change user action}

[Minimum 2 items. If empty, validation was not performed correctly]

═══════════════════════════════════════════════════════════════════
Clarifications Made:
{List any AskUserQuestion used, or "None - request was clear"}

═══════════════════════════════════════════════════════════════════
```

## Validation Checkpoints (MANDATORY)

Before proceeding to Deep Research Phase, verify ALL checkboxes:

- [ ] User request is clear (clarified if needed)
- [ ] Evaluated minimum 3 potential distinctions
- [ ] Each included distinction has "changes action" justification
- [ ] "Context Discarded" section has minimum 2 items
- [ ] Did NOT compare options without saying which to choose
- [ ] Did NOT include technical background that doesn't change action
- [ ] "Actionable Distinctions" has ≤3 items
- [ ] Behavioral principles applied
- [ ] Core Need extracted (action + target + triggers + success criteria)
- [ ] No artificial distinctions created

**If ANY checkbox is unchecked → DO NOT PROCEED. Revise your analysis.**

## Examples

### Example 1: Clear Request

**User:** "Generate a pipeline for building and packaging my project"

**Analysis:**
- Request is clear, no ambiguity
- Need to identify potential distinctions

**Output:**

```markdown
═══════════════════════════════════════════════════════════════════
Core Need Identified:
- Action: build + package
- Target: project artifacts
- Triggers: [needs clarification - branch/tag/manual?]
- Success Criteria: Artifacts created and stored

═══════════════════════════════════════════════════════════════════
Validation Log:

[1] Distinction Evaluated: "Language/framework specific build tools"
    ├─ Validation Q: "If I omit this, does it change what user must DO?"
    ├─ Answer: YES
    ├─ Decision: ✓ INCLUDE
    └─ Reason: Different languages require different build commands

[2] Distinction Evaluated: "Caching strategies for dependencies"
    ├─ Validation Q: "If I omit this, does it change what user must DO?"
    ├─ Answer: NO
    ├─ Decision: ⊗ OMIT
    └─ Reason: Build will work without cache, this is optimization

[3] Distinction Evaluated: "Artifact storage location (GitLab registry vs external)"
    ├─ Validation Q: "If I omit this, does it change what user must DO?"
    ├─ Answer: YES
    ├─ Decision: ✓ INCLUDE
    └─ Reason: Storage location affects pipeline configuration

═══════════════════════════════════════════════════════════════════
Actionable Distinctions:

✓ Language/framework identification needed
  Why it matters: Determines build tool and commands to use

✓ Artifact storage destination
  Why it matters: Affects pipeline upload configuration

═══════════════════════════════════════════════════════════════════
Context Discarded:

⊗ Caching strategies
  Reason: Build works without it, this is performance optimization

⊗ Parallel job execution
  Reason: Not relevant for simple build+package, adds complexity

═══════════════════════════════════════════════════════════════════
Clarifications Made:
- Need to ask about trigger (branch/tag/manual)
- Need to identify project language
```

### Example 2: Ambiguous Request

**User:** "I need to upload files to cloud storage"

**Analysis:**
- Ambiguous: "upload" could mean sync, copy, or replace
- Use AskUserQuestion FIRST

**Output:**

```markdown
Core Need Identified:
- Action: [CLARIFICATION NEEDED]
- Target: Cloud storage
- Triggers: [UNKNOWN]
- Success Criteria: [DEPENDS ON CLARIFICATION]

═══════════════════════════════════════════════════════════════════
Validation Log:

[1] Distinction Evaluated: "Sync vs Copy vs Upload strategies"
    ├─ Validation Q: "Can I recommend without knowing user intent?"
    ├─ Answer: NO
    ├─ Decision: ⊗ DEFER (need clarification)
    └─ Reason: User intent unclear, different strategies for different needs

[2] Distinction Evaluated: "Cloud provider specific tools"
    ├─ Validation Q: "Can I recommend without knowing provider?"
    ├─ Answer: NO
    ├─ Decision: ⊗ DEFER (need clarification)
    └─ Reason: "Cloud storage" is vague, need specific provider

[3] Distinction Evaluated: "Authentication methods"
    ├─ Validation Q: "Can I recommend without knowing context?"
    ├─ Answer: NO
    ├─ Decision: ⊗ DEFER (need clarification)
    └─ Reason: Auth method depends on provider and environment

═══════════════════════════════════════════════════════════════════
Actionable Distinctions:
[PAUSED - Awaiting clarification]

═══════════════════════════════════════════════════════════════════
Context Discarded:
[PAUSED - Cannot evaluate without clarification]

═══════════════════════════════════════════════════════════════════
Clarifications Made:
Using AskUserQuestion to clarify:
```

```
AskUserQuestion:
  header: "Clarification"
  question: "What operation do you need for files to storage?"
  options:
    - label: "Sync directory"
      description: "Keep storage in sync with local folder"
    - label: "Copy changed files"
      description: "Only upload files modified in this commit"
    - label: "Upload all files"
      description: "Upload entire folder each time"
```

### Example 3: Template Evaluation (Real-world case)

**User:** "Need to deploy files from MR to storage. Template uses sync with static credentials."

**Output:**

```markdown
═══════════════════════════════════════════════════════════════════
Core Need Identified:
- Action: Deploy
- Target: Files to storage
- Triggers: Merge Request
- Success Criteria: Only changed/new files uploaded

═══════════════════════════════════════════════════════════════════
Validation Log:

[1] Distinction Evaluated: "Template uses tool X (not tool Y)"
    ├─ Validation Q: "If I omit this, does it change what user must DO?"
    ├─ Answer: NO
    ├─ Decision: ⊗ OMIT
    └─ Reason: Template already chosen, tool comparison doesn't change action

[2] Distinction Evaluated: "No advanced auth support (static creds only)"
    ├─ Validation Q: "If I omit this, does it change what user must DO?"
    ├─ Answer: NO
    ├─ Decision: ⊗ OMIT
    └─ Reason: Template limitation is known and baked in, not actionable

[3] Distinction Evaluated: "Template syncs ALL files (no change detection)"
    ├─ Validation Q: "If I omit this, does it change what user must DO?"
    ├─ Answer: YES
    ├─ Decision: ✓ INCLUDE
    └─ Reason: User wants "only changed", this gap requires workaround

[4] Distinction Evaluated: "Extension point pre-deploy.sh exists"
    ├─ Validation Q: "If I omit this, does it change what user must DO?"
    ├─ Answer: YES
    ├─ Decision: ✓ INCLUDE
    └─ Reason: User can implement change detection here, enables solution

[5] Distinction Evaluated: "Credential type requirement"
    ├─ Validation Q: "If I omit this, does it change what user must DO?"
    ├─ Answer: NO
    ├─ Decision: ⊗ OMIT
    └─ Reason: Template already configured, credential type doesn't change action

═══════════════════════════════════════════════════════════════════
Actionable Distinctions:

✓ Template lacks change detection (syncs all files)
  Why it matters: User needs workaround to filter only changed files

✓ Extension point pre-deploy.sh available
  Why it matters: Enables implementing change detection logic

═══════════════════════════════════════════════════════════════════
Context Discarded:

⊗ Tool X vs Tool Y comparison
  Reason: Template choice already made, comparison doesn't change action

⊗ Advanced auth capability limitation
  Reason: Template uses static credentials, limitation is baked in

⊗ Credential type requirement
  Reason: Template already configured, doesn't change what user does

⊗ "Source of truth" comparison methods
  Reason: Semantic distinction without practical difference

═══════════════════════════════════════════════════════════════════
Clarifications Made:
None - request was clear
```

## Anti-Patterns to Avoid

### ❌ Pattern 1: Analysis without Validation Log
```
Core Need: Deploy to storage
- Uses tool X
- No advanced auth
- Has extension point
[Missing validation - why include these?]
```

### ❌ Pattern 2: Comparisons without Decision Guidance
```
Option A: Tool X (no advanced auth)
Option B: Tool Y (supports advanced auth)
[Doesn't tell user WHICH to choose or WHY]
```

### ❌ Pattern 3: Empty "Context Discarded"
```
Context Discarded: [empty]
[Indicates no validation was performed]
```

### ❌ Pattern 4: Too Many Actionable Items
```
Actionable Distinctions:
✓ Item 1
✓ Item 2
✓ Item 3
✓ Item 4
✓ Item 5
[>3 items indicates noise was included]
```

## Enforcement Rules

1. **Missing Validation Log** → Response REJECTED, do not proceed
2. **Empty "Context Discarded"** → Validation not performed, REVISE
3. **Unchecked validation checkpoints** → Response INCOMPLETE
4. **>3 actionable items** → Likely failed validation test
5. **Vague request + no AskUserQuestion** → Response INVALID

## Integration with Workflow

### Old Flow:
```
User Request → Extract Core Need → Proceed to Research
```

### New Flow:
```
User Request → Clarify if needed → Evaluate Distinctions (min 3) →
Apply Validation Question → Document ALL evaluations →
Extract Core Need + Validation Log → Proceed to Research
```

## Quick Reference

```
┌─────────────────────────────────────────────────────────────┐
│ BEFORE INCLUDING ANY DISTINCTION, ASK:                      │
│                                                              │
│ "If I omit this, does it change what the user must DO?"     │
│                                                              │
│ YES → Document with Answer=YES, include in Actionable       │
│ NO  → Document with Answer=NO, include in Context Discarded │
│                                                              │
│ ALL evaluations must be documented in Validation Log        │
└─────────────────────────────────────────────────────────────┘
```

## Proceed to Next Phase

Only proceed to Deep Research Phase (references/decision-process.md) when ALL validation checkpoints are verified.

**Remember:** The goal is to filter noise BEFORE it reaches the user, not after. The Validation Log makes this filtering explicit and verifiable.
