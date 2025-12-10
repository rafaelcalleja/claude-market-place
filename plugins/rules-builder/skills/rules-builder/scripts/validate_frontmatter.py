#!/usr/bin/env python3
"""
Validate YAML frontmatter in Claude Code rule files against JSON schema.

Usage:
    python validate_frontmatter.py <file.md>
    python validate_frontmatter.py <directory>

Examples:
    python validate_frontmatter.py ~/.claude/rules/code-style.md
    python validate_frontmatter.py .claude/rules/
"""

import sys
import json
import re
from pathlib import Path
from typing import Optional, Tuple, List, Dict, Any

try:
    import yaml
except ImportError:
    print("Error: PyYAML is required. Install with: pip install pyyaml")
    sys.exit(1)

try:
    import jsonschema
    from jsonschema import validate, ValidationError, SchemaError
except ImportError:
    print("Error: jsonschema is required. Install with: pip install jsonschema")
    sys.exit(1)


SCRIPT_DIR = Path(__file__).parent
SCHEMA_PATH = SCRIPT_DIR.parent / "schemas" / "rule-frontmatter.schema.json"


def load_schema() -> Dict[str, Any]:
    """Load the JSON schema for rule frontmatter validation."""
    if not SCHEMA_PATH.exists():
        raise FileNotFoundError(f"Schema not found: {SCHEMA_PATH}")

    with open(SCHEMA_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


def extract_frontmatter(content: str) -> Tuple[Optional[str], Optional[int]]:
    """
    Extract YAML frontmatter from markdown content.

    Returns:
        Tuple of (frontmatter_string, start_line) or (None, None) if not found
    """
    # Pattern handles both empty frontmatter (---\n---) and content
    pattern = r'^---\s*\n(.*?)^---\s*\n'
    match = re.match(pattern, content, re.DOTALL | re.MULTILINE)

    if match:
        return match.group(1).strip(), 1
    return None, None


def parse_frontmatter(frontmatter_str: str) -> Dict[str, Any]:
    """Parse YAML frontmatter string into a dictionary."""
    if not frontmatter_str or not frontmatter_str.strip():
        return {}
    return yaml.safe_load(frontmatter_str) or {}


def validate_frontmatter(data: Dict[str, Any], schema: Dict[str, Any]) -> List[str]:
    """
    Validate frontmatter data against the JSON schema.

    Returns:
        List of validation error messages (empty if valid)
    """
    errors = []

    try:
        validate(instance=data, schema=schema)
    except ValidationError as e:
        path = ".".join(str(p) for p in e.absolute_path) if e.absolute_path else "root"
        errors.append(f"[{path}] {e.message}")
    except SchemaError as e:
        errors.append(f"Schema error: {e.message}")

    return errors


def validate_file(file_path: Path, schema: Dict[str, Any]) -> Tuple[bool, List[str]]:
    """
    Validate a single markdown file.

    Returns:
        Tuple of (is_valid, list_of_messages)
    """
    messages = []

    if not file_path.exists():
        return False, [f"File not found: {file_path}"]

    if not file_path.suffix == ".md":
        return True, [f"Skipping non-markdown file: {file_path}"]

    try:
        content = file_path.read_text(encoding="utf-8")
    except Exception as e:
        return False, [f"Error reading file: {e}"]

    frontmatter_str, _ = extract_frontmatter(content)

    if frontmatter_str is None:
        # No frontmatter is valid (global rule)
        messages.append(f"No frontmatter found (global rule): {file_path}")
        return True, messages

    try:
        data = parse_frontmatter(frontmatter_str)
    except yaml.YAMLError as e:
        return False, [f"YAML parse error: {e}"]

    if not data:
        # Empty frontmatter is valid
        messages.append(f"Empty frontmatter (global rule): {file_path}")
        return True, messages

    errors = validate_frontmatter(data, schema)

    if errors:
        return False, errors

    messages.append(f"Valid: {file_path}")
    if "paths" in data:
        messages.append(f"  Paths: {data['paths']}")

    return True, messages


def validate_directory(dir_path: Path, schema: Dict[str, Any]) -> Tuple[int, int, List[str]]:
    """
    Validate all markdown files in a directory recursively.

    Returns:
        Tuple of (valid_count, invalid_count, all_messages)
    """
    valid = 0
    invalid = 0
    all_messages = []

    for md_file in dir_path.rglob("*.md"):
        is_valid, messages = validate_file(md_file, schema)
        all_messages.extend(messages)

        if is_valid:
            valid += 1
        else:
            invalid += 1

    return valid, invalid, all_messages


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    target = Path(sys.argv[1]).expanduser()

    try:
        schema = load_schema()
    except FileNotFoundError as e:
        print(f"Error: {e}")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error parsing schema: {e}")
        sys.exit(1)

    if target.is_file():
        is_valid, messages = validate_file(target, schema)
        for msg in messages:
            print(msg)
        sys.exit(0 if is_valid else 1)

    elif target.is_dir():
        valid, invalid, messages = validate_directory(target, schema)
        for msg in messages:
            print(msg)
        print(f"\nSummary: {valid} valid, {invalid} invalid")
        sys.exit(0 if invalid == 0 else 1)

    else:
        print(f"Error: Path not found: {target}")
        sys.exit(1)


if __name__ == "__main__":
    main()
