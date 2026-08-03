#!/usr/bin/env bats
# =========================================================================== #
# Description:	Unit tests for todo-cli's core logic.
# Command:		bats test/app.bats
# =========================================================================== #

setup() {
	load test_helper
	todo_test_setup_sandbox
	source "$TODO_TEST_APP_SCRIPT"
}

teardown() {
	todo_test_teardown_sandbox
}
