#!/usr/bin/env bash
bats_require_minimum_version 1.5.0
# =========================================================================== #
# Description:	Centralized Bats test helper.
# =========================================================================== #

export TODO_TEST_APP_ROOT="$(cd "${BATS_TEST_DIRNAME}/.." >/dev/null 2>&1 && pwd)"
export TODO_TEST_APP_SCRIPT="${TODO_TEST_APP_ROOT}/todo.sh"

BATS_LIB_PATH="${BATS_TEST_DIRNAME}/test_helper"
bats_load_library bats-support
bats_load_library bats-assert

todo_test_setup_sandbox() {
	TODO_TEST_SANDBOX="$(mktemp -d "${BATS_TMPDIR:-/tmp}/todo_sandbox.XXXXXX")"
	export TODO_TEST_SANDBOX
	export TODO_FILE="${TODO_TEST_SANDBOX}/todo.txt"
	#export DONE_FILE="${TODO_TEST_SANDBOX}/done.txt"
	touch "$TODO_FILE"
	#touch "$DONE_FILE"
}

todo_test_teardown_sandbox() {
	rm -rf "$TODO_TEST_SANDBOX"
}
