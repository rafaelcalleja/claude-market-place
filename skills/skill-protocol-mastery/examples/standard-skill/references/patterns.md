# Code Patterns Reference

Common patterns to identify during code analysis.

## Structural Patterns

### Module Organization

**Good patterns:**
- Single responsibility per module
- Clear public/private separation
- Consistent file naming
- Logical directory structure

**Signs of issues:**
- God modules (too many responsibilities)
- Circular dependencies
- Inconsistent naming
- Flat structure with many files

### Import Patterns

**Good patterns:**
```python
# Grouped and ordered imports
import os
import sys

import third_party_lib

from local_module import function
```

**Anti-patterns:**
```python
# Random order, no grouping
from local import thing
import sys
import third_party
import os
```

## Error Handling

### Good Patterns

```python
def process_file(path):
    try:
        with open(path) as f:
            return f.read()
    except FileNotFoundError:
        logger.error(f"File not found: {path}")
        raise
    except PermissionError:
        logger.error(f"Permission denied: {path}")
        raise
```

### Anti-Patterns

```python
def process_file(path):
    try:
        # Bare except catches everything
        return open(path).read()
    except:
        pass  # Silent failure
```

## Naming Conventions

### Variables

| Context | Convention | Example |
|---------|------------|---------|
| Constants | UPPER_SNAKE | `MAX_RETRIES` |
| Variables | lower_snake | `user_count` |
| Classes | PascalCase | `UserManager` |
| Private | _prefix | `_internal_state` |

### Functions

| Type | Convention | Example |
|------|------------|---------|
| Public | lower_snake | `get_user()` |
| Private | _prefix | `_validate()` |
| Boolean | is_/has_ | `is_valid()` |
| Factory | create_ | `create_user()` |

## Documentation Patterns

### Good Docstring

```python
def process_data(data: dict, validate: bool = True) -> Result:
    """Process input data and return results.

    Args:
        data: Dictionary containing input values
        validate: Whether to validate before processing

    Returns:
        Result object with processed data

    Raises:
        ValidationError: If data fails validation
    """
```

### Poor Documentation

```python
def process_data(data, validate=True):
    """Process data."""  # Too vague
```
