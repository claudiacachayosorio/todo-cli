#!/usr/bin/env bats
# =========================================================================== #
# Description:	Integration tests for todo-cli.
# Command:			bats test/integration.bats
# =========================================================================== #

setup() {
	load test_helper
	test_todo_setup_sandbox
	source "$TEST_TODO_APP_SCRIPT"
}

teardown() {
	test_todo_teardown_sandbox
}
