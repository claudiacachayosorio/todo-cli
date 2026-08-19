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
	local index="$1" \
	      expected_count="$2" \
	      expected_tasks="$3"
	shift 3
	local task_words=("$@") \
	      new_task="$*"

	run --keep-empty-lines "$TODO_SCRIPT" "add" "${task_words[@]}"
	assert_success
	todo_assert_task_success "[+] Added" "$index" "$new_task"
	todo_assert_summary "$expected_count"
	todo_assert_storage_content "$expected_tasks"
}

@test "success: no todo.txt: creates file and saves new task" {
	todo_execute_add_cmd 1 1 "${TASKS[1]}"$'\n' "${TASKS[1]}"
}

@test "success: existing data: appends new task" {
	local expected_tasks
	expected_tasks="$(todo_print_tasks)"
	todo_print_tasks 3 > "$TODO_FILE"
	todo_execute_add_cmd 4 4 "$expected_tasks" "${TASKS[4]}"
}

@test "success: todo.txt has empty line: inserts new task in empty line" {
	local task_1_alt="this is a different first task" \
	      tasks=("${TASKS[@]}") \
	      expected_tasks

	tasks[1]="$task_1_alt"
	expected_tasks="$(todo_print_tasks "${tasks[@]}")"
	tasks[1]=""
	todo_print_tasks "${tasks[@]}" > "$TODO_FILE"
	todo_execute_add_cmd 1 4 "$expected_tasks" "$task_1_alt"
}

@test "success: unquoted task: joins arguments into one new task" {
	local unquoted_task \
	      expected_tasks
	read -ra unquoted_task <<< "${TASKS[4]}"
	expected_tasks="$(todo_print_tasks)"
	todo_print_tasks 3 > "$TODO_FILE"
	todo_execute_add_cmd 4 4 "$expected_tasks" "${unquoted_task[@]}"
}
