# SKILL.md Template

Use this template when combining Fabric extractions into a final skill.

## Template

```markdown
---
name: [skill-name-lowercase-with-dashes]
description: "[One-line description of what problem this skill solves and when to use it]"
---

# [Skill Title in Title Case]

[2-3 sentence overview of what this skill does. Derived from extract_primary_problem and summarize outputs.]

## Problem Pattern

[When to use this skill. What symptoms or situations indicate this skill is needed?]

**Common triggers:**
- [Trigger 1]
- [Trigger 2]
- [Trigger 3]

## Prerequisites

[What must be in place before using this skill]

- [Tool/dependency 1]
- [Access requirement]
- [Knowledge prerequisite]

## Steps

[Numbered steps derived from extract_instructions. Use imperative mood.]

### 1. [First Step Title]

[Description of what to do]

```bash
[Command or code example]
```

### 2. [Second Step Title]

[Description]

```bash
[Command]
```

[Continue for all steps...]

## Key Insights

[Bullet points from extract_wisdom. These are the "aha moments" that make this skill valuable.]

- [Insight 1]
- [Insight 2]
- [Insight 3]

## Common Mistakes

[What NOT to do - patterns that lead to failure]

- [Mistake 1 with brief explanation]
- [Mistake 2]
- [Mistake 3]

## When to Use This Skill

[Clear description of applicable scenarios]

- [Scenario 1]
- [Scenario 2]

## When NOT to Use This Skill

[Scenarios where this skill doesn't apply]

- [Exception 1]
- [Exception 2]

## References

[Any URLs, files, or resources that were helpful]

- [Reference 1]
- [Reference 2]

---

*Generated from conversation on [date]*
```

## Mapping Fabric Outputs to Template Sections

| Template Section | Fabric Pattern Source |
|-----------------|----------------------|
| Description | `summarize` (first line) |
| Overview | `summarize` |
| Problem Pattern | `extract_primary_problem` |
| Steps | `extract_instructions` |
| Key Insights | `extract_wisdom` |
| Solution (optional) | `extract_primary_solution` |

## Quality Checklist

Before finalizing the skill:

- [ ] Description is specific and includes trigger phrases
- [ ] Problem Pattern clearly describes when to use
- [ ] Steps are in imperative mood ("Do X" not "I did X")
- [ ] Steps include actual commands/code that worked
- [ ] Key Insights are non-obvious learnings
- [ ] Common Mistakes are derived from trial-and-error in conversation
- [ ] All trial-and-error noise is removed
- [ ] References are valid URLs/paths
- [ ] Skill is self-contained (can be used without original conversation)

## Example: Before and After

### Before (Raw Conversation)

```
User: My app crashes on login
Claude: Let me check... [reads logs, tries 3 things, finally finds issue]
Claude: Fixed it! The token wasn't being validated
User: Thanks!
```

### After (Extracted Skill)

```markdown
---
name: fix-login-crash-token-validation
description: "Debug and fix login crashes caused by missing JWT token validation"
---

# Fix Login Crash - Token Validation

Diagnose and resolve application crashes during login caused by JWT token validation issues.

## Problem Pattern

Application crashes on login with null pointer or authentication errors.

**Common triggers:**
- NullPointerException in auth module
- "Token invalid" or "Token expired" errors
- Login works for new tokens, fails for old ones

## Steps

### 1. Check Authentication Logs

```bash
tail -f logs/auth.log | grep -E "null|token|auth"
```

### 2. Verify Token Validation Code

Check `src/auth.js` for expiration validation:

```javascript
// Look for this pattern
if (!token.exp || token.exp < Date.now()) {
  throw new Error('Token expired');
}
```

### 3. Add Missing Validation

If validation is missing, add it before token use.

## Key Insights

- Most login crashes = missing token expiration checks
- Tokens can be valid format but expired
- Always validate before use, not just at creation

## Common Mistakes

- Assuming valid token format = valid token
- Only checking token existence, not expiration
- Not logging token validation failures
```
