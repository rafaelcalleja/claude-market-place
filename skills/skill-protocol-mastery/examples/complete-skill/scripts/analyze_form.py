#!/usr/bin/env python3
"""
Analyze PDF form and extract field information.

Usage:
    python analyze_form.py input.pdf [output.json]

Output:
    JSON object with field names, types, and positions
"""

import json
import sys
from pathlib import Path

def analyze_form(pdf_path: str) -> dict:
    """Extract form fields from PDF.

    Args:
        pdf_path: Path to PDF file

    Returns:
        Dictionary mapping field names to properties
    """
    try:
        import pdfplumber
    except ImportError:
        print("Error: pdfplumber not installed. Run: pip install pdfplumber")
        sys.exit(1)

    fields = {}

    try:
        with pdfplumber.open(pdf_path) as pdf:
            for page_num, page in enumerate(pdf.pages):
                # Extract form widgets if available
                if hasattr(page, 'annots') and page.annots:
                    for annot in page.annots:
                        if annot.get('Subtype') == '/Widget':
                            field_name = annot.get('T', f'field_{len(fields)}')
                            field_type = _get_field_type(annot)

                            fields[field_name] = {
                                'type': field_type,
                                'page': page_num + 1,
                                'x': annot.get('Rect', [0])[0],
                                'y': annot.get('Rect', [0, 0])[1],
                                'width': _get_width(annot),
                                'height': _get_height(annot)
                            }

        print(f"Found {len(fields)} form fields", file=sys.stderr)
        return fields

    except FileNotFoundError:
        print(f"Error: File not found: {pdf_path}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error analyzing PDF: {e}", file=sys.stderr)
        sys.exit(1)


def _get_field_type(annot: dict) -> str:
    """Determine field type from annotation."""
    ft = annot.get('FT', '')
    if ft == '/Tx':
        return 'text'
    elif ft == '/Btn':
        return 'checkbox'
    elif ft == '/Ch':
        return 'dropdown'
    elif ft == '/Sig':
        return 'signature'
    return 'unknown'


def _get_width(annot: dict) -> float:
    """Calculate field width from Rect."""
    rect = annot.get('Rect', [0, 0, 0, 0])
    if len(rect) >= 4:
        return rect[2] - rect[0]
    return 0


def _get_height(annot: dict) -> float:
    """Calculate field height from Rect."""
    rect = annot.get('Rect', [0, 0, 0, 0])
    if len(rect) >= 4:
        return rect[3] - rect[1]
    return 0


def main():
    if len(sys.argv) < 2:
        print("Usage: python analyze_form.py input.pdf [output.json]")
        sys.exit(1)

    pdf_path = sys.argv[1]
    output_path = sys.argv[2] if len(sys.argv) > 2 else None

    fields = analyze_form(pdf_path)

    output = json.dumps(fields, indent=2)

    if output_path:
        Path(output_path).write_text(output)
        print(f"Saved to {output_path}", file=sys.stderr)
    else:
        print(output)


if __name__ == '__main__':
    main()
