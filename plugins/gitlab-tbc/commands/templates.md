---
description: List available TBC templates and their categories
allowed-tools: ["Read", "Skill"]
---

# TBC Templates - Template Catalog

**FIRST**: Load the `building-with-tbc` skill using the Skill tool.

The skill provides complete template information. Use its reference files.

## Workflow

### 1. Determine Intent

| User Request | Action |
|--------------|--------|
| Show all | Read `references/templates-catalog.md` |
| Filter by category | Read category-specific reference |
| Search by keyword | Search in catalog |
| Compare templates | Read both schemas, compare |
| Template details | Read `schemas/[template].json` |

### 2. Present Information

Follow skill's template categories and selection rules:
- Single selection: Build, Packaging, Infrastructure, Deployment
- Multiple selection: Code Analysis, Acceptance, Other

### 3. Offer Next Actions

After showing templates:
- Generate configuration: `/tbc`
- Run wizard: `/tbc:wizard`
- Validate config: `/tbc:validate`

## Output Formats

**Category listing:**
```
CATEGORY NAME (count) - Selection: SINGLE/MULTIPLE
1. Template - Description
   Variants: [if any]
```

**Template details:**
```
Template: [name]
Category: [category] | Selection: [rule]
Description: [from schema]
Variables: [key variables]
Variants: [available variants]
Example: [component mode syntax]
```

**Comparison:**
```
[Template A] vs [Template B]
- Approach: [differences]
- Pros/Cons: [trade-offs]
- Best for: [use cases]
```

## Remember

- Load skill first
- Read from references - never hallucinate template lists
- Show selection type per category
- Mention variants when relevant
