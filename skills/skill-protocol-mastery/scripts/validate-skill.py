#!/usr/bin/env python3
"""
Validate Agent Skill structure and content.

Usage:
    python validate-skill.py /path/to/skill-directory
    python validate-skill.py /path/to/SKILL.md
"""

import re
import sys
import os

# Validation thresholds
MAX_NAME_LENGTH = 64
MAX_DESCRIPTION_LENGTH = 1024
IDEAL_BODY_WORDS = 2000
MAX_BODY_WORDS = 5000
WARNING_BODY_WORDS = 3000

# Patterns
# Strict pattern: lowercase with hyphens only (recommended)
NAME_PATTERN_STRICT = re.compile(r'^[a-z0-9-]+$')
# Lenient pattern: allows spaces and mixed case (Anthropic's actual format)
NAME_PATTERN_LENIENT = re.compile(r'^[a-zA-Z0-9\s-]+$')
RESERVED_WORDS = ['anthropic', 'claude']
SECOND_PERSON_PATTERNS = [
    r'\bYou should\b',
    r'\bYou need\b',
    r'\bYou can\b',
    r'\bYou must\b',
    r'\bYou will\b',
]
FILE_REFERENCE_PATTERN = re.compile(r'\[.*?\]\((.*?\.md)\)')


class ValidationResult:
    def __init__(self):
        self.errors = []
        self.warnings = []
        self.info = []

    def add_error(self, msg):
        self.errors.append("ERROR: " + msg)

    def add_warning(self, msg):
        self.warnings.append("WARNING: " + msg)

    def add_info(self, msg):
        self.info.append("INFO: " + msg)

    def is_valid(self):
        return len(self.errors) == 0

    def print_results(self):
        for msg in self.errors:
            print("  " + msg)
        for msg in self.warnings:
            print("  " + msg)
        for msg in self.info:
            print("  " + msg)

        print()
        if self.is_valid():
            print("RESULT: Skill is valid!")
        else:
            print("RESULT: Skill has %d error(s)" % len(self.errors))


def parse_frontmatter(content):
    """Extract YAML frontmatter and body from SKILL.md."""
    parts = content.split('---')
    if len(parts) < 3:
        return {}, content

    frontmatter_text = parts[1].strip()
    body = '---'.join(parts[2:]).strip()

    # Simple YAML parsing
    frontmatter = {}
    for line in frontmatter_text.split('\n'):
        if ':' in line:
            key, value = line.split(':', 1)
            frontmatter[key.strip()] = value.strip()

    return frontmatter, body


def validate_name(name, result):
    """Validate skill name."""
    if not name:
        result.add_error("Missing 'name' field in frontmatter")
        return

    if len(name) > MAX_NAME_LENGTH:
        result.add_error("Name too long: %d chars (max %d)" % (len(name), MAX_NAME_LENGTH))

    # Check against lenient pattern first (Anthropic's actual format allows spaces)
    if not NAME_PATTERN_LENIENT.match(name):
        result.add_error("Name contains invalid characters: '%s'" % name)
    elif not NAME_PATTERN_STRICT.match(name):
        # Valid but not following strict best practice
        result.add_warning("Name uses spaces/uppercase. Recommended: lowercase with hyphens (e.g., '%s')" %
                          name.lower().replace(' ', '-'))

    for word in RESERVED_WORDS:
        if word in name.lower():
            result.add_warning("Name contains reserved word '%s' - may conflict with official skills" % word)

    if name.lower() in ['helper', 'utils', 'tools', 'data', 'files']:
        result.add_warning("Name is too generic: '%s'" % name)


def validate_description(description, result):
    """Validate skill description."""
    if not description:
        result.add_error("Missing 'description' field in frontmatter")
        return

    if len(description) > MAX_DESCRIPTION_LENGTH:
        result.add_error("Description too long: %d chars (max %d)" % (len(description), MAX_DESCRIPTION_LENGTH))

    # Check third person
    if not description.startswith('This skill should be used when'):
        if description.startswith('Use this skill'):
            result.add_error("Description uses second person. Should start with 'This skill should be used when...'")
        elif description.startswith('Load when') or description.startswith('Provides'):
            result.add_warning("Description should use third person format: 'This skill should be used when...'")

    # Check for trigger phrases
    if '"' not in description:
        result.add_warning("Description should include specific trigger phrases in quotes")


def remove_code_blocks(text):
    """Remove code blocks from text to avoid false positives in examples."""
    # Remove fenced code blocks (```...```)
    text = re.sub(r'```[\s\S]*?```', '', text)
    # Remove inline code (`...`)
    text = re.sub(r'`[^`]+`', '', text)
    return text


def validate_body(body, result):
    """Validate SKILL.md body content."""
    # Count words
    words = len(body.split())
    result.add_info("Body word count: %d" % words)

    if words > MAX_BODY_WORDS:
        result.add_error("Body too long: %d words (max %d). Move content to references/" % (words, MAX_BODY_WORDS))
    elif words > WARNING_BODY_WORDS:
        result.add_warning("Body is long: %d words. Consider moving content to references/" % words)
    elif words < 100:
        result.add_warning("Body is very short: %d words. May need more content." % words)

    # Check writing style (excluding code blocks to avoid false positives in examples)
    body_no_code = remove_code_blocks(body)
    for pattern in SECOND_PERSON_PATTERNS:
        matches = re.findall(pattern, body_no_code, re.IGNORECASE)
        if matches:
            result.add_warning("Body may use second person: found '%s'. Consider using imperative form." % matches[0])


def validate_references(body, skill_dir, result):
    """Check that referenced files exist."""
    references = FILE_REFERENCE_PATTERN.findall(body)

    for ref in references:
        ref_path = os.path.join(skill_dir, ref)
        if not os.path.exists(ref_path):
            result.add_error("Referenced file not found: %s" % ref)
        else:
            result.add_info("Reference found: %s" % ref)


def validate_skill(skill_path):
    """Validate a skill directory or SKILL.md file."""
    result = ValidationResult()

    # Determine skill directory and SKILL.md path
    if os.path.isdir(skill_path):
        skill_dir = skill_path
        skill_md = os.path.join(skill_path, 'SKILL.md')
    else:
        skill_dir = os.path.dirname(skill_path)
        skill_md = skill_path

    # Check SKILL.md exists
    if not os.path.exists(skill_md):
        result.add_error("SKILL.md not found at %s" % skill_md)
        return result

    # Read content
    with open(skill_md, 'r') as f:
        content = f.read()

    # Parse frontmatter
    frontmatter, body = parse_frontmatter(content)

    if not frontmatter:
        result.add_error("No valid YAML frontmatter found (must be between --- markers)")
        return result

    # Validate components
    validate_name(frontmatter.get('name', ''), result)
    validate_description(frontmatter.get('description', ''), result)
    validate_body(body, result)
    validate_references(body, skill_dir, result)

    # Check for common directories
    for dir_name in ['references', 'examples', 'scripts', 'assets']:
        dir_path = os.path.join(skill_dir, dir_name)
        if os.path.isdir(dir_path):
            files = os.listdir(dir_path)
            result.add_info("Found %s/ with %d file(s)" % (dir_name, len(files)))

    return result


def main():
    if len(sys.argv) < 2:
        print("Usage: python validate-skill.py /path/to/skill")
        print()
        print("Validates Agent Skill structure and content.")
        sys.exit(1)

    skill_path = sys.argv[1]

    if not os.path.exists(skill_path):
        print("Error: Path not found: %s" % skill_path)
        sys.exit(1)

    print("Validating: %s" % skill_path)
    print("=" * 50)
    print()

    result = validate_skill(skill_path)
    result.print_results()

    sys.exit(0 if result.is_valid() else 1)


if __name__ == '__main__':
    main()
