#!/usr/bin/env python3
"""
PreToolUse Hook: Bash Command Validator

Validates bash commands before execution to block dangerous operations.
"""

import json
import sys
import re


# Define dangerous patterns
DANGEROUS_PATTERNS = [
    (r'\brm\s+-rf\s+/', "Recursive force delete from root"),
    (r'\bdd\s+if=/dev/', "Direct disk write operation"),
    (r'>\s*/dev/sd', "Output redirection to disk device"),
    (r'\bmkfs\b', "Filesystem creation command"),
    (r'\bformat\b', "Disk format command"),
    (r'\bcurl\s+.+\|\s*bash', "Piping curl output to bash"),
    (r'\bwget\s+.+\|\s*bash', "Piping wget output to bash"),
]

# Suggest better alternatives
IMPROVEMENT_SUGGESTIONS = [
    (r'\bgrep\b', "Consider using 'rg' (ripgrep) for better performance"),
    (r'\bfind\s+\S+\s+-name\b', "Consider using 'rg --files -g pattern'"),
]


def validate_bash_command(command):
    """Validate bash command for dangerous patterns."""
    issues = []

    # Check for dangerous patterns
    for pattern, message in DANGEROUS_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            issues.append({
                "type": "danger",
                "pattern": pattern,
                "message": message
            })

    return issues


def suggest_improvements(command):
    """Suggest improvements for bash commands."""
    suggestions = []

    for pattern, message in IMPROVEMENT_SUGGESTIONS:
        if re.search(pattern, command):
            suggestions.append({
                "pattern": pattern,
                "message": message
            })

    return suggestions


def main():
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"Error parsing input: {e}", file=sys.stderr)
        sys.exit(1)

    # Only validate Bash tool
    tool_name = input_data.get('tool_name')
    if tool_name != 'Bash':
        sys.exit(0)

    # Get command
    tool_input = input_data.get('tool_input', {})
    command = tool_input.get('command', '')

    if not command:
        sys.exit(0)

    # Validate command
    issues = validate_bash_command(command)

    if issues:
        # Block dangerous commands
        error_messages = [issue['message'] for issue in issues]
        print("❌ Dangerous command blocked:", file=sys.stderr)
        for msg in error_messages:
            print(f"  • {msg}", file=sys.stderr)

        sys.exit(2)  # Exit code 2 blocks execution

    # Check for improvements (non-blocking)
    suggestions = suggest_improvements(command)

    if suggestions:
        # Allow but provide feedback
        output = {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "allow",
                "permissionDecisionReason": "Command validated with suggestions"
            },
            "systemMessage": "Suggestions: " + "; ".join(s['message'] for s in suggestions)
        }
        print(json.dumps(output))
        sys.exit(0)

    # Allow command
    output = {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "allow"
        }
    }
    print(json.dumps(output))
    sys.exit(0)


if __name__ == "__main__":
    main()
