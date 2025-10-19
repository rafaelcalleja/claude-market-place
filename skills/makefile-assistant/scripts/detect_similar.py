#!/usr/bin/env python3
"""
Detect similar Makefile targets using fuzzy matching and heuristics

This script:
1. Reads existing Makefile targets from .claude/makefiles/
2. Compares a new command against existing targets
3. Uses fuzzy string matching + command analysis
4. Returns similarity score and matching targets
"""

import sys
import re
from pathlib import Path
from difflib import SequenceMatcher
import json


def normalize_command(command):
    """Normalize command for comparison by removing flags and paths"""
    # Remove common flags
    normalized = re.sub(r'\s+-+\w+', '', command)
    # Remove paths (simple heuristic: strings with /)
    normalized = re.sub(r'\s+[\./][\S]*', '', normalized)
    return normalized.strip()


def get_base_command(command):
    """Extract the base command (first word, ignoring sudo/time/etc)"""
    parts = command.strip().split()
    if not parts:
        return ''

    base = parts[0]
    if base in ['sudo', 'time', 'watch'] and len(parts) > 1:
        base = parts[1]

    return base


def similarity_score(cmd1, cmd2):
    """Calculate similarity score between two commands (0.0 to 1.0)"""
    # Exact match
    if cmd1 == cmd2:
        return 1.0

    # Base command similarity
    base1 = get_base_command(cmd1)
    base2 = get_base_command(cmd2)

    if base1 != base2:
        return 0.0  # Different base commands = not similar

    # Normalized string similarity
    norm1 = normalize_command(cmd1)
    norm2 = normalize_command(cmd2)

    return SequenceMatcher(None, norm1, norm2).ratio()


def parse_makefile_targets(makefile_path):
    """Parse a Makefile and extract targets with their commands

    Returns: List of dicts with {name, command, when_to_use}
    """
    if not makefile_path.exists():
        return []

    targets = []
    current_target = None
    current_command = None
    when_to_use = None

    try:
        lines = makefile_path.read_text().splitlines()
    except Exception as e:
        print(f"Warning: Failed to read {makefile_path}: {e}", file=sys.stderr)
        return []

    for line in lines:
        # Target definition (starts at column 0, ends with :)
        if line and not line[0].isspace() and ':' in line and not line.startswith('#'):
            # Save previous target
            if current_target and current_command:
                targets.append({
                    'name': current_target,
                    'command': current_command,
                    'when_to_use': when_to_use
                })

            current_target = line.split(':')[0].strip()
            current_command = None
            when_to_use = None

        # "When to use" comment
        elif line.startswith('# When to use:'):
            when_to_use = line.replace('# When to use:', '').strip()

        # Command (starts with tab)
        elif line.startswith('\t') and current_target:
            current_command = line.strip()

    # Save last target
    if current_target and current_command:
        targets.append({
            'name': current_target,
            'command': current_command,
            'when_to_use': when_to_use
        })

    return targets


def find_all_makefile_targets(makefiles_dir):
    """Find all targets from all .mk files in .claude/makefiles/

    Returns: List of dicts with {name, command, when_to_use, file}
    """
    makefiles_dir = Path(makefiles_dir)
    if not makefiles_dir.exists():
        return []

    all_targets = []
    for mk_file in makefiles_dir.glob('*.mk'):
        targets = parse_makefile_targets(mk_file)
        for target in targets:
            target['file'] = mk_file.name
            all_targets.append(target)

    return all_targets


def find_similar_targets(command, makefiles_dir, threshold=0.7):
    """Find existing targets similar to the given command

    Args:
        command: Command to check
        makefiles_dir: Path to .claude/makefiles/ directory
        threshold: Similarity threshold (0.0 to 1.0)

    Returns: List of similar targets with similarity scores
    """
    all_targets = find_all_makefile_targets(makefiles_dir)

    similar = []
    for target in all_targets:
        score = similarity_score(command, target['command'])
        if score >= threshold:
            similar.append({
                **target,
                'similarity': score
            })

    # Sort by similarity (highest first)
    similar.sort(key=lambda x: x['similarity'], reverse=True)

    return similar


def main():
    """Main entry point

    Usage: detect_similar.py <command> <makefiles_dir> [threshold]
    """
    if len(sys.argv) < 3:
        print("Usage: detect_similar.py <command> <makefiles_dir> [threshold]", file=sys.stderr)
        return 1

    command = sys.argv[1]
    makefiles_dir = sys.argv[2]
    threshold = float(sys.argv[3]) if len(sys.argv) > 3 else 0.7

    similar = find_similar_targets(command, makefiles_dir, threshold)
    print(json.dumps(similar, indent=2))
    return 0


if __name__ == '__main__':
    sys.exit(main())
