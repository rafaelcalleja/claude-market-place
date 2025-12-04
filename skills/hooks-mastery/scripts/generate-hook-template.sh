#!/bin/bash
# Generate hook boilerplate for different event types

set -e

show_usage() {
    cat << EOF
Usage: $(basename "$0") <event-name> <output-file> [--language python|bash]

Generate hook template for Claude Code hooks.

Event Names:
  PreToolUse, PostToolUse, UserPromptSubmit, Stop, SubagentStop,
  SessionStart, SessionEnd, Notification, PreCompact

Examples:
  $(basename "$0") PreToolUse validator.py --language python
  $(basename "$0") SessionStart setup.sh --language bash
  $(basename "$0") UserPromptSubmit enricher.py

EOF
    exit 1
}

generate_python_template() {
    local event=$1
    local output=$2

    cat > "$output" << 'PYTHON_TEMPLATE'
#!/usr/bin/env python3
"""
Claude Code Hook: EVENT_NAME

Description: [Add description here]
"""

import json
import sys
import os

def main():
    # Read hook input from stdin
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"Error parsing input: {e}", file=sys.stderr)
        sys.exit(1)

    # Validate event type
    event_name = input_data.get('hook_event_name')
    if event_name != 'EVENT_NAME':
        print(f"Unexpected event: {event_name}", file=sys.stderr)
        sys.exit(1)

    # TODO: Implement hook logic here

    # Example: Exit code 0 for success
    sys.exit(0)

    # Example: Exit code 2 to block
    # print("Validation failed", file=sys.stderr)
    # sys.exit(2)

    # Example: JSON output for structured control
    # output = {
    #     "decision": "block",
    #     "reason": "Explanation here"
    # }
    # print(json.dumps(output))
    # sys.exit(0)

if __name__ == "__main__":
    main()
PYTHON_TEMPLATE

    sed -i "s/EVENT_NAME/$event/g" "$output"
}

generate_bash_template() {
    local event=$1
    local output=$2

    cat > "$output" << 'BASH_TEMPLATE'
#!/bin/bash
# Claude Code Hook: EVENT_NAME
# Description: [Add description here]

set -e

# Read input from stdin
input=$(cat)

# Parse event name
event_name=$(echo "$input" | jq -r '.hook_event_name')

if [ "$event_name" != "EVENT_NAME" ]; then
    echo "Unexpected event: $event_name" >&2
    exit 1
fi

# TODO: Implement hook logic here

# Example: Success (exit 0)
exit 0

# Example: Block action (exit 2)
# echo "Validation failed" >&2
# exit 2

# Example: JSON output for structured control
# cat << EOF
# {
#   "decision": "block",
#   "reason": "Explanation here"
# }
# EOF
# exit 0
BASH_TEMPLATE

    sed -i "s/EVENT_NAME/$event/g" "$output"
}

# Parse arguments
if [ $# -lt 2 ]; then
    show_usage
fi

EVENT=$1
OUTPUT=$2
LANGUAGE=${3:-python}

# Validate event name
valid_events=("PreToolUse" "PostToolUse" "UserPromptSubmit" "Stop" "SubagentStop" "SessionStart" "SessionEnd" "Notification" "PreCompact" "PermissionRequest")
if [[ ! " ${valid_events[@]} " =~ " ${EVENT} " ]]; then
    echo "Error: Invalid event name: $EVENT"
    echo "Valid events: ${valid_events[*]}"
    exit 1
fi

# Check if output file exists
if [ -f "$OUTPUT" ]; then
    read -p "File $OUTPUT already exists. Overwrite? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

# Generate template based on language
if [[ "$LANGUAGE" == "--language" ]]; then
    LANGUAGE=$4
fi

case $LANGUAGE in
    python)
        generate_python_template "$EVENT" "$OUTPUT"
        chmod +x "$OUTPUT"
        echo "✓ Generated Python hook template: $OUTPUT"
        ;;
    bash)
        generate_bash_template "$EVENT" "$OUTPUT"
        chmod +x "$OUTPUT"
        echo "✓ Generated Bash hook template: $OUTPUT"
        ;;
    *)
        echo "Error: Invalid language: $LANGUAGE"
        echo "Supported languages: python, bash"
        exit 1
        ;;
esac

echo ""
echo "Next steps:"
echo "1. Edit $OUTPUT to implement your hook logic"
echo "2. Test locally: scripts/test-hook-io.py $OUTPUT $EVENT"
echo "3. Add to hooks configuration in settings.json"
