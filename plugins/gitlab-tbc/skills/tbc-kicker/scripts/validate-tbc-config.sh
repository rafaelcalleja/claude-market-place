#!/bin/bash
# Validate TBC GitLab CI configuration
# Usage: ./validate-tbc-config.sh [gitlab-ci.yml]

set -euo pipefail

CONFIG_FILE="${1:-.gitlab-ci.yml}"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Configuration file not found: $CONFIG_FILE"
    exit 1
fi

echo "Validating TBC configuration: $CONFIG_FILE"
echo "============================================="

# Check for TBC includes
TBC_INCLUDES=$(grep -c "to-be-continuous" "$CONFIG_FILE" 2>/dev/null || echo "0")

if [[ "$TBC_INCLUDES" -eq 0 ]]; then
    echo "Warning: No TBC templates found in configuration"
    exit 0
fi

echo "Found $TBC_INCLUDES TBC template references"
echo ""

# Check include mode
if grep -q "component:" "$CONFIG_FILE"; then
    echo "Include Mode: component (recommended)"
elif grep -q "project:" "$CONFIG_FILE"; then
    echo "Include Mode: project"
elif grep -q "remote:" "$CONFIG_FILE"; then
    echo "Include Mode: remote"
fi

# Extract template versions
echo ""
echo "Templates detected:"
echo "-------------------"

# Component mode
grep -oP '(?<=component: ).*?(?=@)[^"]*@[^"]*' "$CONFIG_FILE" 2>/dev/null | while read -r template; do
    echo "  - $template"
done || true

# Project mode
grep -oP '(?<=project: ")[^"]*' "$CONFIG_FILE" 2>/dev/null | grep "to-be-continuous" | while read -r template; do
    echo "  - $template"
done || true

# Check for common issues
echo ""
echo "Configuration checks:"
echo "---------------------"

# Check for secrets in file
if grep -qE "(TOKEN|PASSWORD|SECRET|KEY):\s*['\"]?[a-zA-Z0-9]" "$CONFIG_FILE"; then
    echo "  [WARNING] Potential hardcoded secrets detected"
    echo "            Move secrets to GitLab CI/CD variables"
else
    echo "  [OK] No hardcoded secrets detected"
fi

# Check for version pinning
if grep -qE "@[0-9]+\.[0-9]+\.[0-9]+" "$CONFIG_FILE"; then
    echo "  [INFO] Using full version pinning (most stable)"
elif grep -qE "@[0-9]+\.[0-9]+" "$CONFIG_FILE"; then
    echo "  [INFO] Using minor version pinning (recommended)"
elif grep -qE "@[0-9]+" "$CONFIG_FILE"; then
    echo "  [INFO] Using major version pinning (receives more updates)"
fi

# Check for YAML syntax
if command -v yamllint &> /dev/null; then
    echo ""
    if yamllint -d relaxed "$CONFIG_FILE" &> /dev/null; then
        echo "  [OK] YAML syntax valid"
    else
        echo "  [WARNING] YAML syntax issues detected"
        yamllint -d relaxed "$CONFIG_FILE" 2>&1 | head -10
    fi
fi

echo ""
echo "Validation complete"
