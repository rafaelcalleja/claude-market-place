#!/bin/bash
# =============================================================================
# Hooks Mastery - Test Suite
# =============================================================================
# Runs all tests for the hooks-mastery skill scripts
#
# Usage: ./tests/run-tests.sh [--verbose]
# =============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"

# Verbose mode
VERBOSE=${1:-""}

log_pass() {
    echo -e "  ${GREEN}✓ PASS${NC}: $1"
    ((TESTS_PASSED++))
}

log_fail() {
    echo -e "  ${RED}✗ FAIL${NC}: $1"
    ((TESTS_FAILED++))
}

log_section() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
}

# =============================================================================
echo ""
echo "╔═══════════════════════════════════════════════════════════════════════════╗"
echo "║               HOOKS MASTERY - TEST SUITE                                  ║"
echo "╚═══════════════════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${YELLOW}[INFO]${NC} Skill directory: $SKILL_DIR"
echo -e "${YELLOW}[INFO]${NC} Tests directory: $SCRIPT_DIR"

# =============================================================================
# Check dependencies
# =============================================================================
log_section "1. Checking Dependencies"

if command -v python3 &> /dev/null; then
    log_pass "python3 found"
else
    log_fail "python3 not found"
    exit 1
fi

if python3 -c "import jsonschema" 2>/dev/null; then
    log_pass "jsonschema module available"
else
    echo -e "  ${YELLOW}Installing jsonschema...${NC}"
    python3 -m pip install jsonschema > /dev/null 2>&1
    log_pass "jsonschema installed"
fi

# =============================================================================
# Test validate-hook-config.py with VALID configs
# =============================================================================
log_section "2. validate-hook-config.py - Valid Configs (should PASS)"

for config in "$SCRIPT_DIR/fixtures/valid"/*.json; do
    filename=$(basename "$config")
    if python3 "$SKILL_DIR/scripts/validate-hook-config.py" "$config" > /tmp/test_out.txt 2>&1; then
        log_pass "$filename"
        [ "$VERBOSE" == "--verbose" ] && cat /tmp/test_out.txt
    else
        log_fail "$filename (should have passed)"
        cat /tmp/test_out.txt
    fi
done

# =============================================================================
# Test validate-hook-config.py with INVALID configs
# =============================================================================
log_section "3. validate-hook-config.py - Invalid Configs (should FAIL)"

for config in "$SCRIPT_DIR/fixtures/invalid"/*.json; do
    filename=$(basename "$config")
    if python3 "$SKILL_DIR/scripts/validate-hook-config.py" "$config" > /tmp/test_out.txt 2>&1; then
        log_fail "$filename (should have failed)"
        cat /tmp/test_out.txt
    else
        log_pass "$filename (correctly rejected)"
        [ "$VERBOSE" == "--verbose" ] && cat /tmp/test_out.txt
    fi
done

# =============================================================================
# Test test-hook-io.py with PASSING hooks
# =============================================================================
log_section "4. test-hook-io.py - Passing Hooks (exit 0)"

for hook in "$SCRIPT_DIR/hooks/pass"/*.py; do
    filename=$(basename "$hook")
    if python3 "$SKILL_DIR/scripts/test-hook-io.py" "$hook" PreToolUse > /tmp/test_out.txt 2>&1; then
        if grep -q "Exit Code: 0" /tmp/test_out.txt; then
            log_pass "$filename"
            [ "$VERBOSE" == "--verbose" ] && cat /tmp/test_out.txt
        else
            log_fail "$filename (wrong exit code)"
            cat /tmp/test_out.txt
        fi
    else
        log_fail "$filename (execution error)"
        cat /tmp/test_out.txt
    fi
done

# =============================================================================
# Test test-hook-io.py with BLOCKING hooks (exit 2)
# =============================================================================
log_section "5. test-hook-io.py - Blocking Hooks (exit 2)"

hook="$SCRIPT_DIR/hooks/fail/exit-2-block.py"
filename=$(basename "$hook")
python3 "$SKILL_DIR/scripts/test-hook-io.py" "$hook" PreToolUse > /tmp/test_out.txt 2>&1
exit_code=$?
if [ $exit_code -eq 2 ] && grep -q "Exit Code: 2" /tmp/test_out.txt; then
    log_pass "$filename (exit code 2)"
    [ "$VERBOSE" == "--verbose" ] && cat /tmp/test_out.txt
else
    log_fail "$filename (expected exit 2, got $exit_code)"
    cat /tmp/test_out.txt
fi

# =============================================================================
# Test test-hook-io.py with NON-BLOCKING errors (exit 1)
# =============================================================================
log_section "6. test-hook-io.py - Non-Blocking Errors (exit 1)"

hook="$SCRIPT_DIR/hooks/fail/exit-1-error.py"
filename=$(basename "$hook")
python3 "$SKILL_DIR/scripts/test-hook-io.py" "$hook" PreToolUse > /tmp/test_out.txt 2>&1
exit_code=$?
if [ $exit_code -eq 1 ] && grep -q "Exit Code: 1" /tmp/test_out.txt; then
    log_pass "$filename (exit code 1)"
    [ "$VERBOSE" == "--verbose" ] && cat /tmp/test_out.txt
else
    log_fail "$filename (expected exit 1, got $exit_code)"
    cat /tmp/test_out.txt
fi

# =============================================================================
# Test test-hook-io.py JSON output detection
# =============================================================================
log_section "7. test-hook-io.py - JSON Output Detection"

for hook in "$SCRIPT_DIR/hooks/pass/json-"*.py; do
    filename=$(basename "$hook")
    if python3 "$SKILL_DIR/scripts/test-hook-io.py" "$hook" PreToolUse > /tmp/test_out.txt 2>&1; then
        if grep -q "Valid JSON output detected" /tmp/test_out.txt; then
            log_pass "$filename (JSON detected)"
            [ "$VERBOSE" == "--verbose" ] && cat /tmp/test_out.txt
        else
            log_fail "$filename (JSON not detected)"
            cat /tmp/test_out.txt
        fi
    else
        log_fail "$filename (execution error)"
        cat /tmp/test_out.txt
    fi
done

# =============================================================================
# Test test-hook-io.py with different event types
# =============================================================================
log_section "8. test-hook-io.py - Different Event Types"

hook="$SCRIPT_DIR/hooks/pass/exit-0-success.py"
for event in PreToolUse PostToolUse Stop SubagentStop SessionStart SessionEnd UserPromptSubmit Notification PreCompact; do
    if python3 "$SKILL_DIR/scripts/test-hook-io.py" "$hook" "$event" > /tmp/test_out.txt 2>&1; then
        if grep -q "Event: $event" /tmp/test_out.txt; then
            log_pass "$event"
            [ "$VERBOSE" == "--verbose" ] && cat /tmp/test_out.txt
        else
            log_fail "$event (event not handled)"
            cat /tmp/test_out.txt
        fi
    else
        log_fail "$event (execution error)"
        cat /tmp/test_out.txt
    fi
done

# =============================================================================
# Test generate-hook-template.sh with Python
# =============================================================================
log_section "9. generate-hook-template.sh - Python Templates"

temp_dir=$(mktemp -d)
for event in PreToolUse PostToolUse Stop SessionStart UserPromptSubmit SessionEnd; do
    output_file="$temp_dir/test-$event.py"
    if bash "$SKILL_DIR/scripts/generate-hook-template.sh" "$event" "$output_file" --language python > /tmp/test_out.txt 2>&1; then
        if [ -f "$output_file" ] && [ -x "$output_file" ] && grep -q "$event" "$output_file"; then
            # Also test the generated template
            if python3 "$SKILL_DIR/scripts/test-hook-io.py" "$output_file" "$event" > /dev/null 2>&1; then
                log_pass "$event (Python template generated and runs)"
            else
                log_fail "$event (template generated but doesn't run)"
            fi
        else
            log_fail "$event (template not created correctly)"
        fi
    else
        log_fail "$event (generation failed)"
        cat /tmp/test_out.txt
    fi
done
rm -rf "$temp_dir"

# =============================================================================
# Test generate-hook-template.sh with Bash
# =============================================================================
log_section "10. generate-hook-template.sh - Bash Templates"

temp_dir=$(mktemp -d)
for event in PreToolUse SessionStart Stop; do
    output_file="$temp_dir/test-$event.sh"
    if bash "$SKILL_DIR/scripts/generate-hook-template.sh" "$event" "$output_file" --language bash > /tmp/test_out.txt 2>&1; then
        if [ -f "$output_file" ] && [ -x "$output_file" ] && grep -q "$event" "$output_file"; then
            # Also test the generated template
            if python3 "$SKILL_DIR/scripts/test-hook-io.py" "$output_file" "$event" > /dev/null 2>&1; then
                log_pass "$event (Bash template generated and runs)"
            else
                log_fail "$event (template generated but doesn't run)"
            fi
        else
            log_fail "$event (template not created correctly)"
        fi
    else
        log_fail "$event (generation failed)"
        cat /tmp/test_out.txt
    fi
done
rm -rf "$temp_dir"

# =============================================================================
# Test generate-hook-template.sh with INVALID event
# =============================================================================
log_section "11. generate-hook-template.sh - Invalid Event Rejection"

temp_dir=$(mktemp -d)
if bash "$SKILL_DIR/scripts/generate-hook-template.sh" "InvalidEvent" "$temp_dir/test.py" --language python > /tmp/test_out.txt 2>&1; then
    log_fail "InvalidEvent (should have been rejected)"
    cat /tmp/test_out.txt
else
    log_pass "InvalidEvent (correctly rejected)"
    [ "$VERBOSE" == "--verbose" ] && cat /tmp/test_out.txt
fi
rm -rf "$temp_dir"

# =============================================================================
# Summary
# =============================================================================
log_section "TEST SUMMARY"

TESTS_TOTAL=$((TESTS_PASSED + TESTS_FAILED))
echo ""
echo -e "  Total Tests:  ${TESTS_TOTAL}"
echo -e "  ${GREEN}Passed:       ${TESTS_PASSED}${NC}"
echo -e "  ${RED}Failed:       ${TESTS_FAILED}${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                     ✓ ALL TESTS PASSED!                                   ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${RED}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                     ✗ SOME TESTS FAILED                                   ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    exit 1
fi
