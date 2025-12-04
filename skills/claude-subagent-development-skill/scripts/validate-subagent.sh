#!/bin/bash
# Validate Claude Code subagent configuration
# Usage: validate-subagent.sh <subagent-file> [--check-tools]

set -euo pipefail

SUBAGENT_FILE="${1:-}"
CHECK_TOOLS="${2:-}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track validation errors
ERRORS=0

error() {
    echo -e "${RED}ERROR:${NC} $1"
    ERRORS=$((ERRORS + 1))
}

warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

info() {
    echo "$1"
}

# Check if file provided
if [ -z "$SUBAGENT_FILE" ]; then
    echo "Usage: $0 <subagent-file> [--check-tools]"
    echo ""
    echo "Options:"
    echo "  --check-tools    Also validate tool names against known tools"
    exit 1
fi

# Check if file exists
if [ ! -f "$SUBAGENT_FILE" ]; then
    error "File not found: $SUBAGENT_FILE"
    exit 1
fi

info "Validating subagent: $SUBAGENT_FILE"
echo ""

# Extract YAML frontmatter
extract_frontmatter() {
    awk '/^---$/{if(++count==1)next;if(count==2)exit}count==1' "$SUBAGENT_FILE"
}

# Extract field from YAML
get_yaml_field() {
    local field="$1"
    extract_frontmatter | grep "^${field}:" | sed "s/^${field}:[[:space:]]*//"
}

# Validate YAML frontmatter exists
FRONTMATTER=$(extract_frontmatter)
if [ -z "$FRONTMATTER" ]; then
    error "No YAML frontmatter found (must start and end with ---)"
    exit 1
fi
success "YAML frontmatter found"

# Validate required fields

## name field
NAME=$(get_yaml_field "name")
if [ -z "$NAME" ]; then
    error "Missing required field: name"
else
    # Validate name pattern: lowercase, numbers, hyphens only
    if echo "$NAME" | grep -qE '^[a-z0-9-]+$'; then
        success "name field valid: '$NAME'"
    else
        error "name must contain only lowercase letters, numbers, and hyphens: '$NAME'"
    fi

    # Check length
    NAME_LEN=${#NAME}
    if [ $NAME_LEN -gt 100 ]; then
        error "name exceeds maximum length (100 characters): $NAME_LEN characters"
    fi
fi

## description field
DESCRIPTION=$(get_yaml_field "description")
if [ -z "$DESCRIPTION" ]; then
    error "Missing required field: description"
else
    # Check length
    DESC_LEN=${#DESCRIPTION}
    if [ $DESC_LEN -lt 10 ]; then
        error "description too short (minimum 10 characters): $DESC_LEN characters"
    elif [ $DESC_LEN -gt 2000 ]; then
        error "description too long (maximum 2000 characters): $DESC_LEN characters"
    else
        success "description field valid ($DESC_LEN characters)"
    fi

    # Check for strong triggers
    if echo "$DESCRIPTION" | grep -qiE '(use when|proactively|must be used|when user asks)'; then
        success "description includes trigger phrases"
    else
        warning "description lacks explicit trigger phrases (consider adding 'use when', 'proactively', etc.)"
    fi
fi

# Validate optional fields

## model field
MODEL=$(get_yaml_field "model")
if [ -n "$MODEL" ]; then
    if echo "$MODEL" | grep -qE '^(sonnet|opus|haiku|inherit)$'; then
        success "model field valid: '$MODEL'"
    else
        error "model must be one of: sonnet, opus, haiku, inherit (got: '$MODEL')"
    fi
fi

## permissionMode field
PERMISSION_MODE=$(get_yaml_field "permissionMode")
if [ -n "$PERMISSION_MODE" ]; then
    if echo "$PERMISSION_MODE" | grep -qE '^(default|acceptEdits|bypassPermissions|plan|ignore)$'; then
        success "permissionMode field valid: '$PERMISSION_MODE'"

        # Security warning for bypassPermissions
        if [ "$PERMISSION_MODE" = "bypassPermissions" ]; then
            warning "bypassPermissions mode detected - ensure this is intentional and secure"
        fi
    else
        error "permissionMode must be one of: default, acceptEdits, bypassPermissions, plan, ignore (got: '$PERMISSION_MODE')"
    fi
fi

## tools field (optional validation)
TOOLS=$(get_yaml_field "tools")
if [ -n "$TOOLS" ] && [ "$TOOLS" != "null" ]; then
    # Check tools format (comma-separated)
    if echo "$TOOLS" | grep -qE '^[A-Za-z_][A-Za-z0-9_]*(,[[:space:]]*[A-Za-z_][A-Za-z0-9_]*)*$'; then
        success "tools field format valid"

        # Optionally validate tool names
        if [ "$CHECK_TOOLS" = "--check-tools" ]; then
            KNOWN_TOOLS=(
                "Task" "Bash" "Glob" "Grep" "Read" "Edit" "Write"
                "NotebookEdit" "WebFetch" "WebSearch" "BashOutput"
                "KillShell" "AskUserQuestion" "TodoWrite" "Skill"
                "SlashCommand" "EnterPlanMode" "ExitPlanMode"
                "ListMcpResourcesTool" "ReadMcpResourceTool"
            )

            IFS=',' read -ra TOOL_ARRAY <<< "$TOOLS"
            for tool in "${TOOL_ARRAY[@]}"; then
                tool=$(echo "$tool" | xargs) # trim whitespace

                # Skip MCP tools (format: mcp__server__tool)
                if [[ "$tool" =~ ^mcp__ ]]; then
                    continue
                fi

                # Check if tool is known
                if printf '%s\n' "${KNOWN_TOOLS[@]}" | grep -qx "$tool"; then
                    success "  - $tool (known tool)"
                else
                    warning "  - $tool (unknown tool - may be MCP tool or typo)"
                fi
            done
        fi
    else
        error "tools field has invalid format (should be comma-separated tool names)"
    fi
fi

## skills field
SKILLS=$(get_yaml_field "skills")
if [ -n "$SKILLS" ] && [ "$SKILLS" != "null" ]; then
    # Check skills format (comma-separated lowercase-hyphen names)
    if echo "$SKILLS" | grep -qE '^[a-z0-9-]+(,[[:space:]]*[a-z0-9-]+)*$'; then
        success "skills field format valid"
    else
        error "skills field has invalid format (should be comma-separated skill names)"
    fi
fi

# Validate content (below frontmatter)
CONTENT=$(awk '/^---$/{if(++count==2){flag=1;next}}flag' "$SUBAGENT_FILE")
CONTENT_LEN=${#CONTENT}

if [ -z "$CONTENT" ]; then
    error "Missing content (system prompt) below YAML frontmatter"
elif [ $CONTENT_LEN -lt 50 ]; then
    warning "Content very short ($CONTENT_LEN characters) - consider adding more detailed instructions"
else
    success "Content present ($CONTENT_LEN characters)"
fi

# Check for common mistakes

## Check for uppercase in name
if [ -n "$NAME" ] && echo "$NAME" | grep -q '[A-Z]'; then
    error "name contains uppercase letters (use lowercase only)"
fi

## Check for underscores in name
if [ -n "$NAME" ] && echo "$NAME" | grep -q '_'; then
    error "name contains underscores (use hyphens instead)"
fi

## Check for spaces in name
if [ -n "$NAME" ] && echo "$NAME" | grep -q ' '; then
    error "name contains spaces (use hyphens instead)"
fi

# Summary
echo ""
echo "─────────────────────────────────────────"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ Validation passed${NC}"
    exit 0
else
    echo -e "${RED}✗ Validation failed with $ERRORS error(s)${NC}"
    exit 1
fi
