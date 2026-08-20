#!/usr/bin/env bats
# =========================================================================== #
# Description: Testing suite for todo-cli's do subcommand.
# Command:     bats test/do.bats

load test_helper
setup() {
	todo_setup
	readonly LABEL="[x] Done"
	todo_print_tasks > "$TODO_FILE"
}

@test "success: valid index: adds prefix to targeted task" {
	local expected_tasks=("${TASKS[@]}")
	expected_tasks[1]="x ${TASKS[1]}"
	run --keep-empty-lines "$TODO_SCRIPT" "do" 1
	assert_success
	todo_assert_task_success "$LABEL" 1 "${expected_tasks[1]}"
	todo_assert_summary 3 1
	todo_assert_storage_content "${expected_tasks[@]}"
}

@test "success: multiple valid indexes: adds prefix to targeted tasks" {
	local expected_tasks=("${TASKS[@]}")
	expected_tasks[1]="x ${TASKS[1]}"
	expected_tasks[2]="x ${TASKS[2]}"
	run --keep-empty-lines "$TODO_SCRIPT" "do" 1 2
	assert_success
	todo_assert_task_success "$LABEL" 1 "${expected_tasks[1]}"
	todo_assert_task_success "$LABEL" 2 "${expected_tasks[2]}"
	todo_assert_summary 2 2
	todo_assert_storage_content "${expected_tasks[@]}"
}
