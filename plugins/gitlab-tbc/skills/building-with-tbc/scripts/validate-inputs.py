#!/usr/bin/env python3
"""Validate .gitlab-ci.yml inputs against TBC schemas.

This script validates that all component inputs in a .gitlab-ci.yml file
are valid according to the extracted JSON schemas. It helps catch:
- Non-existent inputs (hallucinated by AI or typos)
- Typos with suggestions for correct inputs
- Unknown templates

Usage:
    python3 validate-inputs.py .gitlab-ci.yml
    python3 validate-inputs.py .gitlab-ci.yml --verbose
    python3 validate-inputs.py .gitlab-ci.yml --list-valid aws
"""

import argparse
import json
import re
import sys
from difflib import get_close_matches
from pathlib import Path
from typing import Any

import yaml


SCHEMAS_DIR = Path(__file__).parent.parent / "schemas"


def load_meta(schemas_dir: Path) -> dict:
    """Load _meta.json with template metadata."""
    meta_file = schemas_dir / "_meta.json"
    if meta_file.exists():
        with open(meta_file) as f:
            return json.load(f)
    return {}


def load_schemas_from_dir(schemas_dir: Path) -> dict[str, dict]:
    """Load all JSON schemas and index by project path."""
    schemas = {}

    for schema_file in schemas_dir.glob("*.json"):
        if schema_file.name.startswith("_"):
            continue

        with open(schema_file) as f:
            schema = json.load(f)

        # Index by project path (e.g., "to-be-continuous/aws")
        project = schema.get("description", "")
        if project:
            schemas[project] = schema

            # Also index by template name for convenience
            prefix = schema.get("_meta", {}).get("prefix", "").rstrip("_").lower()
            if prefix:
                schemas[prefix] = schema
                # Also index by to-be-continuous/{prefix} for component path matching
                schemas[f"to-be-continuous/{prefix}"] = schema

    return schemas


def parse_component_string(component_str: str) -> dict | None:
    """Parse a TBC component string into its parts.

    Examples:
        $CI_SERVER_FQDN/to-be-continuous/s3/gitlab-ci-s3@7.2.3
        -> {project: "to-be-continuous/s3", component: "gitlab-ci-s3", version: "7.2.3"}

        $CI_SERVER_FQDN/to-be-continuous/aws/gitlab-ci-aws-oidc@5
        -> {project: "to-be-continuous/aws", component: "gitlab-ci-aws-oidc", version: "5"}
    """
    # Match: to-be-continuous/{project}/{component}@{version}
    match = re.search(r'to-be-continuous/([^/]+)/([^@]+)@(.+)$', component_str)
    if match:
        return {
            "project": f"to-be-continuous/{match.group(1)}",
            "component": match.group(2),
            "version": match.group(3)
        }
    return None


def extract_component_path(component_str: str) -> str | None:
    """Extract project path from component string.

    Examples:
        $CI_SERVER_FQDN/to-be-continuous/aws/aws@7 -> to-be-continuous/aws
        $CI_SERVER_HOST/to-be-continuous/python/python@7 -> to-be-continuous/python
        to-be-continuous/docker/docker@6 -> to-be-continuous/docker
    """
    parsed = parse_component_string(component_str)
    if parsed:
        return parsed["project"]
    return None


def find_template_by_project(meta: dict, project_path: str) -> dict | None:
    """Find template metadata by project path."""
    for template_key, template_data in meta.get("templates", {}).items():
        proj = template_data.get("project", {})
        if isinstance(proj, dict) and proj.get("path") == project_path:
            return template_data
    return None


def validate_inputs(yaml_content: dict, schemas: dict, meta: dict, verbose: bool = False) -> tuple[list, list]:
    """Validate all component inputs against schemas.

    Validates:
    1. Project exists
    2. Component name is valid (base or variant)
    3. Version exists in tags
    4. Inputs are valid

    Returns:
        Tuple of (valid_components, errors)
    """
    errors = []
    valid = []

    includes = yaml_content.get("include", [])
    if not isinstance(includes, list):
        includes = [includes]

    for include in includes:
        if not isinstance(include, dict):
            continue

        if "component" not in include:
            continue

        component_str = include["component"]
        parsed = parse_component_string(component_str)

        if not parsed:
            if verbose:
                print(f"  Skipping non-TBC component: {component_str}")
            continue

        project = parsed["project"]
        component_name = parsed["component"]
        version = parsed["version"]

        # Find template metadata
        template_meta = find_template_by_project(meta, project)

        if not template_meta:
            if verbose:
                print(f"  Warning: No metadata found for: {project}")
            # Continue with schema-only validation
        else:
            # Validate component name
            valid_components = template_meta.get("components", [])
            if valid_components and component_name not in valid_components:
                errors.append({
                    "component": component_str,
                    "project": project,
                    "error_type": "invalid_component",
                    "message": f"Component '{component_name}' not found",
                    "valid_components": valid_components
                })
                continue

            # Validate version
            proj_data = template_meta.get("project", {})
            valid_versions = proj_data.get("tags", [])
            if valid_versions and version not in valid_versions:
                errors.append({
                    "component": component_str,
                    "project": project,
                    "error_type": "invalid_version",
                    "message": f"Version '{version}' not found",
                    "latest_version": proj_data.get("tag", ""),
                    "valid_versions": valid_versions[:10]  # Show first 10
                })
                continue

        # Validate inputs against schema
        if project not in schemas:
            if verbose:
                print(f"  Warning: No schema found for: {project}")
            continue

        schema = schemas[project]
        input_schema = schema.get("properties", {}).get("inputs", {}).get("properties", {})
        valid_inputs = set(input_schema.keys())
        provided_inputs = set(include.get("inputs", {}).keys())

        unknown = provided_inputs - valid_inputs

        if unknown:
            suggestions = {}
            for inp in unknown:
                matches = get_close_matches(inp, valid_inputs, n=1, cutoff=0.6)
                if matches:
                    suggestions[inp] = matches[0]

            errors.append({
                "component": component_str,
                "project": project,
                "error_type": "invalid_inputs",
                "unknown_inputs": sorted(unknown),
                "suggestions": suggestions,
                "valid_inputs": sorted(valid_inputs),
                "meta": schema.get("_meta", {})
            })
        else:
            valid.append({
                "component": component_str,
                "project": project,
                "inputs_count": len(provided_inputs)
            })

    return valid, errors


def print_valid_inputs(template_name: str, schemas: dict, schemas_dir: Path = SCHEMAS_DIR) -> int:
    """List all valid inputs for a template."""
    # Find matching schema
    schema = None
    for key, s in schemas.items():
        if template_name.lower() in key.lower():
            schema = s
            break

    if not schema:
        print(f"Error: No schema found for template '{template_name}'")
        print("\nAvailable templates:")
        for key in sorted(schemas.keys()):
            if key.startswith("to-be-continuous/"):
                print(f"  - {key.split('/')[-1]}")
        return 1

    title = schema.get("title", "Unknown")
    project = schema.get("description", "")
    meta = schema.get("_meta", {})
    inputs = schema.get("properties", {}).get("inputs", {}).get("properties", {})

    print(f"=== {title} ===")
    print(f"Project: {project}")
    print(f"Prefix: {meta.get('prefix', 'N/A')}")
    print(f"Features: {', '.join(meta.get('features', [])) or 'None'}")
    print(f"Variants: {', '.join(meta.get('variants', [])) or 'None'}")
    print()
    print(f"Valid inputs ({len(inputs)}):")

    # Group by category
    base_inputs = []
    feature_inputs = {}
    variant_inputs = {}

    for name, props in inputs.items():
        if "x-feature" in props:
            feature = props["x-feature"]
            if feature not in feature_inputs:
                feature_inputs[feature] = []
            feature_inputs[feature].append((name, props))
        elif "x-variant" in props:
            variant = props["x-variant"]
            if variant not in variant_inputs:
                variant_inputs[variant] = []
            variant_inputs[variant].append((name, props))
        else:
            base_inputs.append((name, props))

    def print_input(name: str, props: dict, indent: str = "  "):
        type_str = props.get("type", "string")
        if "enum" in props:
            type_str = f"enum[{', '.join(props['enum'])}]"
        default = props.get("default", "")
        desc = props.get("description", "")[:60]
        advanced = " (advanced)" if props.get("x-advanced") else ""
        print(f"{indent}- {name}: {type_str}{advanced}")
        if default:
            print(f"{indent}    default: {default}")
        if desc:
            print(f"{indent}    {desc}...")

    print("\n  Base inputs:")
    for name, props in sorted(base_inputs):
        print_input(name, props, "    ")

    for feature, inputs_list in sorted(feature_inputs.items()):
        print(f"\n  Feature: {feature}")
        for name, props in sorted(inputs_list):
            print_input(name, props, "    ")

    for variant, inputs_list in sorted(variant_inputs.items()):
        print(f"\n  Variant: {variant}")
        for name, props in sorted(inputs_list):
            print_input(name, props, "    ")

    return 0


def main():
    parser = argparse.ArgumentParser(
        description='Validate .gitlab-ci.yml inputs against TBC schemas'
    )
    parser.add_argument(
        'file',
        nargs='?',
        help='Path to .gitlab-ci.yml file to validate'
    )
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Show verbose output'
    )
    parser.add_argument(
        '--list-valid', '-l',
        metavar='TEMPLATE',
        help='List all valid inputs for a template (e.g., aws, python, docker)'
    )
    parser.add_argument(
        '--schemas-dir',
        default=str(SCHEMAS_DIR),
        help='Path to schemas directory'
    )
    args = parser.parse_args()

    schemas_dir = Path(args.schemas_dir)

    if not schemas_dir.exists():
        print(f"Error: Schemas directory not found: {schemas_dir}")
        print("Run extract-schemas.py first to generate schemas.")
        return 1

    schemas = load_schemas_from_dir(schemas_dir)
    meta = load_meta(schemas_dir)

    if not schemas:
        print("Error: No schemas loaded. Run extract-schemas.py first.")
        return 1

    # List valid inputs mode
    if args.list_valid:
        return print_valid_inputs(args.list_valid, schemas, schemas_dir)

    # Validate mode
    if not args.file:
        print("Usage: validate-inputs.py <gitlab-ci.yml>")
        print("       validate-inputs.py --list-valid <template>")
        return 1

    yaml_file = Path(args.file)
    if not yaml_file.exists():
        print(f"Error: File not found: {yaml_file}")
        return 1

    with open(yaml_file) as f:
        try:
            content = yaml.safe_load(f)
        except yaml.YAMLError as e:
            print(f"Error: Invalid YAML: {e}")
            return 1

    if not content:
        print("Error: Empty YAML file")
        return 1

    print(f"Validating {yaml_file} against TBC schemas...")
    print()

    valid, errors = validate_inputs(content, schemas, meta, args.verbose)

    # Print valid components
    for v in valid:
        print(f"\u2713 {v['component']}")
        print(f"  All {v['inputs_count']} inputs are valid.\n")

    # Print errors
    for e in errors:
        print(f"\u2717 {e['component']}")
        error_type = e.get("error_type", "unknown")

        if error_type == "invalid_component":
            print(f"  ERROR: {e['message']}")
            print(f"  Valid components for {e['project']}:")
            for comp in e.get('valid_components', []):
                print(f"    - {comp}")
            print()

        elif error_type == "invalid_version":
            print(f"  ERROR: {e['message']}")
            print(f"  Latest version: {e.get('latest_version', 'unknown')}")
            print(f"  Available versions: {', '.join(e.get('valid_versions', []))}")
            print()

        elif error_type == "invalid_inputs":
            print("  ERROR: Unknown inputs found:")
            for inp in e.get('unknown_inputs', []):
                suggestion = e.get('suggestions', {}).get(inp)
                if suggestion:
                    print(f"    - '{inp}' is not valid (did you mean '{suggestion}'?)")
                else:
                    print(f"    - '{inp}' is not valid")
            print()

            # Show some valid inputs
            valid_inputs = e.get('valid_inputs', [])
            print("  Valid inputs (first 10):")
            for inp in valid_inputs[:10]:
                print(f"    - {inp}")
            if len(valid_inputs) > 10:
                print(f"    ... and {len(valid_inputs) - 10} more")
            print()

            meta_info = e.get('meta', {})
            if meta_info.get('features'):
                print(f"  Features: {', '.join(meta_info['features'])}")
            if meta_info.get('variants'):
                print(f"  Variants: {', '.join(meta_info['variants'])}")
            print()

        else:
            print(f"  ERROR: {e.get('message', 'Unknown error')}")
            print()

    # Summary
    print("-" * 50)
    print(f"Summary: {len(valid)} valid, {len(errors)} with errors")

    if errors:
        print("\nTip: Run 'validate-inputs.py --list-valid <template>' to see all valid inputs")
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
