#!/bin/bash
# Check YAML frontmatter in SKILL.md files
#
# Usage:
#   ./check-frontmatter.sh SKILL.md
#   ./check-frontmatter.sh /path/to/skills/

set -e

check_file() {
    local file="$1"
    local errors=0

    echo "Checking: $file"

    # Check file exists
    if [[ ! -f "$file" ]]; then
        echo "  ❌ File not found"
        return 1
    fi

    # Check frontmatter markers
    if ! head -1 "$file" | grep -q "^---$"; then
        echo "  ❌ Missing opening --- marker"
        ((errors++))
    fi

    # Extract frontmatter
    frontmatter=$(sed -n '2,/^---$/p' "$file" | head -n -1)

    # Check name field
    name=$(echo "$frontmatter" | grep "^name:" | sed 's/name:[[:space:]]*//')
    if [[ -z "$name" ]]; then
        echo "  ❌ Missing 'name' field"
        ((errors++))
    else
        # Check name pattern - allow spaces and mixed case (Anthropic format)
        if ! echo "$name" | grep -qE "^[a-zA-Z0-9 -]+$"; then
            echo "  ❌ Name contains invalid characters: $name"
            ((errors++))
        elif ! echo "$name" | grep -qE "^[a-z0-9-]+$"; then
            # Valid but not strict best practice
            recommended=$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
            echo "  ⚠️  Name uses spaces/uppercase. Recommended: $recommended"
            echo "  ✅ Name: $name"
        else
            echo "  ✅ Name: $name"
        fi

        # Check length
        if [[ ${#name} -gt 64 ]]; then
            echo "  ❌ Name too long: ${#name} chars (max 64)"
            ((errors++))
        fi
    fi

    # Check description field
    description=$(echo "$frontmatter" | grep "^description:" | sed 's/description:[[:space:]]*//')
    if [[ -z "$description" ]]; then
        echo "  ❌ Missing 'description' field"
        ((errors++))
    else
        # Check third person
        if echo "$description" | grep -qi "^Use this skill"; then
            echo "  ⚠️  Description should use third person ('This skill should be used when...')"
        elif echo "$description" | grep -qi "^This skill should be used when"; then
            echo "  ✅ Description uses third person"
        else
            echo "  ⚠️  Consider starting description with 'This skill should be used when...'"
        fi

        # Check for trigger phrases
        if echo "$description" | grep -q '"'; then
            echo "  ✅ Description includes trigger phrases"
        else
            echo "  ⚠️  Consider adding trigger phrases in quotes"
        fi

        # Check length
        desc_len=${#description}
        if [[ $desc_len -gt 1024 ]]; then
            echo "  ❌ Description too long: $desc_len chars (max 1024)"
            ((errors++))
        fi
    fi

    # Check for second person in body
    body=$(sed '1,/^---$/d' "$file" | sed '1,/^---$/d')
    if echo "$body" | grep -qiE "You should|You need|You must|You can"; then
        echo "  ⚠️  Body may contain second person language"
    fi

    # Word count
    word_count=$(echo "$body" | wc -w | tr -d ' ')
    echo "  ℹ️  Body word count: $word_count"

    if [[ $word_count -gt 5000 ]]; then
        echo "  ❌ Body too long (>5000 words)"
        ((errors++))
    elif [[ $word_count -gt 3000 ]]; then
        echo "  ⚠️  Body is long (>3000 words), consider moving to references/"
    fi

    if [[ $errors -eq 0 ]]; then
        echo "  ✅ All checks passed"
        return 0
    else
        echo "  ❌ $errors error(s) found"
        return 1
    fi
}

# Main
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 SKILL.md|directory"
    exit 1
fi

target="$1"
exit_code=0

if [[ -d "$target" ]]; then
    # Find all SKILL.md files
    while IFS= read -r -d '' file; do
        echo
        if ! check_file "$file"; then
            exit_code=1
        fi
    done < <(find "$target" -name "SKILL.md" -print0)
else
    check_file "$target" || exit_code=1
fi

echo
if [[ $exit_code -eq 0 ]]; then
    echo "✅ All skills valid!"
else
    echo "❌ Some skills have issues"
fi

exit $exit_code
