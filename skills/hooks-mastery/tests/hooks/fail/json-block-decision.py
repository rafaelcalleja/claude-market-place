#!/usr/bin/env python3
"""Hook that returns JSON with block decision for Stop hooks"""
import json
import sys

input_data = json.load(sys.stdin)

output = {
    "decision": "block",
    "reason": "Tests not yet run - please execute test suite"
}
print(json.dumps(output))
sys.exit(0)
