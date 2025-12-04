#!/usr/bin/env python3
"""Hook that returns JSON with additional context"""
import json
import sys

input_data = json.load(sys.stdin)

output = {
    "hookSpecificOutput": {
        "hookEventName": "UserPromptSubmit",
        "additionalContext": "Test context added"
    }
}
print(json.dumps(output))
sys.exit(0)
