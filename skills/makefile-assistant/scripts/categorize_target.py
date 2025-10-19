#!/usr/bin/env python3
"""
Categorize a command/target into appropriate Makefile category

This script:
1. Analyzes a command to determine its category
2. Maps to .mk filename (testing.mk, docker.mk, etc)
3. Uses keyword matching and heuristics
"""

import sys
import re


# Category mappings: keyword patterns -> .mk file
CATEGORY_PATTERNS = {
    'testing.mk': [
        r'\bpytest\b', r'\bnpm test\b', r'\bcargo test\b', r'\bgo test\b',
        r'\btest\b', r'\bjest\b', r'\bmocha\b', r'\bvitest\b',
        r'\bcoverage\b', r'\b--cov\b'
    ],
    'linting.mk': [
        r'\bpylint\b', r'\bflake8\b', r'\beslint\b', r'\bruff\b',
        r'\blint\b', r'\bblack\b', r'\bisort\b', r'\bprettier\b',
        r'\bformat\b', r'\bmypy\b', r'\btsc\b.*--noEmit'
    ],
    'docker.mk': [
        r'\bdocker\b', r'\bdocker-compose\b', r'\bpodman\b',
        r'\bDockerfile\b', r'\bcontainer\b'
    ],
    'build.mk': [
        r'\bbuild\b', r'\bcompile\b', r'\bmake\b', r'\bgradlew\b',
        r'\bcargo build\b', r'\bnpm run build\b', r'\bnpm build\b',
        r'\bwebpack\b', r'\bvite build\b', r'\btsc\b'
    ],
    'database.mk': [
        r'\bpsql\b', r'\bmysql\b', r'\bsqlite\b', r'\bmongo\b',
        r'\bmigrate\b', r'\balembic\b', r'\bprisma\b',
        r'\bdatabase\b', r'\bdb\b'
    ],
    'deploy.mk': [
        r'\bdeploy\b', r'\brelease\b', r'\bpublish\b',
        r'\bkubectl\b', r'\bhelm\b', r'\bterraform\b',
        r'\bansible\b', r'\bcapistrano\b'
    ],
    'dev.mk': [
        r'\bserve\b', r'\bdev\b', r'\bwatch\b', r'\bhot-reload\b',
        r'\bnpm start\b', r'\bnpm run dev\b', r'\bcargo run\b'
    ],
    'clean.mk': [
        r'\bclean\b', r'\brm -rf\b', r'\bpurge\b',
        r'\bdist\b', r'\b__pycache__\b', r'\bnode_modules\b'
    ]
}


def categorize_command(command):
    """Determine the category for a command

    Returns: filename (e.g., 'testing.mk') or 'misc.mk' if no match
    """
    command_lower = command.lower()

    # Check each category pattern
    for category, patterns in CATEGORY_PATTERNS.items():
        for pattern in patterns:
            if re.search(pattern, command_lower):
                return category

    # Default category for uncategorized commands
    return 'misc.mk'


def suggest_category(command):
    """Suggest a category with confidence score

    Returns: dict with {category, confidence, alternatives}
    """
    command_lower = command.lower()

    scores = {}
    for category, patterns in CATEGORY_PATTERNS.items():
        score = 0
        for pattern in patterns:
            if re.search(pattern, command_lower):
                score += 1
        if score > 0:
            scores[category] = score

    if not scores:
        return {
            'category': 'misc.mk',
            'confidence': 'low',
            'alternatives': []
        }

    # Primary category (highest score)
    primary = max(scores.items(), key=lambda x: x[1])

    # Alternative categories (other matches)
    alternatives = [cat for cat, score in scores.items() if cat != primary[0]]

    confidence = 'high' if primary[1] >= 2 else 'medium'

    return {
        'category': primary[0],
        'confidence': confidence,
        'alternatives': alternatives
    }


def main():
    """Main entry point

    Usage: categorize_target.py <command>
    """
    if len(sys.argv) < 2:
        print("Usage: categorize_target.py <command>", file=sys.stderr)
        return 1

    command = sys.argv[1]

    # Simple mode: just return category
    if '--simple' in sys.argv:
        print(categorize_command(command))
    else:
        # Detailed mode: return JSON with confidence
        import json
        result = suggest_category(command)
        print(json.dumps(result, indent=2))

    return 0


if __name__ == '__main__':
    sys.exit(main())
