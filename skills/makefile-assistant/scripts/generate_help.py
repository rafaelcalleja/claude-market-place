#!/usr/bin/env python3
"""
Generate or update the 'help' target in root Makefile

This script:
1. Scans all .mk files in .claude/makefiles/
2. Extracts all targets with their "When to use" comments
3. Generates a formatted help target
4. Updates or creates root Makefile
"""

import sys
from pathlib import Path
import re


def parse_targets_from_makefile(makefile_path):
    """Parse targets and their descriptions from a .mk file

    Returns: List of tuples (target_name, when_to_use_description)
    """
    if not makefile_path.exists():
        return []

    targets = []
    current_when_to_use = None

    try:
        lines = makefile_path.read_text().splitlines()
    except Exception as e:
        print(f"Warning: Failed to read {makefile_path}: {e}", file=sys.stderr)
        return []

    for line in lines:
        # "When to use" comment
        if line.startswith('# When to use:'):
            current_when_to_use = line.replace('# When to use:', '').strip()

        # Target definition
        elif line and not line[0].isspace() and ':' in line and not line.startswith('#'):
            target_name = line.split(':')[0].strip()

            # Skip special targets
            if target_name.startswith('.') or target_name in ['help']:
                current_when_to_use = None
                continue

            description = current_when_to_use or "No description"
            targets.append((target_name, description))
            current_when_to_use = None

    return targets


def collect_all_targets(makefiles_dir):
    """Collect all targets from all .mk files

    Returns: Dict mapping category -> list of (target, description)
    """
    makefiles_dir = Path(makefiles_dir)
    if not makefiles_dir.exists():
        return {}

    categories = {}

    for mk_file in sorted(makefiles_dir.glob('*.mk')):
        category_name = mk_file.stem.replace('_', ' ').title()
        targets = parse_targets_from_makefile(mk_file)

        if targets:
            categories[category_name] = targets

    return categories


def generate_help_target(categories):
    """Generate the help target content

    Returns: String containing the help target
    """
    if not categories:
        return """help:
\t@echo "No targets available yet"
"""

    lines = ['help:']
    lines.append('\t@echo "Available Makefile targets:"')
    lines.append('\t@echo ""')

    for category, targets in categories.items():
        lines.append(f'\t@echo "{category}:"')

        for target_name, description in targets:
            # Truncate long descriptions
            if len(description) > 60:
                description = description[:57] + "..."

            lines.append(f'\t@echo "  {target_name:20} - {description}"')

        lines.append('\t@echo ""')

    return '\n'.join(lines)


def update_or_create_makefile(project_dir, help_content, makefiles_dir_name='.claude/makefiles'):
    """Update root Makefile with help target and includes

    Creates Makefile if it doesn't exist
    Updates help target if it exists
    Ensures include directives are present
    """
    project_dir = Path(project_dir)
    makefile_path = project_dir / 'Makefile'

    # Check if .claude/makefiles exists
    makefiles_dir = project_dir / makefiles_dir_name
    if not makefiles_dir.exists():
        print(f"Warning: {makefiles_dir} doesn't exist", file=sys.stderr)
        return False

    # Include directive
    include_line = f'include {makefiles_dir_name}/*.mk'

    # Read existing Makefile or create new
    if makefile_path.exists():
        try:
            content = makefile_path.read_text()
        except Exception as e:
            print(f"Error reading Makefile: {e}", file=sys.stderr)
            return False

        # Check if include directive exists
        if include_line not in content:
            content = f'{include_line}\n\n' + content

        # Replace help target if exists
        help_pattern = r'^help:.*?(?=^\S|\Z)'
        if re.search(help_pattern, content, re.MULTILINE | re.DOTALL):
            content = re.sub(help_pattern, help_content, content, flags=re.MULTILINE | re.DOTALL)
        else:
            content += f'\n\n{help_content}\n'

    else:
        # Create new Makefile
        content = f"""{include_line}

.DEFAULT_GOAL := help

{help_content}
"""

    try:
        makefile_path.write_text(content)
        return True
    except Exception as e:
        print(f"Error writing Makefile: {e}", file=sys.stderr)
        return False


def main():
    """Main entry point

    Usage: generate_help.py <project_dir> [makefiles_dir]
    """
    if len(sys.argv) < 2:
        print("Usage: generate_help.py <project_dir> [makefiles_dir]", file=sys.stderr)
        return 1

    project_dir = sys.argv[1]
    makefiles_dir_name = sys.argv[2] if len(sys.argv) > 2 else '.claude/makefiles'

    # Collect all targets
    makefiles_dir = Path(project_dir) / makefiles_dir_name
    categories = collect_all_targets(makefiles_dir)

    # Generate help target
    help_content = generate_help_target(categories)

    # Update Makefile
    if update_or_create_makefile(project_dir, help_content, makefiles_dir_name):
        print(f"✓ Updated help target in {project_dir}/Makefile")
        return 0
    else:
        print("✗ Failed to update Makefile", file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
