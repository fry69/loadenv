#!/usr/bin/env bash

# Source the loadenv function
source ./loadenv.sh

# Create a temporary .env file for testing
TEST_ENV_FILE="$HOME/.loadenv/test.env"
mkdir -p "$HOME/.loadenv"
echo "TEST_VAR1=value1" > "$TEST_ENV_FILE"
echo "TEST_VAR2=value2" >> "$TEST_ENV_FILE"

# Test loading variables
echo "Testing loadenv with test.env"
loadenv test
echo "TEST_VAR1: $TEST_VAR1"
echo "TEST_VAR2: $TEST_VAR2"

# Test list command
echo -e "\nTesting list command"
loadenv list

# Test loading more variables
echo -e "\nTesting loading more variables"
echo "TEST_VAR3=value3" >> "$TEST_ENV_FILE"
loadenv test
loadenv list

# Test clear command
echo -e "\nTesting clear command"
loadenv clear
echo "After clear, TEST_VAR1: $TEST_VAR1"
loadenv list

# Test loading variables again after clear
echo -e "\nTesting loading variables again after clear"
loadenv test
loadenv list

# Clean up
rm "$TEST_ENV_FILE"
echo -e "\nTest completed. Temporary .env file removed."
