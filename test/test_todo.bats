#!/usr/bin/env bats

# =========================================================================== #
# Description:	Unit and integration testing for todo-cli.
# Command:		bats test/ --show-output-of-passing-tests
# =========================================================================== #

setup() {
	bats_require_minimum_version 1.5.0
	load "test_helper/bats-support/load"
	load "test_helper/bats-assert/load"

	#TEST_SANDBOX="$(mktemp -d "${TMPDIR:-/tmp}/todo_test.XXXXXX")"
	#export TODO_FILE="${TEST_SANDBOX}/todo.txt"
	#export DONE_FILE="${TEST_SANDBOX}/done.txt"
	#touch "$TODO_FILE" "$DONE_FILE"

	local app_root
	app_root="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd)"
	source "${app_root}/todo.sh"
}

#teardown() {
	#rm -rf "$TEST_SANDBOX"
#}

# =========================================================================== #
# Unit Tests - utils.sh
# =========================================================================== #

@test "error_exit prints message to stderr and terminates with expected status" {
	local -r err_message="Config file was not found."
	run --separate-stderr error_exit "$err_message"
	assert_failure
	assert_stderr "Error: ${err_message}"
}

@test "log_error prints message exclusively to stderr" {
	local -r err_message="Invalid input."
	run --separate-stderr log_error "$err_message"
	assert_success
	refute_output
	assert_stderr "Error: ${err_message}"
}

# =========================================================================== #
# Unit Tests - app.sh
# =========================================================================== #

# =========================================================================== #
# Integration Tests - todo.sh
# =========================================================================== #
