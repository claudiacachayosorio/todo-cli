#!/usr/bin/env bats
# =========================================================================== #
# Description: Testing suite for todo-cli's completion functions.
# Command:     bats test/completion.bats

setup() {
	load test_helper
	todo_setup
	source "$TODO_SCRIPT"
}
