#!/bin/bash

# UserPromptSubmit hook that forces explicit skill evaluation
# This hook requires Claude to explicitly evaluate each available skill
# before proceeding with implementation.
#
# Protocol: Reads JSON from stdin, outputs JSON with hookSpecificOutput

# Consume stdin
cat > /dev/null

# Output JSON with additionalContext
cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "INSTRUCTION: MANDATORY SKILL ACTIVATION SEQUENCE\n\nStep 1 - EVALUATE (do this in your response):\nFor each skill in <available_skills>, state: [skill-name] - YES/NO - [reason]\n\nStep 2 - ACTIVATE (do this immediately after Step 1):\nIF any skills are YES → Use Skill(skill-name) tool for EACH relevant skill NOW\nIF no skills are YES → State \"No skills needed\" and proceed\n\nStep 3 - IMPLEMENT:\nOnly after Step 2 is complete, proceed with implementation.\n\nCRITICAL: You MUST call Skill() tool in Step 2. Do NOT skip to implementation.\nThe evaluation (Step 1) is WORTHLESS unless you ACTIVATE (Step 2) the skills."
  }
}
EOF
