#!/usr/bin/env python3
"""Hook that returns JSON with allow decision"""
import json
import sys

input_data = json.load(sys.stdin)

output = {
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "allow",
        "permissionDecisionReason": "Test approval"
    }
}
print(json.dumps(output))
sys.exit(0)
