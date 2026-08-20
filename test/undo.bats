#!/usr/bin/env bats
# =========================================================================== #
# Description: Testing suite for todo-cli's undo subcommand.
# Command:     bats test/undo.bats

load test_helper
setup() {
	todo_setup
	source "$TODO_SCRIPT"
	readonly LABEL="[ ] Undone"
	readonly DONE_TASKS=("${TASKS[@]/#/x }")
	todo_print_tasks "${DONE_TASKS[@]}" > "$TODO_FILE"
}

@test "success: valid index: adds prefix to targeted task" {
	local expected_tasks=("${DONE_TASKS[@]}")
	expected_tasks[1]="${TASKS[1]}"
	run --keep-empty-lines "$TODO_SCRIPT" "undo" 1
	assert_success
	todo_assert_task_success "$LABEL" 1 "${expected_tasks[1]}"
	todo_assert_summary 1 3
	todo_assert_storage_content "${expected_tasks[@]}"
}

@test "success: multiple valid indexes: removes prefix from targeted tasks" {
	local expected_tasks=("${DONE_TASKS[@]}")
	expected_tasks[1]="${TASKS[1]}"
	expected_tasks[2]="${TASKS[2]}"
	run --keep-empty-lines "$TODO_SCRIPT" "undo" 1 2
	assert_success
	todo_assert_task_success "$LABEL" 1 "${expected_tasks[1]}"
	todo_assert_task_success "$LABEL" 2 "${expected_tasks[2]}"
	todo_assert_summary 2 2
	todo_assert_storage_content "${expected_tasks[@]}"
}
