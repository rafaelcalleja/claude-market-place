# Similarity Detection Algorithm

This document explains how the makefile-assistant skill detects similar commands to avoid duplicate targets.

## Overview

The similarity detection system uses a multi-layered approach:
1. **Base command matching** - Commands must share the same base tool
2. **Fuzzy string matching** - Compare normalized command strings
3. **Heuristic scoring** - Apply domain-specific rules
4. **Threshold filtering** - Only report high-confidence matches

## Base Command Extraction

### Purpose
Filter out completely unrelated commands quickly.

### Algorithm

```python
def get_base_command(command):
    parts = command.strip().split()
    if not parts:
        return ''

    base = parts[0]

    # Skip common prefixes
    if base in ['sudo', 'time', 'watch'] and len(parts) > 1:
        base = parts[1]

    return base
```

### Examples

```
Command: "pytest tests/"
Base: "pytest"

Command: "sudo docker build -t app:latest ."
Base: "docker"

Command: "npm run test -- --coverage"
Base: "npm"
```

### Early Exit

If base commands differ, similarity is 0.0:
```
"pytest tests/" vs "npm test"
→ Different bases → 0.0 similarity
```

## Command Normalization

### Purpose
Remove noise (flags, paths) to compare core functionality.

### Algorithm

```python
def normalize_command(command):
    # Remove flags
    normalized = re.sub(r'\s+-+\w+', '', command)

    # Remove paths
    normalized = re.sub(r'\s+[\./][\S]*', '', normalized)

    return normalized.strip()
```

### Examples

```
Original: "pytest tests/ --cov=src --verbose"
Normalized: "pytest"

Original: "docker build -t myapp:latest ."
Normalized: "docker build"

Original: "npm run test -- --coverage"
Normalized: "npm run test"
```

## Fuzzy String Matching

### Purpose
Calculate similarity between normalized commands.

### Algorithm

Uses Python's `difflib.SequenceMatcher` with Ratcliff/Obershelp algorithm:

```python
from difflib import SequenceMatcher

def fuzzy_match(str1, str2):
    return SequenceMatcher(None, str1, str2).ratio()
```

### Similarity Score

Returns value between 0.0 and 1.0:
- 1.0 = Identical
- 0.8-0.9 = Very similar
- 0.5-0.7 = Somewhat similar
- < 0.5 = Different

### Examples

```python
fuzzy_match("pytest", "pytest")
→ 1.0  # Exact match

fuzzy_match("pytest tests", "pytest tests/unit")
→ 0.82  # Very similar

fuzzy_match("docker build", "docker run")
→ 0.67  # Somewhat similar

fuzzy_match("pytest", "npm test")
→ 0.31  # Different (but already filtered by base command)
```

## Complete Similarity Calculation

### Algorithm

```python
def similarity_score(cmd1, cmd2):
    # Exact match
    if cmd1 == cmd2:
        return 1.0

    # Base command check
    base1 = get_base_command(cmd1)
    base2 = get_base_command(cmd2)

    if base1 != base2:
        return 0.0  # Different tools

    # Normalize and compare
    norm1 = normalize_command(cmd1)
    norm2 = normalize_command(cmd2)

    return fuzzy_match(norm1, norm2)
```

### Examples

```python
similarity_score(
    "pytest tests/",
    "pytest tests/ --cov=src"
)
→ 1.0  # Same after normalization

similarity_score(
    "docker build -t app:dev .",
    "docker build -t app:prod ."
)
→ 1.0  # Flags removed, same command

similarity_score(
    "npm run test",
    "npm run test:unit"
)
→ 0.85  # Very similar

similarity_score(
    "pytest tests/",
    "npm test"
)
→ 0.0  # Different base commands
```

## Threshold Filtering

### Default Threshold

`0.7` (70% similarity)

### Rationale

- **≥ 0.9**: Almost identical (suggest update)
- **0.7-0.9**: Very similar (suggest review)
- **< 0.7**: Different enough to be separate target

### Adjustable

Can be overridden based on context:

```python
# Strict mode (avoid false positives)
find_similar_targets(command, threshold=0.85)

# Relaxed mode (catch more matches)
find_similar_targets(command, threshold=0.6)
```

## Parsing Existing Targets

### Makefile Format

```makefile
# target-name
# When to use: Description here
target-name:
	command here
```

### Extraction Algorithm

```python
def parse_makefile_targets(makefile_path):
    targets = []
    current_target = None
    current_command = None
    when_to_use = None

    for line in lines:
        # Target line (no indent, has :)
        if line and not line[0].isspace() and ':' in line:
            if current_target and current_command:
                targets.append({
                    'name': current_target,
                    'command': current_command,
                    'when_to_use': when_to_use
                })
            current_target = line.split(':')[0].strip()

        # When to use comment
        elif line.startswith('# When to use:'):
            when_to_use = line.replace('# When to use:', '').strip()

        # Command (starts with tab)
        elif line.startswith('\t'):
            current_command = line.strip()

    return targets
```

## Finding Similar Targets

### Complete Workflow

```python
def find_similar_targets(command, makefiles_dir, threshold=0.7):
    # 1. Load all existing targets
    all_targets = find_all_makefile_targets(makefiles_dir)

    # 2. Calculate similarity for each
    similar = []
    for target in all_targets:
        score = similarity_score(command, target['command'])

        # 3. Filter by threshold
        if score >= threshold:
            similar.append({
                **target,
                'similarity': score
            })

    # 4. Sort by similarity (highest first)
    similar.sort(key=lambda x: x['similarity'], reverse=True)

    return similar
```

### Output Format

```json
[
  {
    "name": "test-unit",
    "command": "pytest tests/unit/",
    "when_to_use": "Run unit tests only",
    "file": "testing.mk",
    "similarity": 0.95
  },
  {
    "name": "test",
    "command": "pytest tests/",
    "when_to_use": "Run all tests",
    "file": "testing.mk",
    "similarity": 0.82
  }
]
```

## Decision Logic

### When Similar Targets Found

Based on similarity score:

**0.95-1.0: Almost Identical**
- Action: Suggest updating existing target
- Question: "Target 'test-unit' is very similar. Update it instead?"

**0.8-0.95: Very Similar**
- Action: Suggest variant or consolidation
- Question: "Target 'test' already exists. Create 'test-coverage' variant?"

**0.7-0.8: Similar**
- Action: Inform user, suggest review
- Question: "Similar to 'test'. Create new target or skip?"

**< 0.7: Different**
- Action: Create new target
- No confirmation needed

## Heuristic Improvements

### Future Enhancements

1. **Flag analysis**
   - Detect if only flags differ
   - Suggest consolidating with variables

2. **Path analysis**
   - Detect if only paths differ
   - Suggest parametrized targets

3. **Semantic understanding**
   - "pytest" vs "npm test" are both testing
   - Cross-tool similarity detection

4. **Learning from user decisions**
   - Track which suggestions were accepted/rejected
   - Adjust threshold dynamically

## Examples in Practice

### Example 1: Exact Match After Normalization

```
Existing: "pytest tests/ --cov=src"
New: "pytest tests/ --cov=src --verbose"

Base: pytest == pytest ✓
Normalized: "pytest" == "pytest"
Score: 1.0
Suggestion: Update existing target with verbose flag
```

### Example 2: Variant Detection

```
Existing: "pytest tests/"
New: "pytest tests/unit/"

Base: pytest == pytest ✓
Normalized: "pytest" vs "pytest"
Score: 0.87
Suggestion: Create variant 'test-unit'
```

### Example 3: Different Tools

```
Existing: "pytest tests/"
New: "npm test"

Base: pytest != npm ✓
Score: 0.0
Suggestion: Create new target (no similarity)
```

### Example 4: Docker Variants

```
Existing: "docker build -t app:dev ."
New: "docker build -t app:prod ."

Base: docker == docker ✓
Normalized: "docker build" == "docker build"
Score: 1.0
Suggestion: Parameterize with variable $(ENV)
```

## Performance Considerations

### Time Complexity

- **Base command check**: O(1)
- **Normalization**: O(n) where n = command length
- **Fuzzy matching**: O(n*m) where n,m = string lengths
- **Full scan**: O(t) where t = number of targets

### Optimization Strategies

1. **Early exit on base mismatch**: Saves fuzzy matching
2. **Cache normalized commands**: Avoid re-computation
3. **Index by base command**: Skip irrelevant targets
4. **Limit target scan**: Only check recent N targets

## Testing

### Test Cases

```python
def test_exact_match():
    assert similarity_score("pytest", "pytest") == 1.0

def test_with_flags():
    assert similarity_score("pytest --verbose", "pytest") == 1.0

def test_with_path():
    assert similarity_score("pytest tests/", "pytest") == 1.0

def test_different_base():
    assert similarity_score("pytest", "npm test") == 0.0

def test_similar_targets():
    score = similarity_score("pytest tests/", "pytest tests/unit/")
    assert 0.7 < score < 1.0
```

## Limitations

### Current Limitations

1. **No semantic understanding**: "test" vs "check" not recognized as similar
2. **No cross-tool detection**: pytest vs npm test not linked
3. **Sensitive to order**: "build test" vs "test build" low similarity
4. **Flag-blind**: --verbose vs --quiet treated as identical

### Mitigation Strategies

- Use threshold tuning
- Rely on user confirmation
- Show similar targets even below threshold
- Allow manual override
