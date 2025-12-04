#!/bin/bash
# Create a new Claude Code subagent from template
# Usage: create-subagent.sh <name> <scope>

set -euo pipefail

NAME="${1:-}"
SCOPE="${2:-project}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

error() {
    echo "ERROR: $1" >&2
    exit 1
}

info() {
    echo -e "${GREEN}✓${NC} $1"
}

warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

# Check arguments
if [ -z "$NAME" ]; then
    echo "Usage: $0 <name> [scope]"
    echo ""
    echo "Arguments:"
    echo "  name    Subagent name (lowercase, hyphens only)"
    echo "  scope   Where to create (default: project)"
    echo "          - project: .claude/agents/ (shared with team)"
    echo "          - user: ~/.claude/agents/ (personal)"
    echo ""
    echo "Examples:"
    echo "  $0 code-reviewer project"
    echo "  $0 my-helper user"
    exit 1
fi

# Validate name pattern
if ! echo "$NAME" | grep -qE '^[a-z0-9-]+$'; then
    error "Invalid name: '$NAME' (use lowercase letters, numbers, and hyphens only)"
fi

# Determine target directory
case "$SCOPE" in
    project)
        TARGET_DIR=".claude/agents"
        ;;
    user)
        TARGET_DIR="$HOME/.claude/agents"
        ;;
    *)
        error "Invalid scope: '$SCOPE' (must be 'project' or 'user')"
        ;;
esac

TARGET_FILE="$TARGET_DIR/${NAME}.md"

# Check if file already exists
if [ -f "$TARGET_FILE" ]; then
    error "Subagent already exists: $TARGET_FILE"
fi

# Create directory if needed
mkdir -p "$TARGET_DIR"
info "Created directory: $TARGET_DIR"

# Find template
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_FILE="$SCRIPT_DIR/../assets/template.md"

if [ ! -f "$TEMPLATE_FILE" ]; then
    # Fallback: create basic template inline
    warning "Template file not found, using inline template"

    cat > "$TARGET_FILE" << EOF
---
name: $NAME
description: Clear description of what this subagent does and when to use it. Include specific trigger phrases.
tools: Read, Grep, Glob
model: sonnet
permissionMode: default
---

# ${NAME^}

Brief introduction to the subagent's role and purpose.

## When Invoked

1. First step
2. Second step
3. Third step

## Methodology

- Key principle 1
- Key principle 2
- Key principle 3

## Constraints

- Constraint 1
- Constraint 2

## Output Format

Describe expected output format.

## Examples

Provide concrete examples.
EOF
else
    # Copy from template
    cp "$TEMPLATE_FILE" "$TARGET_FILE"

    # Replace placeholder name
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS sed syntax
        sed -i '' "s/subagent-name/$NAME/g" "$TARGET_FILE"
    else
        # Linux sed syntax
        sed -i "s/subagent-name/$NAME/g" "$TARGET_FILE"
    fi

    info "Created from template"
fi

info "Subagent created: $TARGET_FILE"

# Offer to open in editor
if [ -n "${EDITOR:-}" ]; then
    echo ""
    read -p "Open in editor? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        $EDITOR "$TARGET_FILE"
    fi
fi

echo ""
echo "Next steps:"
echo "  1. Edit the subagent file: $TARGET_FILE"
echo "  2. Customize the description with specific trigger phrases"
echo "  3. Set appropriate tools and permissions"
echo "  4. Write detailed system prompt"
echo "  5. Validate with: scripts/validate-subagent.sh $TARGET_FILE"
echo ""
echo "Testing:"
echo "  - Restart Claude Code to load the new subagent"
echo "  - Try queries that should trigger it"
echo "  - Use /agents to view loaded subagents"
