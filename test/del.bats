#!/usr/bin/env bats
# =========================================================================== #
# Description: Testing suite for todo-cli's del subcommand.
# Command:     bats test/del.bats

load test_helper
setup() {
	todo_setup
	source "$TODO_SCRIPT"
	todo_print_tasks > "$TODO_FILE"
	declare -xr LABEL="[-] Deleted"
}

@test "success: valid index: replaces corresponding task with empty line" {
	local tasks=("${TASKS[@]}") \
	      expected
	tasks[1]=""
	expected="$(todo_print_tasks "${tasks[@]}")"
}
