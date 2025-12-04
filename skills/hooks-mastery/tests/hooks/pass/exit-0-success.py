#!/usr/bin/env python3
"""Hook that exits with code 0 (success)"""
import json
import sys

input_data = json.load(sys.stdin)
sys.exit(0)
