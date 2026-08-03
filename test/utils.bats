#!/usr/bin/env bats
# =========================================================================== #
# Description:	Unit tests for todo-cli's utility functions.
# Command:			bats test/utils.bats
# =========================================================================== #
load "test_helper"

TEST_TODO_DEFAULT_STDERR="${TEST_TODO_ERR_LABEL} An unknown error has occurred."

setup() {
	#test_todo_setup_sandbox
	source "$TEST_TODO_APP_SCRIPT"
}

#teardown() {
#	test_todo_teardown_sandbox
#}

test_todo_assert_default_stderr() {
	local err_util="$1"
	run --separate-stderr "$err_util"
	assert_stderr "$TEST_TODO_DEFAULT_STDERR"
	run --separate-stderr "$err_util" ""
	assert_stderr "$TEST_TODO_DEFAULT_STDERR"
}

# _todo_error_exit
# =========================================================================== #
@test "_todo_error_exit prints message to stderr and terminates with expected status" {
	local err_desc="File not found."
	run --separate-stderr _todo_error_exit "$err_desc"
	test_todo_assert_loud_failure "$err_desc"
}

@test "_todo_error_exit uses default when error message is missing or empty" {
	test_todo_assert_default_stderr "_todo_error_exit"
}

# _todo_log_error
# =========================================================================== #
@test "_todo_log_error prints message exclusively to stderr" {
	local err_desc="Invalid input."
	run --separate-stderr _todo_log_error "$err_desc"
	test_todo_assert_quiet_success
	assert_stderr "${TEST_TODO_ERR_LABEL} ${err_desc}"
}

@test "_todo_log_error uses default when error message is missing or empty" {
	test_todo_assert_default_stderr "_todo_log_error"
}

# _todo_validate_strict_arg_count
# =========================================================================== #
@test "_todo_validate_strict_arg_count rejects mismatched counts" {
	local err_desc="This command requires exactly 3 argument(s)."
	run --separate-stderr _todo_validate_strict_arg_count 3 2
	test_todo_assert_loud_failure "$err_desc"
	run --separate-stderr _todo_validate_strict_arg_count 3 4
	test_todo_assert_loud_failure "$err_desc"
}

@test "_todo_validate_strict_arg_count quietly accepts matching counts" {
	run _todo_validate_strict_arg_count 3 3
	test_todo_assert_quiet_success
}

# _todo_validate_min_arg_count
# =========================================================================== #
@test "_todo_validate_min_arg_count rejects count lower than minimum" {
	local err_desc="This command requires a minimum of 3 argument(s)."
	run --separate-stderr _todo_validate_min_arg_count 3 2
	test_todo_assert_loud_failure "$err_desc"
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
	local err_desc="This command allows a maximum of 3 argument(s)."
	run --separate-stderr _todo_validate_max_arg_count 3 4
	test_todo_assert_loud_failure "$err_desc"
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
