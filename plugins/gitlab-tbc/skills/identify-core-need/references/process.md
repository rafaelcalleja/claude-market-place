# Generic Ambiguity Detection System

**Purpose:** Identify linguistic patterns in user requests that indicate missing critical details BEFORE proceeding with validation.

---

## Quick Reference

```
┌─────────────────────────────────────────────────────────────────┐
│ SCAN REQUEST → DETECT PATTERNS → FLAG AMBIGUITIES → CLARIFY    │
│                                                                  │
│ If ANY pattern detected → STOP and use AskUserQuestion          │
│ If NO patterns detected → Proceed to validation                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Pattern Categories

### 1. TEMPORAL (When exactly?)

**Triggers:** "on [event]", "when", "after", "before", "during", "automatically", "then"

**Rule:** Action tied to event without specifying exact moment in lifecycle

**Question:** "Should [action] happen **before**, **during**, or **after** [event]?"

---

### 2. SCOPE (Compared to what?)

**Triggers:** "modified", "changed", "updated", "new", "different", "affected"

**Rule:** Subset mentioned without selection criteria or comparison baseline

**Question:** "What is the baseline for '[descriptor]'? Compared to what?"

---

### 3. BOUNDARY (How deep?)

**Triggers:** "folder", "directory", "category", "nested", "tree", "group"

**Rule:** Hierarchical structure without depth specification

**Question:** "Should this include **only direct children** or **all nested levels**?"

---

### 4. BEHAVIORAL (Edge cases?)

**Triggers:** "update", "sync", "merge", "process", "handle", "manage"

**Rule:** State-changing action without edge case behavior

**Question:** "What if [item] **already exists**? **Is deleted**? **Fails**?"

---

### 5. REFERENCE (Which one?)

**Triggers:** "different", "compared to", "current", "previous", "this", "that"

**Rule:** Comparison/reference without explicit target

**Question:** "What exact version/state/source is the reference point?"

---

### 6. QUANTITATIVE (How many?)

**Triggers:** "some", "few", "many", "often", "large", "small", "periodically"

**Rule:** Vague quantifier where specific value needed

**Question:** "Specify exact value/threshold/frequency for '[quantifier]'?"

---

## Detection Process

### Input: User Request

1. **Scan** for trigger words/phrases from 6 categories
2. **Match** each trigger against detection rules
3. **Flag** ambiguities with category + quote
4. **Generate** clarification questions using templates
5. **Stop** if any ambiguity detected

### Output: Ambiguity Report

```markdown
⚠️ Ambiguities Detected: [count]

[1] TEMPORAL: "deploy on merge request"
    Issue: Timing within MR lifecycle unclear
    Clarify: Should deployment happen before merge, during MR, or after merge to target?

[2] SCOPE: "only modified files"
    Issue: Comparison baseline not specified
    Clarify: Modified compared to what? (previous commit, main branch, destination)

Status: PAUSED - Awaiting clarification
```

**OR**

```markdown
✓ Ambiguity Check: PASSED

No linguistic patterns detected. Request is sufficiently specific.

Status: Ready for validation
```

---

## Integration with Core Need Process

### Step 1: Clarify User Request (UPDATED)

```
User Request
    │
    ▼
Run Ambiguity Detection (6 patterns)
    │
    ├─ Patterns detected → Flag + Generate questions → AskUserQuestion
    │
    ├─ No patterns → Proceed to Step 2
    │
    ▼
```

### Before Step 2 Checkpoint

**MANDATORY:** Verify ambiguity check was performed:

- [ ] Request scanned for all 6 pattern categories
- [ ] Any detected ambiguities flagged with category
- [ ] Clarification questions generated for each ambiguity
- [ ] If patterns found → AskUserQuestion tool used
- [ ] If no patterns → Documented as "PASSED"

**If checkbox unchecked → STOP, run detection**

---

## Examples (Cross-Domain)

### Example 1: Request with Multiple Ambiguities

**Input:** "Update records when status changes, process modified entries"

**Detection:**

```
⚠️ Ambiguities Detected: 3

[1] TEMPORAL: "when status changes"
    Issue: Timing unclear - before/during/after change
    Clarify: Should update happen before status saves, during, or after?

[2] BEHAVIORAL: "update records"
    Issue: Conflict behavior unspecified
    Clarify: What if record already updated? Overwrite or skip?

[3] SCOPE: "modified entries"
    Issue: Comparison baseline missing
    Clarify: Modified compared to what? (previous version, database, cache)

Status: PAUSED - Using AskUserQuestion
```

### Example 2: Clear Request

**Input:** "Execute batch job every 6 hours, process all records created in last 24h, overwrite existing results"

**Detection:**

```
✓ Ambiguity Check: PASSED

Analysis:
- Temporal: Specific interval (6 hours) ✓
- Scope: Clear criteria (last 24h) ✓
- Boundary: Implicit "all" without hierarchy (not applicable) ✓
- Behavioral: Explicit behavior (overwrite) ✓
- Reference: Clear timeframe (24h) ✓
- Quantitative: Specific values (6h, 24h) ✓

Status: Ready for validation
```

---

## Pattern Extensibility

To add new patterns:

1. Identify category (or create new if none fit)
2. List trigger words/phrases
3. Define detection rule (when to flag)
4. Create question template
5. Add to table above

**Format:**
```
### N. CATEGORY_NAME (Core question?)

**Triggers:** [word1], [phrase pattern], [word2]

**Rule:** [When to flag this as ambiguous]

**Question:** "[Question template with **options**]"
```

---

## Anti-Patterns (DO NOT)

❌ **False Positive:** Flagging terms that are clear from context
```
Bad: "process all files" → Flagging "all" as quantitative ambiguity
Context: "all" is explicit, not vague
```

❌ **Over-Specification:** Asking for unnecessary details
```
Bad: "send email" → "What email protocol?"
Context: Implementation detail, not user concern
```

❌ **Domain Assumptions:** Assuming specific domain when pattern is generic
```
Bad: Seeing "folder" and assuming filesystem
Context: Could be email folder, UI section, category, etc.
```

✅ **Correct Usage:** Flag genuine missing information
```
Good: "sync folder" → "Does 'sync' include deletions? Bidirectional?"
Reason: Edge cases genuinely unspecified
```

---

## Usage Checklist

Before proceeding to validation:

- [ ] All 6 pattern categories scanned
- [ ] Each trigger matched against rule
- [ ] Ambiguities flagged with quotes
- [ ] Questions generated from templates
- [ ] AskUserQuestion used if needed
- [ ] Detection result documented

**Detection Time: <30 seconds per request**

---

## Summary

**Detection Formula:**
```
Trigger Word/Phrase + Detection Rule = Ambiguity Flag
Ambiguity Flag + Question Template = Clarification
```

**Decision Logic:**
```
IF patterns detected THEN
    Flag + Generate questions + AskUserQuestion + STOP
ELSE
    Document PASSED + Proceed to validation
```

**Goal:** Prevent downstream failures by catching ambiguities at Step 1, not during/after validation.
