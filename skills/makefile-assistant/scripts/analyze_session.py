#!/usr/bin/env python3
"""
Analyze cchistory and extract new interesting commands

This script:
1. Executes cchistory to get command history
2. Reads last processed line from state file
3. Filters out trivial commands (ls, cd, pwd, etc)
4. Returns list of interesting commands for Makefile targets
"""

import subprocess
import sys
from pathlib import Path
import json

# Commands to ignore (trivial/navigation)
TRIVIAL_COMMANDS = {
    'ls', 'cd', 'pwd', 'echo', 'cat', 'clear', 'history',
    'exit', 'which', 'whereis', 'man', 'help', 'alias'
}

# State file to track last processed line
STATE_FILE = Path.home() / '.claude' / '.makefile-last-line'


def get_last_processed_line():
    """Read the last processed line number from state file"""
    if not STATE_FILE.exists():
        return 0
    try:
        return int(STATE_FILE.read_text().strip())
    except (ValueError, FileNotFoundError):
        return 0


def save_last_processed_line(line_num):
    """Save the last processed line number to state file"""
    STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    STATE_FILE.write_text(str(line_num))


def get_cchistory_commands():
    """Execute cchistory and return list of commands"""
    try:
        result = subprocess.run(['cchistory'], capture_output=True, text=True, timeout=5)
        if result.returncode != 0:
            print(f"Warning: cchistory failed with code {result.returncode}", file=sys.stderr)
            return []
        return result.stdout.strip().split('\n') if result.stdout.strip() else []
    except subprocess.TimeoutExpired:
        print("Warning: cchistory timed out", file=sys.stderr)
        return []
    except FileNotFoundError:
        print("Warning: cchistory command not found. Is it installed?", file=sys.stderr)
        return []


def is_trivial_command(command):
    """Check if command is trivial and should be ignored"""
    if not command or command.isspace():
        return True

    # Extract the base command (first word)
    base_cmd = command.strip().split()[0]

    # Remove common prefixes
    for prefix in ['sudo', 'time', 'watch']:
        if base_cmd == prefix and len(command.strip().split()) > 1:
            base_cmd = command.strip().split()[1]
            break

    return base_cmd in TRIVIAL_COMMANDS


def parse_cchistory_line(line):
    """Parse a cchistory line to extract line number and command

    cchistory format is similar to bash history:
    - Line number, optionally with timestamp
    - Command text

    Returns: (line_number, command) or (None, None) if parsing fails
    """
    line = line.strip()
    if not line:
        return None, None

    # Try to extract line number (first token)
    parts = line.split(None, 1)
    if not parts:
        return None, None

    try:
        line_num = int(parts[0])
        command = parts[1] if len(parts) > 1 else ''
        return line_num, command
    except ValueError:
        # Line doesn't start with a number
        return None, None


def analyze_new_commands():
    """
    Analyze cchistory for new interesting commands

    Returns: List of dicts with {line_num, command}
    """
    last_line = get_last_processed_line()
    all_commands = get_cchistory_commands()

    interesting_commands = []
    max_line_num = last_line

    for line in all_commands:
        line_num, command = parse_cchistory_line(line)

        if line_num is None or line_num <= last_line:
            continue

        max_line_num = max(max_line_num, line_num)

        if not is_trivial_command(command):
            interesting_commands.append({
                'line_num': line_num,
                'command': command
            })

    # Update state file with latest line number
    if max_line_num > last_line:
        save_last_processed_line(max_line_num)

    return interesting_commands


def main():
    """Main entry point - outputs JSON list of interesting commands"""
    commands = analyze_new_commands()
    print(json.dumps(commands, indent=2))
    return 0


if __name__ == '__main__':
    sys.exit(main())
