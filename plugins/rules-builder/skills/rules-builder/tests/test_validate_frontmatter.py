#!/usr/bin/env python3
"""
Test suite for validate_frontmatter.py

Run with: pytest tests/test_validate_frontmatter.py -v
"""

import sys
from pathlib import Path

import pytest

# Add scripts directory to path
TESTS_DIR = Path(__file__).parent
SCRIPTS_DIR = TESTS_DIR.parent / "scripts"
sys.path.insert(0, str(SCRIPTS_DIR))

from validate_frontmatter import (
    load_schema,
    extract_frontmatter,
    parse_frontmatter,
    validate_frontmatter,
    validate_file,
)

FIXTURES_DIR = TESTS_DIR / "fixtures"
VALID_DIR = FIXTURES_DIR / "valid"
INVALID_DIR = FIXTURES_DIR / "invalid"


@pytest.fixture
def schema():
    """Load the JSON schema once for all tests."""
    return load_schema()


class TestExtractFrontmatter:
    """Tests for frontmatter extraction."""

    def test_extracts_simple_frontmatter(self):
        content = '---\npaths: "**/*.ts"\n---\n\n# Title'
        fm, line = extract_frontmatter(content)
        assert fm == 'paths: "**/*.ts"'
        assert line == 1

    def test_returns_none_for_no_frontmatter(self):
        content = "# Title\n\nNo frontmatter here."
        fm, line = extract_frontmatter(content)
        assert fm is None
        assert line is None

    def test_handles_empty_frontmatter(self):
        content = "---\n---\n\n# Title"
        fm, line = extract_frontmatter(content)
        assert fm == ""
        assert line == 1


class TestParseFrontmatter:
    """Tests for YAML parsing."""

    def test_parses_simple_yaml(self):
        data = parse_frontmatter('paths: "**/*.ts"')
        assert data == {"paths": "**/*.ts"}

    def test_parses_array_paths(self):
        data = parse_frontmatter('paths:\n  - "src/**/*.ts"\n  - "lib/**/*.ts"')
        assert data == {"paths": ["src/**/*.ts", "lib/**/*.ts"]}

    def test_parses_all_fields(self):
        yaml_str = """paths: "**/*.ts"
description: "Test rules"
priority: 75
enabled: true"""
        data = parse_frontmatter(yaml_str)
        assert data["paths"] == "**/*.ts"
        assert data["description"] == "Test rules"
        assert data["priority"] == 75
        assert data["enabled"] is True

    def test_returns_empty_dict_for_empty_string(self):
        assert parse_frontmatter("") == {}
        assert parse_frontmatter("   ") == {}


# =============================================================================
# HAPPY PATH TESTS - Valid Fixtures
# =============================================================================

class TestValidGlobalRules:
    """Test valid global rules (no paths restriction)."""

    def test_no_frontmatter(self, schema):
        file_path = VALID_DIR / "global" / "no-frontmatter.md"
        is_valid, messages = validate_file(file_path, schema)
        assert is_valid, f"Should be valid: {messages}"

    def test_empty_frontmatter(self, schema):
        file_path = VALID_DIR / "global" / "empty-frontmatter.md"
        is_valid, messages = validate_file(file_path, schema)
        assert is_valid, f"Should be valid: {messages}"


class TestValidPathsString:
    """Test valid paths as string."""

    def test_simple_glob(self, schema):
        file_path = VALID_DIR / "paths-string" / "simple-glob.md"
        is_valid, messages = validate_file(file_path, schema)
        assert is_valid, f"Should be valid: {messages}"

    def test_directory_glob(self, schema):
        file_path = VALID_DIR / "paths-string" / "directory-glob.md"
        is_valid, messages = validate_file(file_path, schema)
        assert is_valid, f"Should be valid: {messages}"

    def test_brace_expansion(self, schema):
        file_path = VALID_DIR / "paths-string" / "brace-expansion.md"
        is_valid, messages = validate_file(file_path, schema)
        assert is_valid, f"Should be valid: {messages}"

    def test_multiple_patterns(self, schema):
        file_path = VALID_DIR / "paths-string" / "multiple-patterns.md"
        is_valid, messages = validate_file(file_path, schema)
        assert is_valid, f"Should be valid: {messages}"


class TestValidPathsArray:
    """Test valid paths as array."""

    def test_simple_array(self, schema):
        file_path = VALID_DIR / "paths-array" / "simple-array.md"
        is_valid, messages = validate_file(file_path, schema)
        assert is_valid, f"Should be valid: {messages}"

    def test_mixed_patterns(self, schema):
        file_path = VALID_DIR / "paths-array" / "mixed-patterns.md"
        is_valid, messages = validate_file(file_path, schema)
        assert is_valid, f"Should be valid: {messages}"


class TestValidAllFields:
    """Test valid frontmatter with all fields."""

    def test_complete_frontmatter(self, schema):
        file_path = VALID_DIR / "all-fields" / "complete.md"
        is_valid, messages = validate_file(file_path, schema)
        assert is_valid, f"Should be valid: {messages}"


class TestValidOptionalFields:
    """Test valid frontmatter with optional fields."""

    def test_with_description(self, schema):
        file_path = VALID_DIR / "optional-fields" / "with-description.md"
        is_valid, messages = validate_file(file_path, schema)
        assert is_valid, f"Should be valid: {messages}"

    def test_with_priority(self, schema):
        file_path = VALID_DIR / "optional-fields" / "with-priority.md"
        is_valid, messages = validate_file(file_path, schema)
        assert is_valid, f"Should be valid: {messages}"

    def test_disabled_rule(self, schema):
        file_path = VALID_DIR / "optional-fields" / "disabled.md"
        is_valid, messages = validate_file(file_path, schema)
        assert is_valid, f"Should be valid: {messages}"


# =============================================================================
# EDGE CASE TESTS - Invalid Fixtures
# =============================================================================

class TestInvalidUnknownFields:
    """Test rejection of unknown fields."""

    def test_extra_field(self, schema):
        file_path = INVALID_DIR / "unknown-fields" / "extra-field.md"
        is_valid, messages = validate_file(file_path, schema)
        assert not is_valid, "Should be invalid: unknown field"

    def test_multiple_unknown(self, schema):
        file_path = INVALID_DIR / "unknown-fields" / "multiple-unknown.md"
        is_valid, messages = validate_file(file_path, schema)
        assert not is_valid, "Should be invalid: multiple unknown fields"


class TestInvalidWrongTypes:
    """Test rejection of wrong types."""

    def test_paths_number(self, schema):
        file_path = INVALID_DIR / "wrong-types" / "paths-number.md"
        is_valid, messages = validate_file(file_path, schema)
        assert not is_valid, "Should be invalid: paths as number"

    def test_paths_object(self, schema):
        file_path = INVALID_DIR / "wrong-types" / "paths-object.md"
        is_valid, messages = validate_file(file_path, schema)
        assert not is_valid, "Should be invalid: paths as object"

    def test_priority_string(self, schema):
        file_path = INVALID_DIR / "wrong-types" / "priority-string.md"
        is_valid, messages = validate_file(file_path, schema)
        assert not is_valid, "Should be invalid: priority as string"

    def test_enabled_string(self, schema):
        file_path = INVALID_DIR / "wrong-types" / "enabled-string.md"
        is_valid, messages = validate_file(file_path, schema)
        assert not is_valid, "Should be invalid: enabled as string"

    def test_description_number(self, schema):
        file_path = INVALID_DIR / "wrong-types" / "description-number.md"
        is_valid, messages = validate_file(file_path, schema)
        assert not is_valid, "Should be invalid: description as number"


class TestInvalidValues:
    """Test rejection of invalid values."""

    def test_priority_negative(self, schema):
        file_path = INVALID_DIR / "invalid-values" / "priority-negative.md"
        is_valid, messages = validate_file(file_path, schema)
        assert not is_valid, "Should be invalid: negative priority"

    def test_priority_too_high(self, schema):
        file_path = INVALID_DIR / "invalid-values" / "priority-too-high.md"
        is_valid, messages = validate_file(file_path, schema)
        assert not is_valid, "Should be invalid: priority > 100"

    def test_description_too_long(self, schema):
        file_path = INVALID_DIR / "invalid-values" / "description-too-long.md"
        is_valid, messages = validate_file(file_path, schema)
        assert not is_valid, "Should be invalid: description > 200 chars"


class TestMalformedYaml:
    """Test handling of malformed YAML."""

    def test_unclosed_quote(self, schema):
        file_path = INVALID_DIR / "malformed-yaml" / "unclosed-quote.md"
        is_valid, messages = validate_file(file_path, schema)
        assert not is_valid, "Should be invalid: unclosed quote"

    def test_bad_indentation(self, schema):
        file_path = INVALID_DIR / "malformed-yaml" / "bad-indentation.md"
        is_valid, messages = validate_file(file_path, schema)
        assert not is_valid, "Should be invalid: bad indentation"


# =============================================================================
# UTILITY TESTS
# =============================================================================

class TestSchemaLoading:
    """Test schema loading."""

    def test_schema_loads_successfully(self, schema):
        assert schema is not None
        assert "$schema" in schema
        assert "properties" in schema

    def test_schema_has_paths_property(self, schema):
        assert "paths" in schema["properties"]

    def test_schema_disallows_additional_properties(self, schema):
        assert schema.get("additionalProperties") is False


class TestValidateDirectory:
    """Test directory validation."""

    def test_valid_directory_all_pass(self, schema):
        from validate_frontmatter import validate_directory

        valid, invalid, messages = validate_directory(VALID_DIR, schema)
        assert invalid == 0, f"All valid fixtures should pass: {messages}"
        assert valid > 0, "Should find valid files"

    def test_invalid_directory_all_fail(self, schema):
        from validate_frontmatter import validate_directory

        valid, invalid, messages = validate_directory(INVALID_DIR, schema)
        assert invalid > 0, "Should find invalid files"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
