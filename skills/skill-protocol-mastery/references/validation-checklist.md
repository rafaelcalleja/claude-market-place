# Skill Validation Checklist

Complete checklist for validating Agent Skills before deployment.

## Structure Validation

### Required Files

- [ ] SKILL.md file exists in skill directory
- [ ] SKILL.md has valid YAML frontmatter (between `---` markers)
- [ ] Frontmatter contains `name` field
- [ ] Frontmatter contains `description` field
- [ ] Markdown body is present and substantial

### Optional Structure

- [ ] `references/` directory exists if detailed docs needed
- [ ] `examples/` directory exists if code samples needed
- [ ] `scripts/` directory exists if utilities needed
- [ ] `assets/` directory exists if templates/images needed
- [ ] All referenced files actually exist

## Metadata Validation

### Name Field

- [ ] Uses only lowercase letters, numbers, and hyphens
- [ ] Length is 1-64 characters
- [ ] Pattern matches `^[a-z0-9-]+$`
- [ ] Does not contain "anthropic" or "claude"
- [ ] Does not contain XML tags
- [ ] Is descriptive (not vague like "helper", "utils")

### Description Field

- [ ] Is non-empty
- [ ] Length is 1-1024 characters
- [ ] Does not contain XML tags
- [ ] Uses third person ("This skill should be used when...")
- [ ] Includes specific trigger phrases users would say
- [ ] Lists concrete scenarios ("create X", "configure Y")
- [ ] Is not vague or generic
- [ ] Includes both what skill does AND when to use it

## Writing Style Validation

### SKILL.md Body

- [ ] Uses imperative/infinitive form throughout
- [ ] No second person ("You should...", "You need to...")
- [ ] Uses objective, instructional language
- [ ] Verb-first instructions ("Configure...", "Validate...")

### Description Frontmatter

- [ ] Third-person format ("This skill should be used when...")
- [ ] Not "Use this skill when..." (second person)
- [ ] Not "Load when user needs..." (informal)
- [ ] Not just "Provides X guidance" (no triggers)

## Content Quality

### SKILL.md Size

- [ ] Body is under 2,000 words (ideal)
- [ ] Body is under 3,000 words (acceptable)
- [ ] Body is under 5,000 words (maximum)
- [ ] Detailed content moved to references/

### Organization

- [ ] Core concepts clearly explained
- [ ] Essential procedures documented
- [ ] Quick reference tables included where helpful
- [ ] Pointers to references/examples/scripts present
- [ ] Most common use cases covered

### Progressive Disclosure

- [ ] SKILL.md contains only essential content
- [ ] Detailed patterns in references/
- [ ] Working code in examples/
- [ ] Utilities in scripts/
- [ ] All resources referenced in SKILL.md

## Reference Files

### Structure

- [ ] Each reference file has clear purpose
- [ ] Files are organized by topic/domain
- [ ] Long files (>100 lines) have table of contents
- [ ] References are one level deep (not nested)

### Content

- [ ] No duplication between SKILL.md and references
- [ ] Each file can be 2,000-5,000+ words
- [ ] Includes detailed patterns and techniques
- [ ] Covers edge cases and troubleshooting

## Examples

### Quality

- [ ] Examples are complete and runnable
- [ ] Configuration files are valid
- [ ] Template files are usable
- [ ] Real-world usage demonstrated

### Organization

- [ ] Clear naming conventions
- [ ] Each example has single purpose
- [ ] README or comments explain usage

## Scripts

### Functionality

- [ ] Scripts are executable (`chmod +x`)
- [ ] Scripts have proper shebang line
- [ ] Error handling is explicit
- [ ] Exit codes are meaningful

### Documentation

- [ ] Purpose is documented
- [ ] Usage examples provided
- [ ] Dependencies listed
- [ ] No "voodoo constants" (magic numbers explained)

## Testing

### Triggering

- [ ] Skill triggers on expected user queries
- [ ] Trigger phrases in description match real usage
- [ ] Skill doesn't trigger inappropriately

### Functionality

- [ ] Content is helpful for intended tasks
- [ ] Instructions are clear and actionable
- [ ] Examples work correctly
- [ ] Scripts execute successfully

### Progressive Loading

- [ ] References load when needed
- [ ] No unnecessary content loaded
- [ ] Large files accessible via grep patterns

## Common Issues

### Weak Triggers

❌ Problem: `description: Provides guidance for working with X.`

✅ Fix: `description: This skill should be used when the user asks to "create X", "configure X", "validate X".`

### Too Verbose

❌ Problem: SKILL.md is 8,000 words

✅ Fix: Move detailed content to references/, keep SKILL.md under 2,000 words

### Second Person

❌ Problem: `You should start by reading the file.`

✅ Fix: `Start by reading the file.`

### Missing References

❌ Problem: references/ exists but not mentioned in SKILL.md

✅ Fix: Add "## Additional Resources" section with file links

### Vague Description

❌ Problem: `description: Helps with documents`

✅ Fix: `description: This skill should be used when the user asks to "extract PDF text", "fill PDF forms", "merge PDF files".`

## Validation Commands

### Check Frontmatter

```bash
head -20 SKILL.md | grep -E "^(name|description):"
```

### Count Words

```bash
wc -w SKILL.md
# Should be under 3,000 words
```

### Check Writing Style

```bash
grep -n "You should\|You need\|You can\|You must" SKILL.md
# Should return no matches
```

### Verify References

```bash
grep -oE '\[.*\]\(.*\.md\)' SKILL.md | while read ref; do
  file=$(echo "$ref" | sed 's/.*(\(.*\))/\1/')
  [ -f "$file" ] || echo "Missing: $file"
done
```

### Check Description Person

```bash
grep "^description:" SKILL.md | grep -v "This skill should"
# Should return no matches if third-person
```

## Final Review

Before deployment:

1. [ ] All structure checks pass
2. [ ] All metadata checks pass
3. [ ] All writing style checks pass
4. [ ] All content quality checks pass
5. [ ] All testing checks pass
6. [ ] Skill has been used on real tasks
7. [ ] Feedback incorporated from usage
8. [ ] No common issues present
