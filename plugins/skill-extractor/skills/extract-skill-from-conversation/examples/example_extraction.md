# Example: Full Skill Extraction Process

This example shows the complete process of extracting a skill from a real Claude Code conversation about debugging lakehouse data validation.

## Step 1: Find the Conversation

```bash
# List recent conversations
ls -lht ~/.claude/projects/-home-user-project/*.jsonl | head -5

# Found: 4a7aeb91-1a2e-4e3a-bef4-49374adce3f5.jsonl (528K)
```

## Step 2: Check Conversation Topic

```bash
# Extract summaries to understand what it's about
jq -r 'select(.type == "summary") | .summary' conversation.jsonl
```

Output:
```
GRUPO ORTIZ SLA/Autovalidation Bug Investigation
Database backup and deduplication error resolution
```

This is a debugging session about data validation issues.

## Step 3: Parse Conversation

```bash
bash scripts/parse_conversation.sh conversation.jsonl > /tmp/conversation.txt
```

Resulting text (excerpt):
```
=== USER ===
My data shows 198,656 records in raw but only 195,155 in standardized.
What happened to 3,501 records?

=== ASSISTANT ===
Let me investigate the validation rejections...
[TOOL: Read] standardized/company/errors/functional_errors/
...
```

## Step 4: Run Fabric Extraction

```bash
# Parallel extraction
cat /tmp/conversation.txt | fabric -p extract_wisdom > /tmp/wisdom.md &
cat /tmp/conversation.txt | fabric -p extract_instructions > /tmp/instructions.md &
cat /tmp/conversation.txt | fabric -p extract_primary_problem > /tmp/problem.md &
cat /tmp/conversation.txt | fabric -p extract_primary_solution > /tmp/solution.md &
wait
```

### Extract: Problem (excerpt)

```markdown
The primary problem is a discrepancy between record counts in raw layer
(198,656) and standardized layer (195,155), indicating 3,501 records
(1.76%) were rejected during validation.

The root cause is records failing validation rules that require:
- business_id IS NOT NULL
- vcodigo_empresa IS NOT NULL
- vcif_empresa IS NOT NULL AND not empty
- vemail IS NOT NULL AND not empty
```

### Extract: Instructions (excerpt)

```markdown
1. Count records in raw layer using SQL
2. Count records in standardized layer
3. Calculate difference = rejected records
4. Query functional_errors/ directory for rejected records
5. Create external table if direct S3 read fails
6. Analyze NULL patterns across required fields
7. Decide on fix: improve source data, relax rules, or accept rejections
```

### Extract: Wisdom (excerpt)

```markdown
- Small rejection rates (<2%) often indicate data quality, not pipeline bugs
- functional_errors/ contains full rejected records for analysis
- Always run MSCK REPAIR TABLE after creating external tables
- Parquet files in errors/ can be queried directly without re-running pipeline
```

### Extract: Solution (excerpt)

```markdown
The solution involved:
1. Creating external table for functional_errors
2. Running MSCK REPAIR TABLE to load partitions
3. Querying to identify NULL field patterns
4. Confirming rejections were valid (bad source data)
```

## Step 5: Combine into SKILL.md

Final skill (condensed):

```markdown
---
name: debug-lakehouse-validation-rejections
description: "Investigate data validation rejections in lakehouse standardized layer when record counts differ from raw layer"
---

# Debug Lakehouse Data Validation Rejections

Diagnose why records are rejected during lakehouse data validation.

## Problem Pattern

Record count in standardized layer is lower than raw layer.
Symptoms:
- SQL COUNT differences between raw and standardized
- functional_errors/ directory has data
- Business reports missing expected records

## Steps

### 1. Confirm Rejection Count

```sql
-- Raw count
SELECT COUNT(*) FROM raw_table;

-- Standardized count
SELECT COUNT(*) FROM standardized_table;

-- Difference = rejections
```

### 2. Query Functional Errors

```sql
CREATE EXTERNAL TABLE errors_table (...)
LOCATION 's3://bucket/path/errors/functional_errors/';

MSCK REPAIR TABLE errors_table;

SELECT * FROM errors_table LIMIT 100;
```

### 3. Analyze Rejection Patterns

```sql
SELECT
  CASE WHEN field IS NULL THEN 'null' END,
  COUNT(*)
FROM errors_table
GROUP BY 1;
```

## Key Insights

- <2% rejection rate = likely data quality, not bugs
- functional_errors/ contains full records for analysis
- Always MSCK REPAIR TABLE for partitioned tables
- Parquet errors can be queried without re-running pipeline

## Common Mistakes

- Assuming rejections = pipeline bug (often it's data quality)
- Forgetting MSCK REPAIR TABLE (partitions won't load)
- Not checking specific NULL field patterns
```

## Summary

**Input:** 528KB conversation, 139 lines, ~2 hours of work

**Output:** ~100 line skill capturing the essential workflow

**Noise Removed:**
- Trial and error with SQL syntax
- Exploratory file reads
- Back-and-forth clarifications
- Verbose explanations

**Value Kept:**
- The diagnostic workflow
- Key SQL commands
- Non-obvious insights
- Common pitfalls
