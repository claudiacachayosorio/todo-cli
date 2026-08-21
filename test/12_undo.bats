#!/usr/bin/env bats
# =========================================================================== #
# Description: Testing suite for todo-cli's undo subcommand.
# Command:     bats test/12_undo.bats

load test_helper
readonly LABEL="[ ] Undone"
readonly DONE_TASKS=("${TASKS[@]/#/x }")
readonly UNCHECKED_INDEX="${INDEX_ERRORS["task is unchecked"]#* | }"
FAILURE_TESTS_TASKS=("${DONE_TASKS[@]}")
FAILURE_TESTS_TASKS[$UNCHECKED_INDEX]="${TASKS[$UNCHECKED_INDEX]}"
readonly FAILURE_TESTS_TASKS

setup() {
	todo_setup
	todo_print_tasks "${DONE_TASKS[@]}" > "$TODO_FILE"
}

@test "valid index: adds prefix to targeted task" {
	local expected_tasks=("${DONE_TASKS[@]}")
	expected_tasks[1]="${TASKS[1]}"
	run --keep-empty-lines "$TODO_SCRIPT" "undo" 1
	assert_success
	todo_assert_task_success "$LABEL" 1 "${expected_tasks[1]}"
	todo_assert_summary 1 3
	todo_assert_storage_content "${expected_tasks[@]}"
}

@test "multiple valid indexes: removes prefix from targeted tasks" {
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

todo_register_invalid_index_tests "undo" \
"index is non-numeric" \
"index is 0" \
"index is out of bounds" \
"task is unchecked"

@test "valid and invalid index: targets only valid index" {
	local expected_tasks=("${DONE_TASKS[@]}")
	expected_tasks[4]="${TASKS[4]}"
	todo_execute_mixed_indexes "undo" "$LABEL" 1 3
	todo_assert_storage_content "${expected_tasks[@]}"
}
