#!/usr/bin/env python3
"""Extract JSON schemas from kicker-aggregated.json.

This script generates individual JSON schema files for each TBC template,
enabling validation of .gitlab-ci.yml inputs against the real template
variables. This prevents hallucination of non-existent variables.

Usage:
    python3 extract-schemas.py --input /tmp/kicker/src/assets/kicker-aggregated.json --output-dir schemas/
"""

import argparse
import json
import re
from pathlib import Path
from typing import Any


def var_to_input(var_name: str, prefix: str) -> str:
    """Transform variable name to component input name.

    Examples:
        AWS_CLI_IMAGE -> cli-image
        PYTHON_IMAGE -> image
        DOCKER_BUILD_TOOL -> build-tool
    """
    name = var_name
    upper_prefix = prefix.upper() + '_'

    if name.startswith(upper_prefix):
        name = name[len(upper_prefix):]

    return name.lower().replace('_', '-')


def infer_type(var: dict) -> dict:
    """Infer JSON Schema type from variable definition."""
    schema_type: dict[str, Any] = {}

    if var.get('type') == 'enum':
        schema_type['type'] = 'string'
        if var.get('values'):
            schema_type['enum'] = var['values']
    elif var.get('type') == 'boolean':
        schema_type['type'] = 'boolean'
    elif var.get('type') == 'number':
        schema_type['type'] = 'number'
    elif var.get('type') == 'array':
        schema_type['type'] = 'array'
    else:
        # Default to string
        schema_type['type'] = 'string'

    return schema_type


def extract_template_schema(template: dict) -> dict:
    """Extract JSON schema from a single template."""
    prefix = template.get('prefix', '').upper()
    name = template['name']

    # Handle project - it can be a string or a dict with 'path'
    project_data = template.get('project', '')
    if isinstance(project_data, dict):
        project = project_data.get('path', f"to-be-continuous/{template['name'].lower()}")
    else:
        project = project_data or f"to-be-continuous/{template['name'].lower()}"

    # Build properties for all variables
    input_properties = {}

    # Base variables
    for var in template.get('variables', []):
        input_name = var_to_input(var['name'], prefix)
        prop = infer_type(var)

        if var.get('description'):
            # Clean markdown from description
            desc = var['description']
            desc = re.sub(r'\[([^\]]+)\]\([^)]+\)', r'\1', desc)  # Remove links
            desc = re.sub(r'[_*`]', '', desc)  # Remove formatting
            desc = ' '.join(desc.split())  # Normalize whitespace
            prop['description'] = desc[:200]  # Limit length

        if var.get('default') is not None:
            prop['default'] = var['default']

        if var.get('advanced'):
            prop['x-advanced'] = True

        input_properties[input_name] = prop

    # Feature variables
    feature_names = []
    for feature in template.get('features', []):
        feature_names.append(feature['name'])

        for var in feature.get('variables', []):
            input_name = var_to_input(var['name'], prefix)
            prop = infer_type(var)

            if var.get('description'):
                desc = var['description']
                desc = re.sub(r'\[([^\]]+)\]\([^)]+\)', r'\1', desc)
                desc = re.sub(r'[_*`]', '', desc)
                desc = ' '.join(desc.split())
                prop['description'] = desc[:200]

            if var.get('default') is not None:
                prop['default'] = var['default']

            prop['x-feature'] = feature['name']

            input_properties[input_name] = prop

    # Variant variables
    variant_names = []
    for variant in template.get('variants', []):
        variant_names.append(variant['name'])

        for var in variant.get('variables', []):
            input_name = var_to_input(var['name'], prefix)
            prop = infer_type(var)

            if var.get('description'):
                desc = var['description']
                desc = re.sub(r'\[([^\]]+)\]\([^)]+\)', r'\1', desc)
                desc = re.sub(r'[_*`]', '', desc)
                desc = ' '.join(desc.split())
                prop['description'] = desc[:200]

            if var.get('default') is not None:
                prop['default'] = var['default']

            prop['x-variant'] = variant['name']

            input_properties[input_name] = prop

    # Build final schema
    schema = {
        "$schema": "http://json-schema.org/draft-07/schema#",
        "title": f"{name} Template",
        "description": project,
        "type": "object",
        "properties": {
            "inputs": {
                "type": "object",
                "description": f"Valid inputs for {name} template",
                "properties": input_properties,
                "additionalProperties": False  # KEY: Reject unknown inputs
            }
        },
        "_meta": {
            "prefix": prefix + '_' if prefix else '',
            "kind": template.get('kind', ''),
            "is_component": template.get('is_component', False),
            "features": feature_names,
            "variants": variant_names,
            "variable_count": len(input_properties)
        }
    }

    return schema


def extract_component_name(template_path: str) -> str:
    """Extract component name from template_path.

    Examples:
        templates/gitlab-ci-s3.yml -> gitlab-ci-s3
        templates/gitlab-ci-s3-vault.yml -> gitlab-ci-s3-vault
    """
    if not template_path:
        return ''
    # Remove 'templates/' prefix and '.yml' suffix
    name = template_path
    if name.startswith('templates/'):
        name = name[len('templates/'):]
    if name.endswith('.yml'):
        name = name[:-4]
    return name


def get_template_components(template: dict) -> list[str]:
    """Get all valid component names for a template (base + variants)."""
    components = []

    # Base component from template_path
    base_component = extract_component_name(template.get('template_path', ''))
    if base_component:
        components.append(base_component)

    # Variant components
    for variant in template.get('variants', []):
        variant_component = extract_component_name(variant.get('template_path', ''))
        if variant_component:
            components.append(variant_component)

    return components


def main():
    parser = argparse.ArgumentParser(
        description='Extract JSON schemas from kicker-aggregated.json'
    )
    parser.add_argument(
        '--input', '-i',
        default='/tmp/kicker/src/assets/kicker-aggregated.json',
        help='Path to kicker-aggregated.json'
    )
    parser.add_argument(
        '--output-dir', '-o',
        default='schemas/',
        help='Output directory for schemas'
    )
    parser.add_argument(
        '--template', '-t',
        help='Extract only a specific template by name'
    )
    args = parser.parse_args()

    # Load kicker data
    input_path = Path(args.input)
    if not input_path.exists():
        print(f"Error: Input file not found: {input_path}")
        return 1

    with open(input_path) as f:
        data = json.load(f)

    # Create output directory
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    # Extract schemas
    templates = data.get('templates', [])
    meta_info = {
        "generated_from": str(input_path),
        "template_count": 0,
        "templates": {}
    }

    for template in templates:
        name = template['name']

        # Filter if specific template requested
        if args.template and name.lower() != args.template.lower():
            continue

        # Generate schema filename (lowercase, replace spaces)
        filename = name.lower().replace(' ', '-').replace('/', '-')
        filename = re.sub(r'[^a-z0-9-]', '', filename)

        schema = extract_template_schema(template)

        # Write schema
        output_file = output_dir / f"{filename}.json"
        with open(output_file, 'w') as f:
            json.dump(schema, f, indent=2)

        meta_info['template_count'] += 1
        meta_info['templates'][filename] = {
            "name": name,
            "project": template.get('project', ''),
            "variable_count": len(schema['properties']['inputs']['properties']),
            "components": get_template_components(template)
        }

        print(f"  Generated: {output_file.name} ({len(schema['properties']['inputs']['properties'])} inputs)")

    # Write meta file
    meta_file = output_dir / '_meta.json'
    with open(meta_file, 'w') as f:
        json.dump(meta_info, f, indent=2)

    print(f"\nGenerated {meta_info['template_count']} schemas in {output_dir}")
    return 0


if __name__ == '__main__':
    exit(main())
