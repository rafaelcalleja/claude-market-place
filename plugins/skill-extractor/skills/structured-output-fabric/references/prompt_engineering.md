# Prompt Engineering for Structured JSON Output

This document provides techniques for crafting prompts that reliably produce structured JSON output from LLMs.

## Core Principles

### 1. Be Explicit About Format

**Bad:**
```
Analyze this data and give me a summary.
```

**Good:**
```
Analyze this data and return ONLY a JSON object with these fields: ...
No explanations, no markdown, just raw JSON.
```

### 2. Specify Exact Structure

Always show the complete JSON structure with placeholders:

```json
{
  "field1": "<description>",
  "field2": ["<item1>", "<item2>"],
  "field3": {
    "nested": "<value>"
  }
}
```

### 3. Document Each Field

Provide requirements for each field:

```
Requirements:
- field1: Must be lowercase, max 80 characters
- field2: Array of 3-5 keywords
- field3.nested: ISO 8601 date format
```

### 4. Emphasize "ONLY JSON"

LLMs tend to add explanations. Counter this:

```
Return ONLY the JSON object.
No explanations.
No markdown formatting.
Just the raw JSON.
```

## Using fabric improve_prompt

The `improve_prompt` pattern in fabric enhances prompts for better results:

```bash
cat base_prompt.txt | fabric -p improve_prompt -o improved_prompt.txt
```

### Before improve_prompt:

```
Analyze these user messages and return JSON with topic, tags, and summary.
```

### After improve_prompt:

```
You are an expert conversation analyst specializing in extracting metadata.

## Your Task
Analyze the user messages provided below. Your goal is to understand the user's intent.

## Output Format
Generate a JSON object with the following structure:

{
  "topic": "<one-line description>",
  "tags": ["<keyword1>", "<keyword2>"],
  "summary": "<2-3 sentence summary>"
}

## Detailed Requirements

**topic:**
- Maximum 80 characters
- Concise and immediately convey essence
- Focus on primary objective

**tags:**
- Provide exactly 5-7 keywords
- Use lowercase only
- Prefer single words

**summary:**
- Write 2-3 complete sentences
- Focus exclusively on USER's goals
- Use past tense

## Critical Instructions
- Return ONLY the raw JSON object
- Do NOT include markdown code fences
- Do NOT include explanations
```

## Execution with fabric raw_query

Once you have an improved prompt, use `raw_query`:

```bash
(cat improved_prompt.txt; echo ""; echo "## Input:"; cat data.txt) | \
  fabric -p raw_query -m claude-3-5-haiku-latest -o output.txt
```

### Why raw_query?

- Treats your prompt as-is
- No pattern-specific modifications
- Direct model interaction
- Full control over prompt structure

## Common Patterns

### Pattern 1: Data Analysis

```
You are analyzing [TYPE OF DATA].

Given the input below, [ANALYSIS TASK].

Generate a JSON object with:
{
  "findings": ["<finding1>", "<finding2>"],
  "confidence": "<low|medium|high>",
  "recommendations": ["<rec1>", "<rec2>"]
}

Return ONLY the JSON object.
```

### Pattern 2: Classification

```
Classify the following [ITEMS] into categories.

Return JSON:
{
  "categories": {
    "category1": ["<item1>", "<item2>"],
    "category2": ["<item3>"]
  },
  "uncategorized": []
}

Return ONLY the JSON object.
```

### Pattern 3: Extraction

```
Extract [ENTITIES] from the text below.

Return JSON:
{
  "entities": [
    {
      "type": "<entity_type>",
      "value": "<entity_value>",
      "context": "<surrounding_context>"
    }
  ]
}

Return ONLY the JSON object.
```

## Model Selection

Different models for different needs:

| Model | Use When | Cost | Speed |
|-------|----------|------|-------|
| haiku | Simple extraction, low token count | Low | Fast |
| sonnet | Complex analysis, detailed output | Medium | Medium |
| opus | Critical accuracy, nuanced understanding | High | Slow |

For structured output:
- **haiku** - Sufficient for most cases
- **sonnet** - When prompt is complex or output needs detail

## Validation Strategy

Always validate the output:

```bash
# Extract JSON
output=$(fabric -p raw_query < input.txt)
json=$(echo "$output" | sed -n '/^{/,/^}/p')

# Validate
if echo "$json" | jq '.' >/dev/null 2>&1; then
  echo "Valid JSON"
  # Process
else
  echo "Invalid JSON, retry or adjust prompt"
fi
```

## Iterative Improvement

If output isn't clean:

1. Check if prompt explicitly says "ONLY JSON"
2. Add "No markdown code fences" instruction
3. Provide more specific field requirements
4. Use `improve_prompt` to enhance clarity
5. Test with different models

## Example Workflow

Complete example:

```bash
#!/bin/bash

# 1. Create base prompt
cat > base_prompt.txt << 'EOF'
Analyze these log entries and return JSON with:
- error_count: number of errors
- warnings: array of warning messages
- severity: overall severity level

Return ONLY JSON.
EOF

# 2. Improve prompt
cat base_prompt.txt | fabric -p improve_prompt -o improved.txt

# 3. Combine with data
(cat improved.txt; echo ""; echo "## Logs:"; cat logs.txt) > full_input.txt

# 4. Execute
fabric -p raw_query -m claude-3-5-haiku-latest -o output.txt < full_input.txt

# 5. Extract JSON
sed -n '/^{/,/^}/p' output.txt > result.json

# 6. Validate and use
if jq '.' result.json >/dev/null 2>&1; then
  error_count=$(jq -r '.error_count' result.json)
  echo "Errors found: $error_count"
fi
```

## Tips

- **Test incrementally**: Start simple, add complexity
- **Use examples**: Show desired output format in prompt
- **Be specific**: Vague prompts = inconsistent output
- **Validate always**: Never assume JSON is clean
- **Document fields**: Requirements prevent ambiguity
