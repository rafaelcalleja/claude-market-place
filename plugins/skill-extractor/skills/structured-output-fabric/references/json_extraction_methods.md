# JSON Extraction Methods from LLM Output

This document describes techniques for extracting clean JSON objects from LLM responses that may contain additional text.

## The Problem

LLMs often add explanatory text before or after the requested JSON:

```
I'll provide the analysis in JSON format:

{
  "result": "data"
}

Let me know if you need anything else!
```

## Solution: sed Pattern Matching

The most reliable method uses `sed` to extract from the first `{` to the last `}`:

```bash
sed -n '/^{/,/^}/p' input.txt
```

### How It Works

- `/^{/` - Matches lines starting with `{`
- `,` - Range operator
- `/^}/` - Matches lines starting with `}`
- `p` - Print matching lines
- `-n` - Suppress default output

### Limitations

This works when:
- The JSON object starts at the beginning of a line
- The JSON object ends at the beginning of a line
- There are no other `{` or `}` at line starts

## Alternative: awk

For more complex scenarios with balanced braces:

```bash
awk '/^{/{flag=1} flag; /^}/{flag=0}' input.txt
```

## Alternative: grep with Perl Regex

Experimental, may not work on all systems:

```bash
grep -oP '\{(?:[^{}]|(?R))*\}' input.txt
```

This uses recursive regex but requires grep with PCRE support.

## Validation

Always validate extracted JSON with `jq`:

```bash
extracted_json | jq '.' >/dev/null 2>&1 && echo "Valid JSON" || echo "Invalid JSON"
```

## Best Practice Workflow

1. Create prompt requesting JSON-only output
2. Execute with fabric
3. Extract JSON with sed
4. Validate with jq
5. Process validated JSON

Example:

```bash
# 1. Create improved prompt
echo "$base_prompt" | fabric -p improve_prompt -o improved.txt

# 2. Execute
cat input.txt improved.txt | fabric -p raw_query -o output.txt

# 3. Extract
sed -n '/^{/,/^}/p' output.txt > clean.json

# 4. Validate
jq '.' clean.json

# 5. Use
result=$(jq -r '.field' clean.json)
```

## Edge Cases

### Multiple JSON Objects

If output contains multiple JSON objects, `sed` returns only the first:

```bash
sed -n '/^{/,/^}/p' input.txt | head -1
```

### Nested Objects

The `/^{/,/^}/` pattern handles nested objects correctly as long as opening/closing braces are at line starts.

### Minified JSON

For minified JSON on a single line:

```bash
grep -o '{.*}' input.txt | head -1
```

### JSON Arrays

For arrays instead of objects:

```bash
sed -n '/^\[/,/^\]/p' input.txt
```

## Related Tools

- **jq** - JSON processor and validator
- **python -m json.tool** - Pretty-print and validate
- **grep** - Pattern matching
- **awk** - Text processing
