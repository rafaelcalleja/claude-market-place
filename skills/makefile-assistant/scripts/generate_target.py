#!/usr/bin/env python3
"""
Generate a Makefile target from a command using template

This script:
1. Takes a command and suggested target name
2. Reads the template file
3. Fills in placeholders
4. Returns formatted Makefile target
"""

import sys
import re
from pathlib import Path


def sanitize_target_name(name):
    """Sanitize target name to be Makefile-safe

    - Lowercase
    - Replace spaces/underscores with hyphens
    - Remove invalid characters
    """
    name = name.lower()
    name = re.sub(r'[\s_]+', '-', name)
    name = re.sub(r'[^a-z0-9-]', '', name)
    return name


def generate_target_name_from_command(command):
    """Auto-generate a target name from command

    Examples:
        "pytest tests/" -> "test"
        "docker build -t app:latest ." -> "docker-build"
        "black . && isort ." -> "format"
    """
    base_cmd = command.strip().split()[0]

    # Common command to target name mappings
    mappings = {
        'pytest': 'test',
        'npm test': 'test',
        'cargo test': 'test',
        'go test': 'test',
        'black': 'format',
        'isort': 'format',
        'prettier': 'format',
        'eslint': 'lint',
        'pylint': 'lint',
        'flake8': 'lint',
        'mypy': 'typecheck',
        'docker build': 'docker-build',
        'docker-compose up': 'up',
        'docker-compose down': 'down',
    }

    # Check for compound commands
    for key, value in mappings.items():
        if command.startswith(key):
            return value

    # Default: use base command
    return sanitize_target_name(base_cmd)


def fill_template(template_path, target_name, command, when_to_use):
    """Fill template placeholders with actual values

    Template placeholders:
        [TODO: target-name]
        [TODO: Description]
        [TODO: command]
    """
    try:
        template = template_path.read_text()
    except Exception as e:
        print(f"Error reading template: {e}", file=sys.stderr)
        return None

    # Replace placeholders
    filled = template.replace('[TODO: target-name]', target_name)
    filled = filled.replace('[TODO: Description]', when_to_use)
    filled = filled.replace('[TODO: command]', command)

    return filled


def generate_target(command, target_name=None, when_to_use=None, template_path=None):
    """Generate a complete Makefile target

    Args:
        command: The command to execute
        target_name: Name of the target (auto-generated if None)
        when_to_use: Description of when to use this target
        template_path: Path to template file

    Returns: Formatted Makefile target as string
    """
    # Auto-generate target name if not provided
    if not target_name:
        target_name = generate_target_name_from_command(command)
    else:
        target_name = sanitize_target_name(target_name)

    # Default when_to_use if not provided
    if not when_to_use:
        when_to_use = f"Run {command}"

    # Use template if provided
    if template_path and Path(template_path).exists():
        return fill_template(Path(template_path), target_name, command, when_to_use)

    # Generate manually if no template
    return f"""# {target_name}
# When to use: {when_to_use}
{target_name}:
\t{command}
"""


def main():
    """Main entry point

    Usage: generate_target.py <command> [target_name] [when_to_use] [template_path]
    """
    if len(sys.argv) < 2:
        print("Usage: generate_target.py <command> [target_name] [when_to_use] [template_path]", file=sys.stderr)
        return 1

    command = sys.argv[1]
    target_name = sys.argv[2] if len(sys.argv) > 2 else None
    when_to_use = sys.argv[3] if len(sys.argv) > 3 else None
    template_path = sys.argv[4] if len(sys.argv) > 4 else None

    target = generate_target(command, target_name, when_to_use, template_path)

    if target:
        print(target)
        return 0
    else:
        return 1


if __name__ == '__main__':
    sys.exit(main())
