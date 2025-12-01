---
description: Validate a TBC configuration against schemas
argument-hint: [yaml-content-or-file-path]
allowed-tools: Bash(python3:*), Bash(mktemp:*), Bash(rm -f /tmp/tbc-validate*), Bash(cat:*)
---

# TBC Validate

Validate the following configuration against TBC JSON schemas:

```
$ARGUMENTS
```

## Execution

1. Write the content above to a temp file
2. Run validation:
   ```bash
   python3 ${CLAUDE_PLUGIN_ROOT}/skills/building-with-tbc/scripts/validate-inputs.py /tmp/tbc-validate.yml
   ```
3. Report the script output
4. Cleanup temp file

## Output

**If valid (exit 0):**
```
✓ TBC Configuration Valid
[Script output]
```

**If errors (exit non-zero):**
```
✗ Validation Errors Found
[Script output]
```
