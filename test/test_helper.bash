#!/usr/bin/env bash
bats_require_minimum_version 1.5.0
# =========================================================================== #
# Description:	Centralized Bats test helper.
# =========================================================================== #

export TODO_TEST_APP_ROOT="$(cd "${BATS_TEST_DIRNAME}/.." >/dev/null 2>&1 && pwd)"
export TODO_TEST_APP_SCRIPT="${TODO_TEST_APP_ROOT}/todo.sh"
export FIXTURE_ERR_LABEL="Error:"

BATS_LIB_PATH="${BATS_TEST_DIRNAME}/test_helper"
bats_load_library bats-support
bats_load_library bats-assert

todo_test_setup_sandbox() {
	TODO_TEST_SANDBOX="$(mktemp -d "${BATS_TMPDIR:-/tmp}/todo_sandbox.XXXXXX")"
	export TODO_TEST_SANDBOX
	export FIXTURE_TODO_FILE="${TODO_TEST_SANDBOX}/todo.txt"
	export FIXTURE_DONE_FILE="${TODO_TEST_SANDBOX}/done.txt"
	touch "$FIXTURE_TODO_FILE" "$FIXTURE_DONE_FILE"
}

todo_test_teardown_sandbox() {
	rm -rf "$TODO_TEST_SANDBOX"
}

todo_test_assert_quiet_success() {
	assert_success
	refute_output
}

todo_test_assert_failure_message() {
	local err_message="$1"
	assert_failure
	assert_stderr "${FIXTURE_ERR_LABEL} ${err_message}"
}
