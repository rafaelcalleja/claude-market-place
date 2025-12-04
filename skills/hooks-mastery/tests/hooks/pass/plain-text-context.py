#!/usr/bin/env python3
"""Hook that returns plain text context (for UserPromptSubmit/SessionStart)"""
import json
import sys

input_data = json.load(sys.stdin)

print("Current time: 2025-01-15 10:30:00")
print("Git branch: main")
sys.exit(0)
