#!/usr/bin/env bash
bats_require_minimum_version 1.5.0
# =========================================================================== #
# Description:	Centralized Bats test helper.
# =========================================================================== #

export TEST_TODO_APP_ROOT="$(cd "${BATS_TEST_DIRNAME}/.." >/dev/null 2>&1 && pwd)"
export TEST_TODO_APP_SCRIPT="${TEST_TODO_APP_ROOT}/todo.sh"
export TEST_TODO_ERR_LABEL="Error:"

BATS_LIB_PATH="${BATS_TEST_DIRNAME}/test_helper"
bats_load_library bats-support
bats_load_library bats-assert

test_todo_setup_sandbox() {
	TEST_TODO_SANDBOX="$(mktemp -d "${BATS_TMPDIR:-/tmp}/todo_sandbox.XXXXXX")"
	export TEST_TODO_SANDBOX
	export TEST_TODO_DB_ACTIVE="${TEST_TODO_SANDBOX}/todo.txt"
	export TEST_TODO_DB_ARCHIVE="${TEST_TODO_SANDBOX}/done.txt"
	touch "$TEST_TODO_DB_ACTIVE" "$TEST_TODO_DB_ARCHIVE"
}

test_todo_teardown_sandbox() {
	rm -rf "$TEST_TODO_SANDBOX"
}

test_todo_assert_quiet_success() {
	assert_success
	refute_output
}

test_todo_assert_loud_failure() {
	local err_message="$1"
	assert_failure
	assert_stderr "${TEST_TODO_ERR_LABEL} ${err_message}"
}
