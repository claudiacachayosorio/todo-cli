#!/usr/bin/env bats
# =========================================================================== #
# Description: Testing suite for todo-cli's del subcommand.
# Command:     bats test/13_del.bats

load test_helper
readonly LABEL="[-] Deleted"
setup() {
	todo_setup
}

@test "valid index: replaces targeted task with empty line" {
	local tasks=("${TASKS[@]}")
	todo_print_tasks > "$TODO_FILE"

	run --keep-empty-lines "$TODO_SCRIPT" "del" 1
	assert_success
	todo_assert_task_success "$LABEL" 1
	todo_assert_summary 3
	tasks[1]=""
	todo_assert_storage_content "${tasks[@]}"
}

@test "multiple valid indexes: replaces targeted tasks with empty lines" {
	local tasks=("${TASKS[@]}")
	todo_print_tasks > "$TODO_FILE"

	run --keep-empty-lines "$TODO_SCRIPT" "del" 1 2
	assert_success
	todo_assert_task_success "$LABEL" 1
	todo_assert_task_success "$LABEL" 2
	todo_assert_summary 2
	tasks[1]=""
	tasks[2]=""
	todo_assert_storage_content "${tasks[@]}"
}

@test "end of file task: trims leftover trailing newlines" {
	local tasks=("${TASKS[@]}")
	tasks[3]=""
	todo_print_tasks "${tasks[@]}" > "$TODO_FILE"
	run --keep-empty-lines "$TODO_SCRIPT" "del" 4
	assert_success
	todo_assert_task_success "$LABEL" 4
	todo_assert_summary 2
	unset "tasks[3]" "tasks[4]"
	todo_assert_storage_content "${tasks[@]}"
}

@test "last remaining task: empties storage" {
	printf "\n%s\n" "${TASKS[2]}" > "$TODO_FILE"
	run --keep-empty-lines "$TODO_SCRIPT" "del" 2
	assert_success
	todo_assert_task_success "$LABEL" 2
	todo_assert_summary 0
	todo_assert_storage_empty
}

todo_register_invalid_index_tests "del" \
"index is non-numeric" \
"index is 0" \
"index is out of bounds"

@test "valid & invalid index: targets only valid index" {
	todo_print_tasks > "$TODO_FILE"
	todo_execute_mixed_indexes "del" "$LABEL" 3
	todo_assert_storage_content "${TASKS[@]:0:4}"
}
