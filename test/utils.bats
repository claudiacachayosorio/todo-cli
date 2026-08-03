#!/usr/bin/env bats

# =========================================================================== #
# Description:	Unit tests for todo-cli's utility functions.
# Command:		bats test/utils.bats
# =========================================================================== #

FIXTURE_COMMAND="todo.sh edit"

setup() {
	load test_helper
	todo_test_setup_sandbox
	source "$TODO_TEST_APP_SCRIPT"
}

teardown() {
	todo_test_teardown_sandbox
}

# error_exit
# =========================================================================== #
@test "error_exit prints message to stderr and terminates with expected status" {
	local -r err_message="File not found."
	run --separate-stderr error_exit "$err_message"
	assert_failure
	assert_stderr "Error: ${err_message}"
}

# log_error
# =========================================================================== #
@test "log_error prints message exclusively to stderr" {
	local -r err_message="Invalid input."
	run --separate-stderr log_error "$err_message"
	assert_success
	refute_output
	assert_stderr "Error: ${err_message}"
}

# validate_strict_arg_count
# =========================================================================== #
@test "validate_strict_arg_count fails mismatched counts" {
	local -r err_message="${FIXTURE_COMMAND} requires exactly 3 argument(s)."
	run --separate-stderr validate_strict_arg_count 3 2 "$FIXTURE_COMMAND"
	assert_failure
	assert_stderr "Error: $err_message"
	run --separate-stderr validate_strict_arg_count 3 4 "$FIXTURE_COMMAND"
	assert_failure
	assert_stderr "Error: $err_message"
}

@test "validate_strict_arg_count quietly passes matching counts" {
	run validate_strict_arg_count 3 3
	assert_success
	refute_output
}

# validate_min_arg_count
# =========================================================================== #
@test "validate_min_arg_count fails count lower than minimum" {
	run --separate-stderr validate_min_arg_count 3 2 "$FIXTURE_COMMAND"
	assert_failure
	assert_stderr "Error: ${FIXTURE_COMMAND} requires a minimum of 3 argument(s)."
}

@test "validate_min_arg_count quietly passes count greater than or equal to minimum" {
	run validate_min_arg_count 3 4
	assert_success
	refute_output
	run validate_min_arg_count 3 3
	assert_success
	refute_output
}

# validate_max_arg_count
# =========================================================================== #
@test "validate_max_arg_count fails count higher than maximum" {
	run --separate-stderr validate_max_arg_count 3 4 "$FIXTURE_COMMAND"
	assert_failure
	assert_stderr "Error: ${FIXTURE_COMMAND} allows a maximum of 3 argument(s)."
}

@test "validate_max_arg_count quietly passes count lower than or equal to maximum" {
	run validate_max_arg_count 3 2
	assert_success
	refute_output
	run validate_max_arg_count 3 3
	assert_success
	refute_output
}

# assert_file_exists
# =========================================================================== #

# assert_file_not_empty
# =========================================================================== #

# assert_task_exists
# =========================================================================== #

# validate_task_id
# =========================================================================== #

# sanitize_string
# =========================================================================== #
