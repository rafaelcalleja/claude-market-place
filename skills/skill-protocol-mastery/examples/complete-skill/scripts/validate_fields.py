#!/usr/bin/env python3
"""
Validate field mappings for PDF form filling.

Usage:
    python validate_fields.py fields.json

Output:
    "OK" if valid, or list of issues found
"""

import json
import sys
from pathlib import Path

# Valid field types
VALID_TYPES = {'text', 'checkbox', 'dropdown', 'signature', 'unknown'}

# Required properties per type
REQUIRED_PROPS = {
    'text': ['value'],
    'checkbox': ['checked'],
    'dropdown': ['selected'],
    'signature': []  # Optional, may be left empty
}


def validate_fields(fields_path: str) -> list:
    """Validate field mapping file.

    Args:
        fields_path: Path to fields.json

    Returns:
        List of validation errors (empty if valid)
    """
    errors = []

    # Check file exists
    path = Path(fields_path)
    if not path.exists():
        return [f"File not found: {fields_path}"]

    # Parse JSON
    try:
        fields = json.loads(path.read_text())
    except json.JSONDecodeError as e:
        return [f"Invalid JSON: {e}"]

    # Check structure
    if not isinstance(fields, dict):
        return ["Root must be an object"]

    # Validate each field
    for name, props in fields.items():
        if not isinstance(props, dict):
            errors.append(f"Field '{name}': must be an object")
            continue

        # Check type
        field_type = props.get('type')
        if not field_type:
            errors.append(f"Field '{name}': missing 'type'")
        elif field_type not in VALID_TYPES:
            errors.append(f"Field '{name}': invalid type '{field_type}'")
        else:
            # Check required properties for type
            required = REQUIRED_PROPS.get(field_type, [])
            for prop in required:
                if prop not in props:
                    errors.append(f"Field '{name}': missing '{prop}' for type '{field_type}'")

        # Check for conflicting values
        if 'value' in props and props['value'] is None:
            errors.append(f"Field '{name}': 'value' is null (use empty string or remove)")

    return errors


def main():
    if len(sys.argv) < 2:
        print("Usage: python validate_fields.py fields.json")
        sys.exit(1)

    fields_path = sys.argv[1]
    errors = validate_fields(fields_path)

    if not errors:
        print("OK")
        sys.exit(0)
    else:
        print("Validation errors:")
        for error in errors:
            print(f"  - {error}")
        sys.exit(1)


if __name__ == '__main__':
    main()
