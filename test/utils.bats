#!/usr/bin/env bats
# =========================================================================== #
# Description:	Unit tests for todo-cli's utility functions.
# Command:			bats test/utils.bats
# =========================================================================== #

setup() {
	load test_helper
	test_todo_setup_sandbox
	source "$TEST_TODO_APP_SCRIPT"
}

teardown() {
	test_todo_teardown_sandbox
}

TEST_TODO_FIXTURE_CMD="todo.sh add"

# _todo_error_exit
# =========================================================================== #
@test "_todo_error_exit prints message to stderr and terminates with expected status" {
	local err_message="File not found."
	run --separate-stderr _todo_error_exit "$err_message"
	test_todo_assert_loud_failure "$err_message"
}

# _todo_log_error
# =========================================================================== #
@test "_todo_log_error prints message exclusively to stderr" {
	local err_message="Invalid input."
	run --separate-stderr _todo_log_error "$err_message"
	test_todo_assert_quiet_success
	assert_stderr "${TEST_TODO_ERR_LABEL} ${err_message}"
}

# _todo_validate_strict_arg_count
# =========================================================================== #
@test "_todo_validate_strict_arg_count rejects mismatched counts" {
	local err_message="${TEST_TODO_FIXTURE_CMD} requires exactly 3 argument(s)."
	run --separate-stderr _todo_validate_strict_arg_count 3 2 "$TEST_TODO_FIXTURE_CMD"
	test_todo_assert_loud_failure "$err_message"
	run --separate-stderr _todo_validate_strict_arg_count 3 4 "$TEST_TODO_FIXTURE_CMD"
	test_todo_assert_loud_failure "$err_message"
}

@test "_todo_validate_strict_arg_count quietly accepts matching counts" {
	run _todo_validate_strict_arg_count 3 3
	test_todo_assert_quiet_success
}

# _todo_validate_min_arg_count
# =========================================================================== #
@test "_todo_validate_min_arg_count rejects count lower than minimum" {
	local err_message="${TEST_TODO_FIXTURE_CMD} requires a minimum of 3 argument(s)."
	run --separate-stderr _todo_validate_min_arg_count 3 2 "$TEST_TODO_FIXTURE_CMD"
	test_todo_assert_loud_failure "$err_message"
}

@test "_todo_validate_min_arg_count quietly accepts count greater than or equal to minimum" {
	run _todo_validate_min_arg_count 3 4
	test_todo_assert_quiet_success
	run _todo_validate_min_arg_count 3 3
	test_todo_assert_quiet_success
}

# _todo_validate_max_arg_count
# =========================================================================== #
@test "_todo_validate_max_arg_count rejects count higher than maximum" {
	local err_message="${TEST_TODO_FIXTURE_CMD} allows a maximum of 3 argument(s)."
	run --separate-stderr _todo_validate_max_arg_count 3 4 "$TEST_TODO_FIXTURE_CMD"
	test_todo_assert_loud_failure "$err_message"
}

@test "_todo_validate_max_arg_count quietly accepts count lower than or equal to maximum" {
	run _todo_validate_max_arg_count 3 2
	test_todo_assert_quiet_success
	run _todo_validate_max_arg_count 3 3
	test_todo_assert_quiet_success
}

# _todo_sanitize_string
# =========================================================================== #

# _todo_assert_file_exists
# =========================================================================== #
#@test "_todo_assert_file_exists fails when target file doesn't exist" {}

#@test "_todo_assert_file_exists passes when target file exists" {}

# _todo_assert_file_not_empty
# =========================================================================== #

# _todo_assert_task_exists
# =========================================================================== #

# _todo_validate_task_id
# =========================================================================== #
