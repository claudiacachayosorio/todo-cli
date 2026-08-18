#!/usr/bin/env bats
# =========================================================================== #
# Description: Testing suite for todo-cli's core functions.
# Command:     bats test/core.bats

setup() {
	load test_helper
	todo_setup
	source "$TODO_SCRIPT"
}
