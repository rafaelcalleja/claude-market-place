#!/usr/bin/env python3
"""
List all available Claude Code rules from user-level and project directories.

Usage:
    python list_rules.py [project_path]

Examples:
    python list_rules.py                    # Uses current directory as project
    python list_rules.py /path/to/project   # Specify project path

Output:
    Lists rules from:
    - User-level: ~/.claude/rules/
    - Project: <project>/.claude/rules/
"""

import sys
import re
from pathlib import Path
from typing import Dict, List, Optional, Any

try:
    import yaml
except ImportError:
    yaml = None


def get_user_rules_dir() -> Path:
    """Get the user-level rules directory."""
    return Path.home() / ".claude" / "rules"


def get_project_rules_dir(project_path: Path) -> Path:
    """Get the project rules directory."""
    return project_path / ".claude" / "rules"


def extract_frontmatter(content: str) -> Optional[Dict[str, Any]]:
    """Extract and parse YAML frontmatter from markdown content."""
    pattern = r'^---\s*\n(.*?)^---\s*\n'
    match = re.match(pattern, content, re.DOTALL | re.MULTILINE)

    if not match:
        return None

    frontmatter_str = match.group(1).strip()
    if not frontmatter_str:
        return {}

    if yaml:
        try:
            return yaml.safe_load(frontmatter_str) or {}
        except yaml.YAMLError:
            return None
    else:
        # Basic parsing without PyYAML
        data = {}
        for line in frontmatter_str.split('\n'):
            if ':' in line:
                key, value = line.split(':', 1)
                data[key.strip()] = value.strip().strip('"\'')
        return data


def get_rule_info(file_path: Path) -> Dict[str, Any]:
    """Get information about a rule file."""
    info = {
        "path": str(file_path),
        "name": file_path.stem,
        "relative_path": None,
        "paths": None,
        "description": None,
        "priority": 50,
        "enabled": True,
        "scope": "global",
    }

    try:
        content = file_path.read_text(encoding="utf-8")
        frontmatter = extract_frontmatter(content)

        if frontmatter:
            if "paths" in frontmatter:
                info["paths"] = frontmatter["paths"]
                info["scope"] = "path-specific"
            if "description" in frontmatter:
                info["description"] = frontmatter["description"]
            if "priority" in frontmatter:
                info["priority"] = frontmatter["priority"]
            if "enabled" in frontmatter:
                info["enabled"] = frontmatter["enabled"]

        # Extract title from first heading
        title_match = re.search(r'^#\s+(.+)$', content, re.MULTILINE)
        if title_match and not info["description"]:
            info["description"] = title_match.group(1)

    except Exception:
        pass

    return info


def list_rules_in_dir(rules_dir: Path, base_path: Path) -> List[Dict[str, Any]]:
    """List all rule files in a directory recursively."""
    rules = []

    if not rules_dir.exists():
        return rules

    for md_file in sorted(rules_dir.rglob("*.md")):
        info = get_rule_info(md_file)
        info["relative_path"] = str(md_file.relative_to(base_path))
        rules.append(info)

    return rules


def format_rule_entry(rule: Dict[str, Any], index: int) -> str:
    """Format a single rule entry for display."""
    status = "" if rule["enabled"] else " [DISABLED]"
    scope = f"[{rule['scope']}]" if rule["paths"] else "[global]"

    lines = [f"  {index}. {rule['name']}{status}"]
    lines.append(f"     Path: {rule['relative_path']}")

    if rule["description"]:
        desc = rule["description"][:60] + "..." if len(rule["description"]) > 60 else rule["description"]
        lines.append(f"     Description: {desc}")

    if rule["paths"]:
        paths = rule["paths"]
        if isinstance(paths, list):
            paths = ", ".join(paths[:3])
            if len(rule["paths"]) > 3:
                paths += f" (+{len(rule['paths']) - 3} more)"
        lines.append(f"     Paths: {paths}")

    lines.append(f"     Scope: {scope} | Priority: {rule['priority']}")

    return "\n".join(lines)


def main():
    # Determine project path
    if len(sys.argv) > 1:
        project_path = Path(sys.argv[1]).resolve()
    else:
        project_path = Path.cwd()

    user_rules_dir = get_user_rules_dir()
    project_rules_dir = get_project_rules_dir(project_path)

    print("=" * 60)
    print("CLAUDE CODE RULES")
    print("=" * 60)

    # List user-level rules
    print(f"\n[USER-LEVEL] ~/.claude/rules/")
    print("-" * 40)

    if user_rules_dir.exists():
        user_rules = list_rules_in_dir(user_rules_dir, user_rules_dir.parent.parent)
        if user_rules:
            for i, rule in enumerate(user_rules, 1):
                print(format_rule_entry(rule, i))
                print()
        else:
            print("  No rules found.")
    else:
        print("  Directory does not exist.")

    # List project rules
    print(f"\n[PROJECT] {project_path}/.claude/rules/")
    print("-" * 40)

    if project_rules_dir.exists():
        project_rules = list_rules_in_dir(project_rules_dir, project_path)
        if project_rules:
            for i, rule in enumerate(project_rules, 1):
                print(format_rule_entry(rule, i))
                print()
        else:
            print("  No rules found.")
    else:
        print("  Directory does not exist.")

    # Summary
    user_count = len(list_rules_in_dir(user_rules_dir, user_rules_dir)) if user_rules_dir.exists() else 0
    project_count = len(list_rules_in_dir(project_rules_dir, project_path)) if project_rules_dir.exists() else 0

    print("=" * 60)
    print(f"Total: {user_count} user-level, {project_count} project rules")
    print("=" * 60)

    # Return counts for programmatic use
    return {"user": user_count, "project": project_count}


if __name__ == "__main__":
    main()
