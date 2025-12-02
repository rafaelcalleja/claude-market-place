---
name: component-research
description: This skill should be used when the user asks to "evaluate if TBC covers
  a use case", "decide which TBC component to use", "check if a TBC template fits",
  "research TBC capabilities", "find the right TBC template", "analyze if custom step
  is needed", "compare TBC templates", or needs to determine whether To-Be-Continuous
  framework components can solve a CI/CD requirement before generating configuration.
version: 1.0.0
---

# TBC Component Research

Process for determining if a To-Be-Continuous (TBC) component fits a use case or requires customization.

## Purpose

This skill provides a systematic research process to evaluate TBC framework capabilities against user requirements. Use this BEFORE generating any configuration to ensure the correct solution path.

## When to Use

- Before generating `.gitlab-ci.yml` with TBC
- When user requests functionality that may or may not be covered by TBC
- When deciding between TBC template, variant, or custom solution
- When user asks for something and the approach needs validation

## Solution Priority Hierarchy

**ALWAYS follow this priority order. Higher priority = preferred solution.**

| Priority | Solution | When to Use |
|----------|----------|-------------|
| 1 (Highest) | TBC template direct | Template inputs cover use case 100% |
| 2 | Template + existing variant | Template needs authentication/secrets variant |
| 3 | Variant from other template | Another template has variant that fits |
| 4 | New component | Create new TBC template |
| 5 | New component + variant | Create new template with variant |
| 6 (Lowest) | Custom step | **ONLY after exhausting 1-5** |

**Key Principle:** The user may request a solution (e.g., "custom script") but be incorrect. This process disciplines correct framework usage by evaluating ALL options before accepting user's proposed approach.

## Decision Process Overview

```
User Request
    │
    ▼
Identify Core Need (action + target + triggers)
    │
    ▼
╔═══════════════════════════════════════════╗
║  DEEP RESEARCH PHASE (MANDATORY)          ║
║  See references/decision-process.md       ║
╚═══════════════════════════════════════════╝
    │
    ▼
Evaluate Priority 1-6 with evidence
    │
    ▼
Document decision path
```

## Quick Decision Steps

### Step 1: Identify Core Need

Extract the fundamental requirement:
- **Action**: build, deploy, test, scan, package
- **Target**: language, platform, service
- **Triggers**: branch, tag, manual

### Step 2: Search Template Catalog

Read `schemas/_meta.json` from `building-with-tbc` skill for complete template inventory. Check:
- Template names and versions
- Available variants
- Project paths for YML download

### Step 3: Evaluate Template Fit

For each potentially matching template:
1. Read `schemas/{template}.json` for inputs
2. Check if required inputs match use case
3. Check if optional inputs cover customization needs
4. Review available variants in `references/variantes.md`

### Step 4: Deep Research (If Partial Match)

When template partially covers the need, execute **Deep Research Phase**:

1. **Download actual YML** from GitLab using URL pattern:
   ```
   https://gitlab.com/{project}/-/raw/{version}/{file}
   ```

2. **Analyze YML content**: stages, jobs, scripts, tools, extension points

3. **WebSearch tool documentation** for underlying tools

4. **Cross-reference** user need vs template vs tool capabilities

See `references/decision-process.md` for complete Deep Research protocol.

### Step 5: Make Decision

Apply Priority 1-6 hierarchy based on evidence gathered:

| If... | Then... |
|-------|---------|
| Template covers 100% | Priority 1: Use TBC direct |
| Template + variant covers | Priority 2: Use TBC + variant |
| Other template's variant fits | Priority 3: Apply/create variant |
| Can create new component | Priority 4: Create component |
| Component + variant needed | Priority 5: Create both |
| ALL above fail (documented) | Priority 6: Custom step |

## Output Format

Always document the decision path taken:

```
## Decision Path

User Request: "{request}"
    │
    ▼
Core Need: {action} + {target}
    │
    ▼
Templates Checked: {list}
    │
    ▼
Match Analysis: {findings}
    │
    ▼
Decision: Priority {N} - {solution}

Evidence:
- {source-1}: {finding}
- {source-2}: {finding}
```

## Reference Files

| Need | Reference |
|------|-----------|
| Complete decision flowchart | `references/decision-process.md` |
| Deep Research protocol | `references/decision-process.md` (Phase 0) |
| Cross-reference analysis | `references/decision-process.md` (Phase 0.5) |

## Integration with building-with-tbc

After completing component research:
1. Document decision in output format above
2. If TBC component selected → use `building-with-tbc` skill to generate config
3. If custom step required → document WHY TBC doesn't fit before proceeding

## Common Scenarios

### Scenario: Template Exists but Partial Fit

Follow Deep Research to check if:
- Template extension points (before_script, scripts-dir) can enable the feature
- Underlying tool supports the requirement
- Variant pattern from other template can be applied

### Scenario: User Requests Custom Script

**Do NOT accept immediately.** Execute full research process:
1. Identify what user actually needs
2. Check if any TBC template covers it
3. Check variants
4. Only if documented failure → accept custom approach

### Scenario: Multiple Templates Possible

Compare each template's fit:
- Which covers more requirements?
- Which has better extension points?
- Which has relevant variants?
