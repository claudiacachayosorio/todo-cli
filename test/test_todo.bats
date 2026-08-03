#!/usr/bin/env bats

# =========================================================================== #
# Description:	Unit and integration testing for todo-cli.
# Command:		bats test/
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

@test "validate_strict_arg_count fails mismatched counts" {
	local -r command="todo.sh edit"
	local -r err_message="${command} requires exactly 3 argument(s)."

	run --separate-stderr validate_strict_arg_count 3 2 "$command"
	assert_failure
	assert_stderr "Error: $err_message"

	run --separate-stderr validate_strict_arg_count 3 4 "$command"
	assert_failure
	assert_stderr "Error: $err_message"
}

@test "validate_strict_arg_count quietly passes matching counts" {
	run validate_strict_arg_count 3 3
	assert_success
	refute_output
}

@test "validate_min_arg_count fails count lower than minimum" {
	local -r command="todo.sh edit"
	run --separate-stderr validate_min_arg_count 3 2 "$command"
	assert_failure
	assert_stderr "Error: ${command} requires a minimum of 3 argument(s)."
}

@test "validate_min_arg_count quietly passes count greater than or equal to minimum" {
	run validate_min_arg_count 3 4
	assert_success
	refute_output

	run validate_min_arg_count 3 3
	assert_success
	refute_output
}

@test "validate_max_arg_count fails count higher than maximum" {
	local -r command="todo.sh edit"
	run --separate-stderr validate_max_arg_count 3 4 "$command"
	assert_failure
	assert_stderr "Error: ${command} allows a maximum of 3 argument(s)."
}

@test "validate_max_arg_count quietly passes count lower than or equal to maximum" {
	run validate_max_arg_count 3 2
	assert_success
	refute_output

	run validate_max_arg_count 3 3
	assert_success
	refute_output
}

# =========================================================================== #
# Unit Tests - app.sh
# =========================================================================== #

# =========================================================================== #
# Integration Tests - todo.sh
# =========================================================================== #
