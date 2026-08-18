#!/usr/bin/env bats
# =========================================================================== #
# Description: Testing suite for todo-cli's del subcommand.
# Command:     bats test/del.bats

setup() {
	load test_helper
	todo_setup
	source "$TODO_SCRIPT"
}
