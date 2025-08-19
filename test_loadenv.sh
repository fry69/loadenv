#!/usr/bin/env bash

# Test script for loadenv function
# Exit on any error for safety, but handle test failures gracefully
set -euo pipefail

# Source the loadenv function
# shellcheck disable=SC1091
source ./loadenv.sh

# Global variables for cleanup
TEST_ENV_FILE=""
ORIGINAL_LOADENV_VARS=()
COMPLETION_TEST_FILES=()  # Track completion test files for cleanup

# Test result counters
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
log_test() {
    echo "🧪 Test: $1"
}

log_success() {
    echo "✅ $1"
    ((TESTS_PASSED++))
}

log_failure() {
    echo "❌ $1"
    ((TESTS_FAILED++))
}

assert_equals() {
    local expected="$1"
    local actual="$2"
    local description="$3"

    if [[ "$actual" == "$expected" ]]; then
        log_success "$description"
        return 0
    else
        log_failure "$description - Expected: '$expected', Got: '$actual'"
        return 1
    fi
}

assert_contains() {
    local text="$1"
    local substring="$2"
    local description="$3"

    if [[ "$text" == *"$substring"* ]]; then
        log_success "$description"
        return 0
    else
        log_failure "$description - '$substring' not found in '$text'"
        return 1
    fi
}

# Cleanup function
# shellcheck disable=SC2329  # Function is used via trap
cleanup() {
    echo "🧹 Cleaning up..."

    # Remove test env file if it exists
    if [[ -n "$TEST_ENV_FILE" && -f "$TEST_ENV_FILE" ]]; then
        rm "$TEST_ENV_FILE"
        echo "Removed test file: $TEST_ENV_FILE"
    fi

    # Remove completion test files if they exist
    for test_file in "${COMPLETION_TEST_FILES[@]}"; do
        if [[ -f "$test_file" ]]; then
            rm "$test_file"
            echo "Removed completion test file: $test_file"
        fi
    done

    # Clear any test variables
    loadenv clear >/dev/null 2>&1 || true

    # Restore original LOADENV_VARS if it existed
    if [[ ${#ORIGINAL_LOADENV_VARS[@]} -gt 0 ]]; then
        LOADENV_VARS=("${ORIGINAL_LOADENV_VARS[@]}")
    fi
}

# Set up cleanup trap
trap cleanup EXIT

# Setup test environment
setup_test() {
    echo "🔧 Setting up test environment..."

    # Save current LOADENV_VARS state
    if [[ -n "${LOADENV_VARS[*]:-}" ]]; then
        ORIGINAL_LOADENV_VARS=("${LOADENV_VARS[@]}")
    fi

    # Create unique test file name
    local random_suffix
    random_suffix=$(openssl rand -hex 8 2>/dev/null || date +%s%N | cut -c1-16)
    TEST_ENV_FILE="$HOME/.loadenv/test_${random_suffix}.env"

    # Ensure .loadenv directory exists
    mkdir -p "$HOME/.loadenv"

    # Create test .env file
    cat > "$TEST_ENV_FILE" << 'EOF'
# Test environment file
TEST_VAR1=value1
TEST_VAR2=value2
# This is a comment
TEST_VAR_WITH_SPACES="value with spaces"
EOF

    echo "Created test file: $TEST_ENV_FILE"
}

# Test shell completion functionality
test_completion() {
    log_test "Testing shell completion functionality"

    # Generate unique filenames for completion testing
    local random_suffix1 random_suffix2
    random_suffix1=$(openssl rand -hex 6 2>/dev/null || date +%s%N | cut -c1-12)
    random_suffix2=$(openssl rand -hex 6 2>/dev/null || date +%s%N | cut -c1-12)

    local test_file1="$HOME/.loadenv/completion_${random_suffix1}.env"
    local test_file2="$HOME/.loadenv/completion_${random_suffix2}.env"

    # Track files for cleanup
    COMPLETION_TEST_FILES=("$test_file1" "$test_file2")

    # Create test environment files
    echo "TEST_VAR=value1" > "$test_file1"
    echo "TEST_VAR=value2" > "$test_file2"

    # Extract just the filenames (without path and extension) for expected completion
    local file1_base file2_base
    file1_base=$(basename "$test_file1" .env)
    file2_base=$(basename "$test_file2" .env)

    # Test 1: Complete all available options (empty input)
    local COMP_WORDS=("loadenv" "")
    local COMP_CWORD=1
    local COMPREPLY=()

    _loadenv_complete

    local completion_list="${COMPREPLY[*]}"
    assert_contains "$completion_list" "$file1_base" "should complete to test file 1" || true
    assert_contains "$completion_list" "$file2_base" "should complete to test file 2" || true
    assert_contains "$completion_list" "list" "should include 'list' command" || true
    assert_contains "$completion_list" "clear" "should include 'clear' command" || true

    # Test 2: Partial completion with "completion_" prefix
    COMP_WORDS=("loadenv" "completion_")
    COMPREPLY=()
    _loadenv_complete
    completion_list="${COMPREPLY[*]}"
    assert_contains "$completion_list" "$file1_base" "should complete partial match 1" || true
    assert_contains "$completion_list" "$file2_base" "should complete partial match 2" || true

    # Test 3: Command completion with "l" prefix
    COMP_WORDS=("loadenv" "l")
    COMPREPLY=()
    _loadenv_complete
    completion_list="${COMPREPLY[*]}"
    assert_contains "$completion_list" "list" "should complete 'l' to 'list'" || true

    # Test 4: Command completion with "c" prefix
    COMP_WORDS=("loadenv" "c")
    COMPREPLY=()
    _loadenv_complete
    completion_list="${COMPREPLY[*]}"
    assert_contains "$completion_list" "clear" "should complete 'c' to 'clear'" || true

    # Test 5: No matches for nonexistent prefix
    COMP_WORDS=("loadenv" "nonexistent_prefix_xyz")
    COMPREPLY=()
    _loadenv_complete
    if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
        log_success "should return no matches for nonexistent prefix"
    else
        log_failure "should return no matches for nonexistent prefix - Got: ${COMPREPLY[*]}"
    fi

    # Test 6: Completion when COMP_CWORD is not 1 (should not complete)
    COMP_WORDS=("loadenv" "test" "extra")
    COMP_CWORD=2
    COMPREPLY=()
    _loadenv_complete
    if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
        log_success "should not complete when not in position 1"
    else
        log_failure "should not complete when not in position 1 - Got: ${COMPREPLY[*]}"
    fi

    echo
}

# Run tests
run_tests() {
    local test_env_name
    test_env_name=$(basename "$TEST_ENV_FILE" .env)

    echo "🚀 Starting loadenv tests..."
    echo "Using test environment: $test_env_name"
    echo

    # Test 1: Load environment variables
    log_test "Loading environment variables"
    local output
    # Create a temporary file to capture output while preserving variable export
    local temp_output
    temp_output=$(mktemp)
    loadenv "$test_env_name" > "$temp_output" 2>&1
    output=$(cat "$temp_output")
    rm "$temp_output"

    assert_contains "$output" "Loaded 3 vars:" "should show count of loaded variables" || true
    assert_contains "$output" "TEST_VAR1" "should list TEST_VAR1 in loaded variables" || true
    assert_contains "$output" "TEST_VAR2" "should list TEST_VAR2 in loaded variables" || true
    assert_contains "$output" "TEST_VAR_WITH_SPACES" "should list TEST_VAR_WITH_SPACES in loaded variables" || true
    assert_equals "value1" "${TEST_VAR1:-}" "TEST_VAR1 should be set to 'value1'" || true
    assert_equals "value2" "${TEST_VAR2:-}" "TEST_VAR2 should be set to 'value2'" || true
    assert_equals "value with spaces" "${TEST_VAR_WITH_SPACES:-}" "TEST_VAR_WITH_SPACES should handle spaces" || true
    echo

    # Test 2: List command
    log_test "List command functionality"
    local temp_output
    temp_output=$(mktemp)
    loadenv list > "$temp_output" 2>&1
    output=$(cat "$temp_output")
    rm "$temp_output"

    assert_contains "$output" "Loaded environment variables:" "list should show header" || true
    assert_contains "$output" "TEST_VAR1" "list should show TEST_VAR1" || true
    assert_contains "$output" "TEST_VAR2" "list should show TEST_VAR2" || true
    echo

    # Test 3: Add more variables and reload
    log_test "Adding more variables"
    echo "TEST_VAR3=value3" >> "$TEST_ENV_FILE"

    # Capture output when loading with new variable
    local temp_output
    temp_output=$(mktemp)
    loadenv "$test_env_name" > "$temp_output" 2>&1
    output=$(cat "$temp_output")
    rm "$temp_output"

    assert_equals "value3" "${TEST_VAR3:-}" "TEST_VAR3 should be set after reload" || true
    assert_contains "$output" "Loaded 1 vars: TEST_VAR3" "should show only newly loaded variable TEST_VAR3" || true

    temp_output=$(mktemp)
    loadenv list > "$temp_output" 2>&1
    output=$(cat "$temp_output")
    rm "$temp_output"
    assert_contains "$output" "TEST_VAR3" "list should show newly added TEST_VAR3" || true
    echo

    # Test 4: Clear command
    log_test "Clear command functionality"
    local temp_output
    temp_output=$(mktemp)
    loadenv clear > "$temp_output" 2>&1
    output=$(cat "$temp_output")
    rm "$temp_output"

    assert_contains "$output" "All loadenv variables have been unset" "clear should confirm action" || true
    assert_equals "" "${TEST_VAR1:-}" "TEST_VAR1 should be unset after clear" || true
    assert_equals "" "${TEST_VAR2:-}" "TEST_VAR2 should be unset after clear" || true
    assert_equals "" "${TEST_VAR3:-}" "TEST_VAR3 should be unset after clear" || true

    temp_output=$(mktemp)
    loadenv list > "$temp_output" 2>&1
    output=$(cat "$temp_output")
    rm "$temp_output"
    assert_contains "$output" "No environment variables have been loaded" "list should show no variables after clear" || true
    echo

    # Test 5: Reload after clear
    log_test "Reloading after clear"
    loadenv "$test_env_name" >/dev/null 2>&1
    assert_equals "value1" "${TEST_VAR1:-}" "TEST_VAR1 should be restored after reload" || true
    assert_equals "value2" "${TEST_VAR2:-}" "TEST_VAR2 should be restored after reload" || true
    echo

    # Test completion functionality
    test_completion

    # Test 6: Error handling - non-existent file
    log_test "Error handling for non-existent file"
    output=$(loadenv nonexistent 2>&1 || true)
    assert_contains "$output" "Error: .env file not found" "should show error for missing file" || true
    echo
}

# Main execution
main() {
    echo "🔍 Testing loadenv script functionality"
    echo "========================================"

    setup_test
    run_tests

    echo "📊 Test Results"
    echo "==============="
    echo "✅ Passed: $TESTS_PASSED"
    echo "❌ Failed: $TESTS_FAILED"
    echo "📈 Total:  $((TESTS_PASSED + TESTS_FAILED))"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo "🎉 All tests passed!"
        exit 0
    else
        echo "💥 Some tests failed!"
        exit 1
    fi
}

# Run main function
main
