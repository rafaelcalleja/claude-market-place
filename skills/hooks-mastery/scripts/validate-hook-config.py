#!/usr/bin/env python3
"""
Validate Claude Code hooks configuration against JSON schema.

Usage:
    python3 validate-hook-config.py <path-to-settings.json>
    python3 validate-hook-config.py ~/.claude/settings.json
"""

import json
import sys
import os
from pathlib import Path

try:
    import jsonschema
    from jsonschema import validate, ValidationError
except ImportError:
    print("Error: jsonschema module required. Install with: pip install jsonschema")
    sys.exit(1)


def load_schema():
    """Load the hooks JSON schema."""
    script_dir = Path(__file__).parent
    schema_path = script_dir.parent / "assets" / "hooks-schema.json"

    if not schema_path.exists():
        print(f"Error: Schema file not found at {schema_path}")
        sys.exit(1)

    with open(schema_path) as f:
        return json.load(f)


def load_config(config_path):
    """Load the hooks configuration file."""
    config_path = Path(config_path).expanduser()

    if not config_path.exists():
        print(f"Error: Configuration file not found at {config_path}")
        sys.exit(1)

    with open(config_path) as f:
        return json.load(f)


def validate_hooks(config, schema):
    """Validate hooks configuration against schema."""
    if "hooks" not in config:
        print("✓ No hooks configuration found (this is valid)")
        return True

    try:
        validate(instance={"hooks": config["hooks"]}, schema=schema)
        return True
    except ValidationError as e:
        print(f"✗ Validation failed:")
        print(f"  Path: {' -> '.join(str(p) for p in e.path)}")
        print(f"  Error: {e.message}")
        return False


def check_hook_commands(config):
    """Additional validation checks for hook commands."""
    if "hooks" not in config:
        return True

    issues = []
    hooks_section = config["hooks"]

    for event_name, event_configs in hooks_section.items():
        for i, event_config in enumerate(event_configs):
            hooks_list = event_config.get("hooks", [])

            for j, hook in enumerate(hooks_list):
                hook_path = f"{event_name}[{i}].hooks[{j}]"

                # Check command hooks for executable paths
                if hook.get("type") == "command":
                    command = hook.get("command", "")

                    # Check for CLAUDE_PROJECT_DIR usage
                    if "$CLAUDE_PROJECT_DIR" in command:
                        # Validate quoting
                        if '"$CLAUDE_PROJECT_DIR"' not in command and "'$CLAUDE_PROJECT_DIR'" not in command:
                            issues.append(f"{hook_path}: CLAUDE_PROJECT_DIR should be quoted")

                    # Check for suspicious patterns
                    if "rm -rf" in command:
                        issues.append(f"{hook_path}: WARNING - Dangerous command 'rm -rf' detected")

                    if "eval " in command:
                        issues.append(f"{hook_path}: WARNING - 'eval' usage detected (security risk)")

                # Check prompt hooks
                if hook.get("type") == "prompt":
                    prompt = hook.get("prompt", "")

                    if not prompt:
                        issues.append(f"{hook_path}: Empty prompt")

                    # Check for response format instructions
                    if "JSON" not in prompt and "json" not in prompt:
                        issues.append(f"{hook_path}: WARNING - Prompt should specify JSON response format")

    return issues


def check_event_matchers(config):
    """Validate event-specific matcher usage."""
    if "hooks" not in config:
        return []

    issues = []
    hooks_section = config["hooks"]

    # Events that don't support matchers
    no_matcher_events = ["UserPromptSubmit", "Stop", "SubagentStop", "SessionEnd"]

    for event_name, event_configs in hooks_section.items():
        for i, event_config in enumerate(event_configs):
            has_matcher = "matcher" in event_config

            if event_name in no_matcher_events and has_matcher:
                issues.append(f"{event_name}[{i}]: Event does not support matchers")

            # Check for empty matcher (valid, but document it)
            if has_matcher and event_config["matcher"] == "":
                issues.append(f"{event_name}[{i}]: INFO - Empty matcher matches all tools")

    return issues


def main():
    if len(sys.argv) != 2:
        print("Usage: python3 validate-hook-config.py <path-to-settings.json>")
        print("Example: python3 validate-hook-config.py ~/.claude/settings.json")
        sys.exit(1)

    config_path = sys.argv[1]

    print(f"Validating hooks configuration: {config_path}")
    print("=" * 60)

    # Load schema and config
    schema = load_schema()
    config = load_config(config_path)

    # Validate against schema
    print("\n1. Schema Validation")
    print("-" * 60)
    schema_valid = validate_hooks(config, schema)

    if schema_valid:
        print("✓ Configuration matches JSON schema")
    else:
        print("\nValidation failed. Fix schema errors before continuing.")
        sys.exit(1)

    # Check hook commands
    print("\n2. Hook Command Validation")
    print("-" * 60)
    command_issues = check_hook_commands(config)

    if command_issues:
        for issue in command_issues:
            print(f"  {issue}")
    else:
        print("✓ No command issues found")

    # Check event matchers
    print("\n3. Event Matcher Validation")
    print("-" * 60)
    matcher_issues = check_event_matchers(config)

    if matcher_issues:
        for issue in matcher_issues:
            print(f"  {issue}")
    else:
        print("✓ No matcher issues found")

    # Summary
    print("\n" + "=" * 60)
    total_issues = len(command_issues) + len(matcher_issues)

    if total_issues == 0:
        print("✓ All validation checks passed!")
        sys.exit(0)
    else:
        warnings = sum(1 for issue in (command_issues + matcher_issues) if "WARNING" in issue or "INFO" in issue)
        errors = total_issues - warnings

        print(f"Validation complete: {errors} errors, {warnings} warnings")

        if errors > 0:
            sys.exit(1)
        else:
            sys.exit(0)


if __name__ == "__main__":
    main()
