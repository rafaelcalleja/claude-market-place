#!/bin/bash

# UserPromptSubmit hook that provides simple skill activation instructions
#
# Protocol: Reads JSON from stdin, outputs JSON with hookSpecificOutput

# Consume stdin
cat > /dev/null

# Output JSON with additionalContext
cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "INSTRUCTION: If the prompt matches any available skill keywords, use Skill(skill-name) to activate it."
  }
}
EOF