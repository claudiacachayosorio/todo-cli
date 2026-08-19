#!/usr/bin/env bats
# =========================================================================== #
# Description: Testing suite for todo-cli's do and undo subcommands.
# Command:     bats test/completion.bats

load test_helper
setup() {
	todo_setup
	source "$TODO_SCRIPT"
	export LABEL_UNDO="[ ] Undone"
}
