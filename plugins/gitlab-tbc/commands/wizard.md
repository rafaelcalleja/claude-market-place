---
description: Guided wizard to generate GitLab CI/CD configuration with framework-first evaluation
allowed-tools: ["Read", "AskUserQuestion", "Skill", "Task"]
---

# TBC Wizard

**FIRST**: Load the `building-with-tbc` skill using the Skill tool.

The skill contains the Framework-First Principle and all knowledge. Follow this principle strictly.

## Phase 1: Deep Research Phase (MANDATORY)

**NO decisions can be made until this phase completes.**

Read `references/component-decision.md` for the complete process. Execute all 4 sub-phases:

### Phase 0.1: Inventory ALL Templates

1. Read `schemas/_meta.json`
2. Extract component names, project paths, file locations, and **VARIANTS**
3. **Version Policy:** Always use latest version. Do not ask about versions.
4. Output:

```
┌──────────────────────────────────────────────────────────────────────┐
│ Template Inventory (from _meta.json)                                 │
├──────────────────┬────────────────────┬──────────────────────────────┤
│ Component        │ Project            │ Variants                     │
├──────────────────┼────────────────────┼──────────────────────────────┤
│ [name]           │ [project path]     │ [variant1, variant2, ...]    │
│ ...              │ ...                │ ...                          │
└──────────────────┴────────────────────┴──────────────────────────────┘
```

### Phase 0.2: Download & Analyze Template YML Files

For EACH template that could match the user need:

1. **Build URL from _meta.json:**
   ```
   https://gitlab.com/{project}/-/raw/{version}/{file}
   ```

2. **Download with WebFetch**

3. **Analyze YML content and output:**

```
┌────────────────────────────────────────────────────┐
│ Template: [name]                                   │
│ Source: [URL downloaded from]                      │
├────────────────────────────────────────────────────┤
│ YML Analysis:                                      │
│   Docker Image: [image:tag]                        │
│   Tools Invoked: [tools from YML]                  │
│   Commands Used: [specific commands in scripts]    │
├────────────────────────────────────────────────────┤
│ Schema Inputs (from schemas/{name}.json):          │
│   - [input] (required/optional): [description]     │
├────────────────────────────────────────────────────┤
│ Extension Points (from YML):                       │
│   - [scripts-dir, before_script, etc.]             │
├────────────────────────────────────────────────────┤
│ Variants: [from references/variantes.md]           │
└────────────────────────────────────────────────────┘
```

### Phase 0.3: Read ALL Variants (CRITICAL)

**MUST read `references/variantes.md` COMPLETELY.** Cannot skip.

1. List ALL variants across ALL templates
2. Identify variant patterns (from `references/variantes.md`)
3. Output:

```
┌────────────────────────────────────────────────────────────────┐
│ Variant Analysis (from references/variantes.md)                │
├────────────────────────────────────────────────────────────────┤
│ Variants for matching template:                                │
│   - [variant-1]: [what it adds]                                │
│   - None available: ❌                                          │
├────────────────────────────────────────────────────────────────┤
│ Variant PATTERNS in other templates:                           │
│   - [pattern-1]: exists in [templates]                         │
│   - [pattern-2]: exists in [templates]                         │
├────────────────────────────────────────────────────────────────┤
│ Could pattern be applied?                                      │
│   - [pattern]: ✅/❌ [reason]                                   │
└────────────────────────────────────────────────────────────────┘
```

### Phase 0.4: Research Underlying Tools Documentation

**MUST use WebSearch** for EACH tool identified in Phase 0.2:

1. Search: `"{tool} official documentation {version}"`
2. Extract ALL capabilities (not just what TBC uses)
3. Output:

```
┌────────────────────────────────────────────────────┐
│ Tool: [name]                                       │
├────────────────────────────────────────────────────┤
│ Official Docs: [URL]                               │
│ Version in TBC: [version from YML]                 │
├────────────────────────────────────────────────────┤
│ ALL Capabilities (from docs):                      │
│   - [capability 1]                                 │
│   - [capability 2]                                 │
├────────────────────────────────────────────────────┤
│ What TBC Template Uses:                            │
│   - [commands from YML analysis]                   │
├────────────────────────────────────────────────────┤
│ Available via extension points:                    │
│   - [what can be done via scripts-dir, etc.]       │
└────────────────────────────────────────────────────┘
```

### Phase 0.5: Cross-Reference Analysis

Compare user need vs findings, following Priority 1-6 hierarchy:

```
┌─────────────────────────────────────────────────────────────────┐
│ Cross-Reference Analysis                                        │
├─────────────────────────────────────────────────────────────────┤
│ User Need: [description]                                        │
├─────────────────────────────────────────────────────────────────┤
│ Priority 1 - Template Direct:                                   │
│   - [template]: ✅ Covers 100% / ❌ Missing: [what]             │
├─────────────────────────────────────────────────────────────────┤
│ Priority 2 - Template + Existing Variant:                       │
│   - [template] + [variant]: ✅ Covers / ❌ Still missing: [what]│
├─────────────────────────────────────────────────────────────────┤
│ Priority 3 - Variant Pattern from Other Template:               │
│   - Pattern [name] from [other-template]                        │
│   - Could apply? ✅/❌ Would solve need? ✅/❌                   │
├─────────────────────────────────────────────────────────────────┤
│ Priority 4 - New Component: ✅/❌ [reason]                      │
├─────────────────────────────────────────────────────────────────┤
│ Priority 5 - New Component + Variant: ✅/❌ [reason]            │
├─────────────────────────────────────────────────────────────────┤
│ Priority 6 - Custom Step: Why 1-5 ALL failed: [reasons]         │
├─────────────────────────────────────────────────────────────────┤
│ DECISION: Priority [N] - [solution]                             │
│ Evidence: [sources]                                             │
└─────────────────────────────────────────────────────────────────┘
```

**Only after ALL 5 phases complete with REAL data, proceed to Phase 2.**

## Phase 2: Configuration (Only if TBC fits)

### Step 0: Global Options

Use AskUserQuestion to configure:

1. **Include Mode** (multiSelect: false)
   - component (Recommended for GitLab 16.0+)
   - project (Self-hosted GitLab)
   - remote (External GitLab)

2. **Version Mode** (multiSelect: false)
   - minor (@7.5) - Recommended
   - major (@7) - Latest features
   - full (@7.5.2) - Maximum stability

3. **Detail Level** (multiSelect: false)
   - basic - Essential variables only
   - advanced - All configuration options

4. **Custom Stages** (multiSelect: false)
   - No (default)
   - Yes

### Steps 1-7: Template Selection

For each category, following the skill's instructions:

| Step | Category | Selection | Reference File |
|------|----------|-----------|----------------|
| 1 | Build | Single | build-templates.md |
| 2 | Code Analysis | Multiple | analysis-templates.md |
| 3 | Packaging | Single | analysis-templates.md |
| 4 | Infrastructure | Single | deployment-templates.md |
| 5 | Deployment | Single | deployment-templates.md |
| 6 | Acceptance | Multiple | analysis-templates.md |
| 7 | Other | Multiple | analysis-templates.md |

**For each step:**
1. Present options via AskUserQuestion (respect single/multiple rule)
2. For each selection, follow skill's "Workflow Instructions"
3. Include "None" option for single-selection categories

### Step 8: Generate & Validate

1. Generate `.gitlab-ci.yml` following the skill's configuration format
2. Include variants as separate components if user selected them
3. Add secret variables as comments
4. Add custom stages if requested
5. **CRITICAL**: Use SlashCommand tool with `tbc:validate` before presenting
6. Present final configuration with next steps

## Output Format

```
✓ TBC Configuration Generated

[Generated YAML]

---

Secret Variables (configure in GitLab CI/CD Settings):
- VARIABLE_NAME: Description

---

Next Steps:
1. Copy to .gitlab-ci.yml
2. Configure secret variables in GitLab
3. Commit and push
```

## Error Handling

- Schema not found → Check available templates in skill
- User skips all categories → Warn about empty configuration
- Validation fails → Fix and re-validate before presenting
