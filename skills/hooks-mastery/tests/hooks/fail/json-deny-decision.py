#!/usr/bin/env python3
"""Hook that returns JSON with deny decision"""
import json
import sys

input_data = json.load(sys.stdin)

output = {
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": "Command blocked for testing"
    }
}
print(json.dumps(output))
sys.exit(0)
