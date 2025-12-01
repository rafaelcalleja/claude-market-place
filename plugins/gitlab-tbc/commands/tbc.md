---
description: Generate GitLab CI/CD configurations using To-Be-Continuous framework
argument-hint: Optional description of what you want to build
allowed-tools: ["Read", "Write", "Glob", "Grep", "AskUserQuestion", "Task", "Skill"]
---

# TBC - GitLab CI/CD Configuration Generator

**FIRST**: Load the `building-with-tbc` skill using the Skill tool.

The skill provides the **Framework-First Principle** and all TBC knowledge. Follow this principle strictly.

## Intent Classification

Analyze user request and route to appropriate flow:

| Keywords | Flow | Action |
|----------|------|--------|
| create, generate, new, setup, build | GENERATE | New configuration |
| migrate, convert, upgrade, existing | MIGRATE | Convert to TBC |
| what, how, explain, list, compare | CONSULT | Answer questions |

## GENERATE Flow

### Phase 1: Framework Evaluation (MANDATORY)

**Never assume solution. Always evaluate framework first.**

1. **Identify core need**:
   - What action? (build, deploy, test, scan, release)
   - What target? (language, platform, service, cloud)
   - What triggers? (branch, tag, manual, schedule)

2. **Evaluate framework fit**:
   - Read `references/component-decision.md` for decision flowchart
   - Search `references/templates-catalog.md` for matching templates
   - Read `schemas/_meta.json` + `schemas/{template}.json` for capabilities
   - Check `references/variantes.md` for variants

3. **Output decision path** (mandatory):
   ```
   ## Decision Path
   User Request: "[request]"
       │
       ▼
   Core Need: [action + target + triggers]
       │
       ▼
   [Show branch taken from decision flowchart]
       │
       ▼
   Result: [TBC / TBC+variant / TBC+script / Custom (with reason)]
   ```

### Phase 2: Configuration (Only after Phase 1)

1. **Configure global options** (from skill):
   - Include mode (component/project/remote)
   - Version mode (major/minor/full)
   - Detail level (basic/advanced)

2. **Template selection** - Follow skill's workflow

3. **Configure variables** - Use skill's configuration format

4. **Generate** - Follow skill's format

5. **CRITICAL**: Use SlashCommand tool with `tbc:validate` before presenting

## MIGRATE Flow

1. Read existing `.gitlab-ci.yml`
2. Analyze current jobs and configurations
3. Map to equivalent TBC templates (use skill knowledge)
4. Generate TBC configuration
5. Use SlashCommand tool with `tbc:validate`
6. Present migration plan with benefits

## CONSULT Flow

1. Identify topic from user question
2. Read relevant reference file (skill tells which one)
3. Provide clear answer with examples
4. Offer next steps (generate config, see more templates)

## Output Format

```
[Generated/Migrated YAML]

---

Secret Variables (configure in GitLab CI/CD Settings):
- VARIABLE_NAME: Description

---

Next Steps:
1. Copy to .gitlab-ci.yml
2. Configure secret variables
3. Commit and push
```

## Remember

- Load skill first - it has all knowledge
- Follow skill's "How to Use This Skill" instructions
- ALWAYS validate before presenting
- Never hallucinate - read schemas
