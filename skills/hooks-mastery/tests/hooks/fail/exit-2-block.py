#!/usr/bin/env python3
"""Hook that exits with code 2 (blocking error)"""
import json
import sys

input_data = json.load(sys.stdin)

print("Validation failed: dangerous operation detected", file=sys.stderr)
sys.exit(2)
