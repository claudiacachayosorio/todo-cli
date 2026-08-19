#!/usr/bin/env bats
# =========================================================================== #
# Description: Testing suite for todo-cli's add subcommand.
# Command:     bats test/add.bats

load test_helper
setup() {
	todo_setup
	source "$TODO_SCRIPT"
}

todo_execute_add_cmd() {
	local index="$1"
	local expected_count="$index"
	shift
	[[ "${1:-}" =~ ^[0-9]$ ]] && { expected_count="$1"; shift; }

	local task_words=("$@") \
	      new_task="$*"
	run --keep-empty-lines "$TODO_SCRIPT" "add" "${task_words[@]}"
	assert_success
	todo_assert_task_success "[+] Added" "$index" "$new_task"
	todo_assert_summary "$expected_count"
}

@test "success: no todo.txt: creates file and saves new task" {
	todo_execute_add_cmd 1 "${TASKS[1]}"
	todo_assert_storage_content "${TASKS[1]}"
}

@test "success: existing data: appends new task" {
	todo_print_tasks 3 > "$TODO_FILE"
	todo_execute_add_cmd 4 "${TASKS[4]}"
	todo_assert_storage_content
}

@test "success: todo.txt has empty line: inserts new task in empty line" {
	local task_1_alt="this is a different first task" \
	      tasks=("${TASKS[@]}")

	tasks[1]=""
	todo_print_tasks "${tasks[@]}" > "$TODO_FILE"
	todo_execute_add_cmd 1 4 "$task_1_alt"
	tasks[1]="$task_1_alt"
	todo_assert_storage_content "${tasks[@]}"
}

@test "success: unquoted task: joins arguments into one new task" {
	local unquoted_task
	read -ra unquoted_task <<< "${TASKS[4]}"
	todo_print_tasks 3 > "$TODO_FILE"
	todo_execute_add_cmd 4 "${unquoted_task[@]}"
	todo_assert_storage_content
}
