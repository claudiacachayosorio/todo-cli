#!/usr/bin/env bats
# =========================================================================== #
# Description: Testing suite for todo-cli's add subcommand.
# Command:     bats test/add.bats

setup() {
	load test_helper
	todo_setup
	source "$TODO_SCRIPT"
}
