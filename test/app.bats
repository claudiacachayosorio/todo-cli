#!/usr/bin/env bats
# =========================================================================== #
# Description:	Unit tests for todo-cli's core logic.
# Command:		bats test/app.bats
# =========================================================================== #

setup() {
	load test_helper
	test_todo_setup_sandbox
	source "$TEST_TODO_APP_SCRIPT"
}

teardown() {
	test_todo_teardown_sandbox
}
