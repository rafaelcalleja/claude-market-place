# Component Decision Process

Process for determining if a TBC component fits the use case or requires customization.

## Solution Priority Hierarchy

**ALWAYS follow this priority order. Higher priority = preferred solution.**

| Priority | Solution | When to Use | Required Reading |
|----------|----------|-------------|------------------|
| 1 (Highest) | TBC template direct | Template inputs cover use case 100% | `schemas/{template}.json` |
| 2 | Template + existing variant | Template needs authentication/secrets variant | `references/variantes.md` |
| 3 | Variant from other template | Another template has variant that fits | `references/variantes.md` (ALL variants) |
| 4 | New component | Create new TBC template | TBC contribution guidelines |
| 5 | New component + variant | Create new template with variant | TBC contribution guidelines |
| 6 (Lowest) | Custom step | **ONLY after exhausting 1-5** | Document why ALL options fail |

**Key Principle:** The user may request a solution (e.g., "custom script") but be incorrect. This process disciplines correct framework usage by evaluating ALL options before accepting user's proposed approach.

**Custom step is almost NEVER the answer.** Before reaching option 6:
- Read `references/variantes.md` completely
- Check if ANY existing variant pattern can be applied
- Evaluate if a new variant can be created
- Evaluate if a new component can be created
- Only if ALL fail (with documented evidence) → Custom step

## Decision Flowchart

```
                    ┌─────────────────┐
                    │  User Request   │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ Identify Core   │
                    │     Need        │
                    └────────┬────────┘
                             │
    ╔════════════════════════▼════════════════════════╗
    ║     STEP 0: DEEP RESEARCH PHASE (MANDATORY)     ║
    ╠═════════════════════════════════════════════════╣
    ║ Phase 0.1: Read schemas/_meta.json              ║
    ║   → Inventory ALL templates and VARIANTS        ║
    ║   → Extract project paths and file locations    ║
    ║   → Always use latest version (don't ask)       ║
    ╠═════════════════════════════════════════════════╣
    ║ Phase 0.2: Download & Analyze Template YMLs     ║
    ║   → Build URL: gitlab.com/{project}/-/raw/      ║
    ║     {version}/{file}                            ║
    ║   → WebFetch actual .yml files                  ║
    ║   → Extract: stages, jobs, scripts, tools       ║
    ║   → Identify underlying tools                   ║
    ╠═════════════════════════════════════════════════╣
    ║ Phase 0.3: Read references/variantes.md         ║
    ║   → ALL variants across ALL templates           ║
    ║   → Identify variant patterns                    ║
    ║   → Check which variants could apply            ║
    ╠═════════════════════════════════════════════════╣
    ║ Phase 0.4: WebSearch tool documentation         ║
    ║   → Official docs for EACH tool from 0.2        ║
    ║   → ALL capabilities, flags, options            ║
    ╠═════════════════════════════════════════════════╣
    ║ Phase 0.5: Cross-Reference Analysis             ║
    ║   → User need vs template capabilities          ║
    ║   → User need vs variant capabilities           ║
    ║   → User need vs tool capabilities              ║
    ╚════════════════════════════════════════════════╝
                             │
                    ┌────────▼────────┐
                    │ Priority 1:     │
                    │ Template 100%?  │
                    └───┬─────────┬───┘
                   Yes │         │ No
                       │         │
    ┌──────────────────▼──┐      │
    │ USE TBC DIRECT      │      │
    └─────────────────────┘      │
                                 │
                    ┌────────────▼────────────┐
                    │ Priority 2:             │
                    │ Template + existing     │
                    │ variant covers?         │
                    │ (Read variantes.md)     │
                    └───┬─────────────────┬───┘
                   Yes │                  │ No
                       │                  │
    ┌──────────────────▼──┐               │
    │ USE TBC + VARIANT   │               │
    └─────────────────────┘               │
                                          │
                    ┌─────────────────────▼───────────────────┐
                    │ Priority 3:                             │
                    │ Variant from OTHER template fits?       │
                    │ (Read ALL variantes.md, check patterns) │
                    │ Can apply/create variant for this       │
                    │ template?                               │
                    └───┬─────────────────────────────────┬───┘
                   Yes │                                  │ No
                       │                                  │
    ┌──────────────────▼──┐                               │
    │ USE TBC + CREATE/   │                               │
    │ APPLY VARIANT       │                               │
    └─────────────────────┘                               │
                                                          │
                    ┌─────────────────────────────────────▼───┐
                    │ Priority 4:                             │
                    │ Can create NEW TBC component?           │
                    └───┬─────────────────────────────────┬───┘
                   Yes │                                  │ No
                       │                                  │
    ┌──────────────────▼──┐                               │
    │ CREATE NEW          │                               │
    │ TBC COMPONENT       │                               │
    └─────────────────────┘                               │
                                                          │
                    ┌─────────────────────────────────────▼───┐
                    │ Priority 5:                             │
                    │ Can create NEW component + variant?     │
                    └───┬─────────────────────────────────┬───┘
                   Yes │                                  │ No
                       │                                  │
    ┌──────────────────▼──┐                               │
    │ CREATE NEW          │                               │
    │ COMPONENT + VARIANT │                               │
    └─────────────────────┘                               │
                                                          │
                    ┌─────────────────────────────────────▼───┐
                    │ Priority 6 (LAST RESORT):               │
                    │ Custom step                             │
                    │ MUST DOCUMENT:                          │
                    │ - Why Priority 1-5 ALL failed           │
                    │ - Evidence from Deep Research           │
                    │ - What was checked in variantes.md      │
                    └─────────────────────────────────────────┘
```

## Decision Steps

### Step 1: Identify Core Need

Extract the fundamental requirement:
- What action? (build, deploy, test, scan)
- What target? (language, platform, service)
- What triggers? (branch, tag, manual)

### Step 2: Search Template Catalog

Read `references/templates-catalog.md` for complete list, or category-specific:

| Need | Reference File |
|------|----------------|
| Build code | `references/build-templates.md` |
| Deploy | `references/deployment-templates.md` |
| Analysis/Test/Package | `references/analysis-templates.md` |

### Step 3: Evaluate Template Fit

Read `schemas/_meta.json` for component names, versions, and tags.
Read `schemas/{template-name}.json` for inputs and check:

1. **Inputs match use case?**
   - Required inputs available
   - Optional inputs cover customization needs

2. **Output matches expectation?**
   - Stages align with pipeline needs
   - Artifacts produced correctly

3. **Variants available?**
   - Read `references/variantes.md` for available variants

4. **Presets applicable?**
   - Read `references/presets.md` for pre-configured settings

### Step 0: Deep Research Phase (MANDATORY BEFORE ANY DECISION)

**CRITICAL:** This phase MUST complete before ANY decision can be made. This is not optional.

The Deep Research Phase has 5 sub-phases that must execute in order:

```
┌─────────────────────────────────────────────────────────────────┐
│              DEEP RESEARCH PHASE (MANDATORY)                    │
├─────────────────────────────────────────────────────────────────┤
│ Phase 0.1: Inventory ALL Templates                              │
│   Read schemas/_meta.json                                       │
│   Extract: component names, project paths, file locations       │
│   Output: Complete template inventory with variants             │
├─────────────────────────────────────────────────────────────────┤
│ Phase 0.2: Download & Analyze Template YML Files                │
│   For EACH potentially matching template:                       │
│   - Build URL from _meta.json: gitlab.com/{project}/-/raw/...   │
│   - Download actual .yml template file                          │
│   - Extract: stages, jobs, scripts, tools used                  │
│   - Identify underlying tools                                   │
│   Output: Template capability matrix with REAL code             │
├─────────────────────────────────────────────────────────────────┤
│ Phase 0.3: Read ALL Variants (CRITICAL)                         │
│   Read references/variantes.md COMPLETELY                       │
│   - List ALL variants across ALL templates                      │
│   - Identify variant patterns                                   │
│   - Check which variants exist for matching templates           │
│   - Check which variant PATTERNS could be applied/created       │
│   Output: Variant availability matrix                           │
├─────────────────────────────────────────────────────────────────┤
│ Phase 0.4: Research Underlying Tools Documentation              │
│   For EACH underlying tool identified in Phase 0.2:             │
│   - WebSearch: official documentation                           │
│   - Extract: tool version, ALL capabilities, flags, options     │
│   - Compare: what template uses vs what tool can do             │
│   Output: Tool capability analysis                              │
├─────────────────────────────────────────────────────────────────┤
│ Phase 0.5: Cross-Reference Analysis                             │
│   - Compare user need vs template capabilities (from YML)       │
│   - Compare user need vs VARIANT capabilities (from 0.3)        │
│   - Compare user need vs tool capabilities (from docs)          │
│   - Identify: can existing variant solve it?                    │
│   - Identify: can variant from other template be applied?       │
│   Output: Fit analysis following Priority 1-6 hierarchy         │
└─────────────────────────────────────────────────────────────────┘
```

#### Phase 0.1: Inventory ALL Templates

**MUST read `schemas/_meta.json` first.** This file contains:
- All component names
- Project paths and file locations (for URL construction)
- Tags and categories
- **Variants available** (authentication, secrets, cloud-specific)

**Version Policy:** Always use the latest version available. Do not ask the user about versions.

```
Output format:
┌──────────────────────────────────────────────────────────────────────┐
│ Template Inventory (from _meta.json)                                 │
├──────────────────┬────────────────────┬──────────────────────────────┤
│ Component        │ Project            │ Variants                     │
├──────────────────┼────────────────────┼──────────────────────────────┤
│ {component-1}    │ {project-path-1}   │ {variant-a}, {variant-b}     │
├──────────────────┼────────────────────┼──────────────────────────────┤
│ {component-2}    │ {project-path-2}   │ -                            │
├──────────────────┼────────────────────┼──────────────────────────────┤
│ {component-3}    │ {project-path-3}   │ {variant-c}                  │
├──────────────────┼────────────────────┼──────────────────────────────┤
│ ...              │ ...                │ ...                          │
└──────────────────┴────────────────────┴──────────────────────────────┘
```

#### Phase 0.2: Download & Analyze Template YML Files

**MUST download actual template files from the official TBC repository.**

For **EACH** template identified as potentially relevant:

1. **Build URL from `schemas/_meta.json` data:**

   The `_meta.json` contains entries like:
   ```json
   {
     "name": "{component-name}",
     "version": "{version}",
     "project": "{project-path}",
     "file": "{yml-file-path}"
   }
   ```

   **URL Construction:**
   ```
   https://gitlab.com/{project}/-/raw/{version}/{file}
   ```

2. **Download template YML:**
   ```
   WebFetch: https://gitlab.com/{project}/-/raw/{version}/{file}
   ```

3. **Analyze the actual YML content:**
   - What stages does it create?
   - What jobs does it define?
   - What scripts does it execute?
   - What Docker images does it use?
   - What CLI tools does it invoke?
   - What variables does it read?
   - What extension points exist? (before_script, after_script, scripts-dir)

3. **Also read local schema:**
   - Read `schemas/{template}.json` for input definitions

```
Output format per template:
┌────────────────────────────────────────────────────┐
│ Template: {component-name}                         │
│ Source: gitlab.com/{project-path}                  │
├────────────────────────────────────────────────────┤
│ YML Analysis:                                      │
│   Docker Image: {image}:{tag}                      │
│   Tools Invoked: {tool-1}, {tool-2}                │
│   Commands Used: {cmd-1}, {cmd-2}, {cmd-3}         │
├────────────────────────────────────────────────────┤
│ Schema Inputs:                                     │
│   - {input-1} (required): {description}            │
│   - {input-2} (optional): {description}            │
│   - {input-3} (optional): {description}            │
├────────────────────────────────────────────────────┤
│ Extension Points (from YML):                       │
│   - {extension-1}: {what it does}                  │
│   - {extension-2}: {what it does}                  │
├────────────────────────────────────────────────────┤
│ Variants Available:                                │
│   - {variant-1}: {description}                     │
│   - {variant-2}: {description}                     │
└────────────────────────────────────────────────────┘
```

#### Phase 0.3: Read ALL Variants (CRITICAL)

**MUST read `references/variantes.md` COMPLETELY.** This step cannot be skipped.

1. **List ALL variants across ALL templates:**
   - Not just variants of the matching template
   - ALL variants in the entire TBC framework

2. **Identify variant patterns:**
   - Authentication variants
   - Secret management variants
   - Cloud-specific variants
   - Other patterns found in `references/variantes.md`

3. **Check applicability:**
   - Does the matching template have a variant that solves the need?
   - Does ANOTHER template have a variant pattern that could be applied?
   - Can a new variant be created following existing patterns?

```
Output format:
┌────────────────────────────────────────────────────────────────┐
│ Variant Analysis (from references/variantes.md)                │
├────────────────────────────────────────────────────────────────┤
│ Variants for matching template ({template-name}):              │
│   - {variant-1}: {what it adds}                                │
│   - {variant-2}: {what it adds}                                │
│   - None available: ❌                                          │
├────────────────────────────────────────────────────────────────┤
│ Variant PATTERNS in other templates:                           │
│   - {pattern-1}: exists in {template-a}, {template-b}          │
│   - {pattern-2}: exists in {template-c}, {template-d}          │
│   - {pattern-3}: exists in {template-e}                        │
├────────────────────────────────────────────────────────────────┤
│ Could pattern be applied to {template-name}?                   │
│   - {pattern-1}: ✅/❌ {reason}                                  │
│   - {pattern-2}: ✅/❌ {reason}                                  │
│   - {pattern-3}: ✅/❌ {reason}                                  │
└────────────────────────────────────────────────────────────────┘
```

#### Phase 0.4: Research Underlying Tools Documentation

**MUST use WebSearch** to get official documentation for each tool identified in Phase 0.2.

**CRITICAL: Search PROACTIVELY for user's specific needs.**

For each tool:

1. **Search official documentation:**
   ```
   WebSearch: "{tool} official documentation"
   ```

2. **Search SPECIFICALLY for user's requirements:**
   ```
   # If user needs authentication:
   WebSearch: "{tool} authentication"
   WebSearch: "{tool} credentials"
   WebSearch: "{tool} {user-auth-requirement}"

   # If user needs file operations:
   WebSearch: "{tool} {user-file-requirement}"

   # General pattern - search for what user needs:
   WebSearch: "{tool} {user-specific-need}"
   ```

   **DO NOT ASSUME the tool doesn't support something. SEARCH FIRST.**

3. **Extract ALL capabilities from docs:**
   - ALL flags, options, features
   - Look for the specific capability user needs
   - Document if tool supports it or not (with evidence)

4. **If tool SUPPORTS what user needs:**
   - Return to Priority evaluation
   - Template can likely use this via extension points
   - Check if variant exists or can be created
   - **DO NOT recommend custom step if tool supports it**

```
Output format:
┌────────────────────────────────────────────────────────────────┐
│ Tool: {tool-name}                                              │
├────────────────────────────────────────────────────────────────┤
│ Official Docs: {official-docs-url}                             │
│ Version in TBC: {version-from-yml}                             │
├────────────────────────────────────────────────────────────────┤
│ USER NEEDS: {what user specifically requested}                 │
│                                                                │
│ Searched for user's need:                                      │
│   WebSearch: "{tool} {user-need-1}" → {result}                 │
│   WebSearch: "{tool} {user-need-2}" → {result}                 │
│                                                                │
│ TOOL SUPPORTS USER NEED? ✅/❌                                  │
│   Evidence: {flag/option/feature that supports it}             │
├────────────────────────────────────────────────────────────────┤
│ ALL Capabilities (from official docs):                         │
│   - {capability-1}: {description}                              │
│   - {capability-2}: {description}                              │
│   - ...                                                        │
├────────────────────────────────────────────────────────────────┤
│ What TBC Template Uses:                                        │
│   - {command-used-1}                                           │
│   - {command-used-2}                                           │
├────────────────────────────────────────────────────────────────┤
│ If tool SUPPORTS user need:                                    │
│   → Can template extension points enable it? ✅/❌             │
│   → Can variant be created? ✅/❌                               │
│   → Re-evaluate Priority 2-3 before considering custom step    │
└────────────────────────────────────────────────────────────────┘
```

#### Phase 0.5: Cross-Reference Analysis

Compare user requirements against findings from Phases 0.2, 0.3, and 0.4:

```
Output format:
┌─────────────────────────────────────────────────────────────────┐
│ Cross-Reference Analysis                                        │
├─────────────────────────────────────────────────────────────────┤
│ User Need: {user-requirement-description}                       │
├─────────────────────────────────────────────────────────────────┤
│ Priority 1 - Template Direct:                                   │
│   - {template}: {analysis}                                      │
│     → ✅ Covers 100% / ❌ Missing: {what's missing}             │
├─────────────────────────────────────────────────────────────────┤
│ Priority 2 - Template + Existing Variant:                       │
│   - {template} + {variant}: {analysis}                          │
│     → ✅ Covers need / ❌ Still missing: {what}                 │
├─────────────────────────────────────────────────────────────────┤
│ Priority 3 - Variant Pattern from Other Template:               │
│   - Pattern {pattern-name} from {other-template}                │
│   - Could apply to {template}? ✅/❌ {reason}                   │
│   - Would solve user need? ✅/❌ {reason}                       │
├─────────────────────────────────────────────────────────────────┤
│ Priority 4 - New Component:                                     │
│   - Could create new TBC component? ✅/❌ {reason}              │
├─────────────────────────────────────────────────────────────────┤
│ Priority 5 - New Component + Variant:                           │
│   - Could create new component + variant? ✅/❌ {reason}        │
├─────────────────────────────────────────────────────────────────┤
│ Priority 6 - Custom Step (LAST RESORT):                         │
│   - Why Priorities 1-5 ALL failed: {documented reasons}         │
├─────────────────────────────────────────────────────────────────┤
│ DECISION: Priority {N} - {solution}                             │
│                                                                 │
│ Evidence:                                                       │
│   - {source-1}: {what it confirms}                              │
│   - {source-2}: {what it confirms}                              │
└─────────────────────────────────────────────────────────────────┘
```

**Only after Phase 0 completes with REAL data can the decision process continue.**

### Step 4: Final Analysis (After Deep Research)

Apply the Priority 1-6 hierarchy based on Deep Research findings.

### Step 5: Decision Matrix

| Priority | Condition | Decision |
|----------|-----------|----------|
| 1 | Template covers 100% | Use TBC direct |
| 2 | Template + existing variant covers | Use TBC + variant |
| 3 | Variant pattern from other template applies | Use TBC + create/apply variant |
| 4 | Can create new TBC component | Create new component |
| 5 | Can create new component + variant | Create component + variant |
| 6 | ALL above fail (documented) | Custom step (RARE) |
| None | No viable path found | Custom solution (document why) |

## Common Scenarios

### Scenario: Template Exists but Doesn't Fit

```
{template-A} ──► {use case matches?}
                  │
         Yes ◄────┼────► No
          │               │
          ▼               ▼
   Use {template-A}    Use {template-B} + script
```

**Pattern:** Template exists but designed for different use case.
**Solution:** Use alternative template with extension points.

### Scenario: Multiple Templates Needed

```
{template-1} ──► {output} ──► {template-2} ──► {custom script}
```

**Pattern:** Pipeline requires outputs from multiple templates.
**Solution:** Combine multiple TBC templates + custom job.

### Scenario: No Template Matches

Document why and provide custom approach:
1. Explain what was searched
2. Why templates don't fit
3. Custom solution with best practices

## Output Format

Always include the decision path taken:

```
## Decision Path

User Request
    │
    ▼
Identify Core Need: [description]
    │
    ▼
Search Templates: [templates checked]
    │
    ▼
Template exists? ──► [Yes/No]
    │
    ▼
[Continue showing only the branch taken...]
    │
    ▼
Result: [Use TBC / TBC + script / Custom]
```

### Example: TBC Component Used

```
## Decision Path

User Request: "{user-request}"
    │
    ▼
Identify Core Need: {action} + {target}
    │
    ▼
Search: references/{category}-templates.md
    │
    ▼
Template exists? ──► Yes ({template-1}, {template-2})
    │
    ▼
Read: schemas/_meta.json, schemas/{template-1}.json, schemas/{template-2}.json
    │
    ▼
Inputs cover use case? ──► Yes
    │
    ▼
Result: Use TBC components ({template-1} + {template-2})
```

### Example: Deep Research Required

```
## Decision Path

User Request: "{user-request}"
    │
    ▼
Identify Core Need: {specific-need-description}
    │
    ▼
Search: references/{category}-templates.md
    │
    ▼
Template exists? ──► Yes ({template-A})
    │
    ▼
Read: schemas/_meta.json, schemas/{template-A}.json
    │
    ▼
Inputs cover use case? ──► Partial ({reason})
    │
    ▼
Deep Research Phase
    │
    ▼
Download: {template-A} YML from gitlab.com/{project}
    │
    ▼
Analyze: Tools used = {tool-1}
    │
    ▼
WebSearch: {tool-1} official documentation
    │
    ▼
Tool capability found? ──► Yes ({specific-capability})
    │
    ▼
Available via extension point? ──► Yes (scripts-dir)
    │
    ▼
Result: TBC ({template-A} + {variant}) + custom script
```

### Example: Custom Solution

```
## Decision Path

User Request: "[specific need]"
    │
    ▼
Identify Core Need: [description]
    │
    ▼
Search: [templates checked]
    │
    ▼
Template exists? ──► No
    │
    ▼
Deep Research: tool alternatives
    │
    ▼
Found compatible tool? ──► No
    │
    ▼
Result: Custom solution needed

## Why TBC Doesn't Fit

- Searched: [list]
- Reason: [explanation]
- Custom approach: [details]
```
