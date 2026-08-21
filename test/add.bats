#!/usr/bin/env bats
# =========================================================================== #
# Description: Testing suite for todo-cli's add subcommand.
# Command:     bats test/add.bats

load test_helper
readonly LABEL="[+] Added"

setup() {
	todo_setup
}

@test "success: no todo.txt: creates file and saves new task" {
	local -r new_task="${TASKS[1]}"
	run --keep-empty-lines "$TODO_SCRIPT" "add" "$new_task"
	assert_success
	todo_assert_task_success "$LABEL" 1 "$new_task"
	todo_assert_summary 1
	todo_assert_storage_content "$new_task"
}

@test "success: existing data: appends new task" {
	local -r new_task="${TASKS[4]}"
	todo_print_tasks 3 > "$TODO_FILE"

	run --keep-empty-lines "$TODO_SCRIPT" "add" "$new_task"
	assert_success
	todo_assert_task_success "$LABEL" 4 "$new_task"
	todo_assert_summary 4
	todo_assert_storage_content
}

@test "success: todo.txt has empty line: inserts new task in empty line" {
	local -r task_1_alt="this is a different first task"
	local tasks=("${TASKS[@]}")
	tasks[1]=""
	todo_print_tasks "${tasks[@]}" > "$TODO_FILE"

	run --keep-empty-lines "$TODO_SCRIPT" "add" "$task_1_alt"
	assert_success
	todo_assert_task_success "$LABEL" 1 "$task_1_alt"
	todo_assert_summary 4
	tasks[1]="$task_1_alt"
	todo_assert_storage_content "${tasks[@]}"
}

@test "success: unquoted task: joins arguments into one new task" {
	local -r task="${TASKS[4]}"
	local unquoted_task
	read -ra unquoted_task <<< "$task"
	todo_print_tasks 3 > "$TODO_FILE"

	run --keep-empty-lines "$TODO_SCRIPT" "add" "${unquoted_task[@]}"
	assert_success
	todo_assert_task_success "$LABEL" 4 "$task"
	todo_assert_summary 4
	todo_assert_storage_content
}
