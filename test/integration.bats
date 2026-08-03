#!/usr/bin/env bats
# =========================================================================== #
# Description:	Integration tests for todo-cli.
# Command:		bats test/integration.bats
# =========================================================================== #

setup() {
	load test_helper
	todo_test_setup_sandbox
	source "$TODO_TEST_APP_SCRIPT"
}

teardown() {
	todo_test_teardown_sandbox
}
