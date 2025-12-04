#!/usr/bin/env python3
"""
UserPromptSubmit Hook: Context Enricher

Adds contextual information before Claude processes user prompts.
"""

import json
import sys
import datetime
import subprocess
import os


def get_git_info():
    """Get current git branch and status."""
    try:
        branch = subprocess.check_output(
            ['git', 'branch', '--show-current'],
            text=True,
            stderr=subprocess.DEVNULL
        ).strip()

        # Get uncommitted changes count
        status = subprocess.check_output(
            ['git', 'status', '--porcelain'],
            text=True,
            stderr=subprocess.DEVNULL
        )
        uncommitted_count = len([line for line in status.split('\n') if line.strip()])

        # Get last commit
        last_commit = subprocess.check_output(
            ['git', 'log', '-1', '--pretty=format:%h - %s'],
            text=True,
            stderr=subprocess.DEVNULL
        ).strip()

        return {
            'branch': branch,
            'uncommitted': uncommitted_count,
            'last_commit': last_commit
        }
    except:
        return None


def get_environment_info():
    """Get environment information."""
    info = {
        'cwd': os.getcwd(),
        'user': os.getenv('USER', 'unknown'),
        'shell': os.getenv('SHELL', 'unknown')
    }

    # Check for Node.js
    try:
        node_version = subprocess.check_output(
            ['node', '--version'],
            text=True,
            stderr=subprocess.DEVNULL
        ).strip()
        info['node'] = node_version
    except:
        pass

    # Check for Python
    try:
        python_version = subprocess.check_output(
            ['python3', '--version'],
            text=True,
            stderr=subprocess.DEVNULL
        ).strip()
        info['python'] = python_version
    except:
        pass

    return info


def check_for_sensitive_content(prompt):
    """Check if prompt contains potentially sensitive information."""
    sensitive_patterns = [
        'password',
        'api_key',
        'api key',
        'secret',
        'token',
        'credential'
    ]

    lower_prompt = prompt.lower()

    for pattern in sensitive_patterns:
        if pattern in lower_prompt:
            # Check if it's likely defining a variable/discussing concepts vs actual secrets
            if any(marker in lower_prompt for marker in ['=', ':', 'example', 'like', 'such as']):
                return pattern

    return None


def main():
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"Error parsing input: {e}", file=sys.stderr)
        sys.exit(1)

    prompt = input_data.get('prompt', '')

    # Check for sensitive content
    sensitive_match = check_for_sensitive_content(prompt)
    if sensitive_match:
        # Block prompt with sensitive content
        output = {
            "decision": "block",
            "reason": f"Your prompt may contain sensitive information ('{sensitive_match}'). Please rephrase without including actual credentials."
        }
        print(json.dumps(output))
        sys.exit(0)

    # Build context
    context_parts = []

    # Add timestamp
    context_parts.append(f"**Current Time**: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

    # Add git info
    git_info = get_git_info()
    if git_info:
        context_parts.append(f"\n**Git Context**:")
        context_parts.append(f"- Branch: {git_info['branch']}")
        context_parts.append(f"- Last commit: {git_info['last_commit']}")
        if git_info['uncommitted'] > 0:
            context_parts.append(f"- Uncommitted changes: {git_info['uncommitted']} files")

    # Add environment info
    env_info = get_environment_info()
    if env_info:
        context_parts.append(f"\n**Environment**:")
        if 'node' in env_info:
            context_parts.append(f"- Node: {env_info['node']}")
        if 'python' in env_info:
            context_parts.append(f"- Python: {env_info['python']}")

    # Output context as plain text (added to conversation)
    context = '\n'.join(context_parts)
    print(context)

    sys.exit(0)


if __name__ == "__main__":
    main()
