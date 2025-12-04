#!/usr/bin/env python3
"""Hook that exits with code 1 (non-blocking error)"""
import json
import sys

input_data = json.load(sys.stdin)

print("Non-critical error occurred", file=sys.stderr)
sys.exit(1)
