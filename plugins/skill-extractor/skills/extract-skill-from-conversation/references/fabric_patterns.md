# Fabric Patterns for Skill Extraction

Fabric is an AI framework that provides modular patterns for processing content. This reference details the patterns most useful for extracting skills from conversations.

## Core Extraction Patterns

### extract_wisdom

**Purpose:** Extract insights, learnings, and wisdom from content.

**Output:** Bullet points of key takeaways, mental models, and reusable knowledge.

**Use for:** Key Insights section of skills.

**Example output:**
```markdown
- Most JWT auth crashes are caused by missing token expiration validation
- Always check functional_errors/ directory before assuming pipeline bugs
- Small rejection rates (<2%) typically indicate data quality, not code issues
```

### extract_instructions

**Purpose:** Extract step-by-step procedures and actionable instructions.

**Output:** Numbered list of procedures with details.

**Use for:** Steps section of skills.

**Example output:**
```markdown
1. Check logs for null pointer errors
2. Verify token expiration handling in auth.js
3. Add validation if missing
4. Run tests to confirm fix
```

### extract_primary_problem

**Purpose:** Identify the core problem or challenge being addressed.

**Output:** Clear problem statement with context.

**Use for:** Problem Pattern section to describe when to use the skill.

**Example output:**
```markdown
The primary problem is data validation rejections during lakehouse ingestion,
where records pass raw layer but fail standardized layer validation due to
NULL or empty required fields.
```

### extract_primary_solution

**Purpose:** Extract the solution that actually worked.

**Output:** Concise description of the winning approach.

**Use for:** Solution summary, eliminating trial-and-error noise.

**Example output:**
```markdown
Query the functional_errors/ parquet files directly to see rejected records,
then analyze NULL patterns across required fields to identify validation failures.
```

## Supporting Patterns

### summarize

**Purpose:** Create a brief summary of content.

**Output:** 1-3 paragraph overview.

**Use for:** Skill description and overview section.

### create_recursive_outline

**Purpose:** Break down complex topics into hierarchical structure.

**Output:** Nested outline with levels of detail.

**Use for:** Complex multi-phase workflows.

### extract_patterns

**Purpose:** Identify recurring patterns and themes.

**Output:** List of patterns with examples.

**Use for:** Identifying when a skill applies (pattern recognition).

## Pattern Combination Strategies

### Parallel Extraction (Recommended)

Run multiple patterns simultaneously for speed:

```bash
cat input.txt | fabric -p extract_wisdom > wisdom.md &
cat input.txt | fabric -p extract_instructions > steps.md &
cat input.txt | fabric -p extract_primary_problem > problem.md &
cat input.txt | fabric -p extract_primary_solution > solution.md &
wait
```

### Sequential Refinement

For deeper analysis, chain patterns:

```bash
# First pass: get overview
cat input.txt | fabric -p summarize > summary.md

# Second pass: detailed extraction
cat input.txt | fabric -p extract_instructions > steps.md

# Third pass: refine steps into outline
cat steps.md | fabric -p create_recursive_outline > refined_steps.md
```

### Strategy Modifiers

Add reasoning strategies for better extraction:

```bash
# Chain of Thought reasoning
fabric -p extract_wisdom --strategy cot

# Self-refinement
fabric -p extract_instructions --strategy self-refine

# Tree of Thoughts (multiple approaches)
fabric -p extract_primary_solution --strategy tot
```

## Pattern Selection Guide

| Conversation Type | Primary Patterns | Secondary Patterns |
|------------------|------------------|-------------------|
| **Debugging session** | extract_primary_problem, extract_primary_solution | extract_wisdom |
| **Feature implementation** | extract_instructions, extract_wisdom | summarize |
| **Research/Learning** | extract_wisdom, summarize | extract_patterns |
| **Refactoring** | extract_instructions, extract_patterns | extract_primary_problem |
| **Configuration** | extract_instructions | extract_wisdom |

## Fabric Strategies

| Strategy | Description | Best For |
|----------|-------------|----------|
| `cot` | Chain of Thought - step-by-step reasoning | Complex problems |
| `tot` | Tree of Thoughts - explore multiple paths | Multiple solutions |
| `self-refine` | Iterative improvement | Polishing output |
| `reflexion` | Self-critique and correction | Quality validation |
| `standard` | Default prompting | Simple extractions |

## Tips for Better Extraction

1. **Clean input first** - Remove system messages, truncate long tool outputs
2. **Run in parallel** - Patterns are independent, run simultaneously
3. **Review before combining** - Each extraction may need filtering
4. **Use strategies** - `--strategy cot` improves complex extractions
5. **Iterate** - Run patterns multiple times if needed, take best parts
