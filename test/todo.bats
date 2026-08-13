#!/usr/bin/env bats
# =========================================================================== #
# Description: Test suite for todo-cli project.
# Command:     bats test/

bats_require_minimum_version 1.5.0

readonly BATS_LIB_PATH="${BATS_TEST_DIRNAME}/test_helper"
readonly TODO_DIR="$(cd "$BATS_TEST_DIRNAME/.." >/dev/null 2>&1 && pwd)"
readonly TODO_SCRIPT="${TODO_DIR}/todo"

MOCK_TASKS=("")
MOCK_TASKS[1]="prepare cake mixes"
MOCK_TASKS[2]="test buttercream recipe"
MOCK_TASKS[3]="refill flour containers"
MOCK_TASKS[4]="make banana bread"
MOCK_TASKS[5]="replace scale batteries"
readonly MOCK_TASKS

setup() {
	bats_load_library bats-support
	bats_load_library bats-assert
	bats_load_library bats-file

	load test_helper
	export DATA_DIR="$BATS_TEST_TMPDIR"
	source "$TODO_SCRIPT"
}

# bats --filter "^interface:" test/

@test "interface: handles routing and usage" {
	# no arguments: prints help and exits 0
	todo_execute_help
	# help option : prints help and exits 0
	todo_execute_help help
	todo_execute_help --help
	# invalid subcommand: prints error and exits 2
	local error_desc="hey is not a valid command."
	todo_execute_usage_failure "$error_desc" hey
}

# bats --filter "^storage:" test/

@test "storage: initializes and manages files" {
	# fresh run: creates todo.txt
	run "$TODO_SCRIPT" --init-only
	assert_success
	assert_file_exists "$TODO_FILE"
	# existing todo.txt: preserves file content
	todo_seed_storage
	run "$TODO_SCRIPT" --init-only
	assert_success
	todo_assert_storage_persists
}

# bats --filter "^validation:" test/

@test "validation: rejects missing arguments for subcommands" {
	local missing_task_error="Task description cannot be empty."
	local missing_index_error="Task index required."
	# missing task description: prints error and exits 2
	todo_execute_usage_failure "$missing_task_error" add
	# missing task index: prints error and exits 2
	todo_execute_usage_failure "$missing_index_error" del
	todo_execute_usage_failure "$missing_index_error" done
	todo_execute_usage_failure "$missing_index_error" undo
}

@test "validation: handles empty storage precondition" {
	run "$TODO_SCRIPT" --init-only
	[[ -f "$TODO_FILE" ]]
	[[ ! -s "$TODO_FILE" ]]

	run "$TODO_SCRIPT" del 1
	todo_assert_storage_empty del
	run "$TODO_SCRIPT" done 1
	todo_assert_storage_empty done
	run "$TODO_SCRIPT" undo 1
	todo_assert_storage_empty undo
}

# bats --filter "^add:" test/

@test "add: creates storage and appends tasks" {
	# missing todo.txt: initializes storage and inserts task
	todo_execute_add_cmd 1 "${MOCK_TASKS[1]}"
	# existing todo.txt: appends new task
	todo_execute_add_cmd 2 "${MOCK_TASKS[2]}"
	# unquoted task: appends arguments as one task
	local mock_task_unquoted=(${MOCK_TASKS[3]})
	todo_execute_add_cmd 3 "${mock_task_unquoted[@]}"
}

# bats --filter "^del:" test/

@test "del: handles and skips invalid indexes" {
	todo_seed_storage
	# non-numeric index: prints error and exits 2
	todo_execute_invalid_index del text
	todo_assert_storage_persists
	# index zero: prints error and exits 2
	todo_execute_invalid_index del 0
	todo_assert_storage_persists
	# out of bounds index: prints error and exits 2
	todo_execute_invalid_index del 6
	todo_assert_storage_persists
	# valid and invalid indexes: only targets valid indexes
	run "$TODO_SCRIPT" del 0 1
	todo_assert_valid_index "$LABEL_DEL" 1
	todo_assert_invalid_index 0
	todo_assert_tasks_removed 1
}

@test "del: removes tasks corresponding to valid indexes" {
	todo_seed_storage
	# valid index: removes task corresponding to index
	todo_execute_valid_index del "$LABEL_DEL" 1
	todo_assert_tasks_removed 1
	# multiple indexes: removes tasks targeted by index
	todo_execute_valid_index del "$LABEL_DEL" ":2" 1 2 3
	todo_assert_tasks_removed 1 2 3 4
	# one task exists: removes task and prints success message
	todo_execute_valid_index del "$LABEL_DEL" ":5" 1
	todo_assert_storage_empty
}

# bats --filter "^done:" test/

#@test "done: no arguments: prints error and exits 2" {
#	run --separate-stderr "$TODO_SCRIPT" done
#	assert_command_error "Task index required."
#}

#@test "done: invalid task numbers: prints error and leave data intact" {
#	assert_invalid_indexes "done"
#}

#@test "done: task already done: print error and leaves data intact" {
#	seed_todo
#	run_and_assert_index_error "done" "4" "Task 4 is already marked as done."
#	assert_todo_content "$MOCK_TASKS_RENDERED"
#}

#@test "done: empty todo.txt: prints 'empty todo' message and exits 0" {
#	assert_todo_empty "done"
#}

#@test "done: valid index: inserts 'done' mark into line corresponding to index" {
#	seed_todo
#	run "$TODO_SCRIPT" done 6
#	assert_success
#	assert_output "✅ 6  ${MOCK_TASKS[6]}"
#}

#@test "done: multiple indexes: inserts 'done' mark into lines corresponding to indexes provided" {
#	seed_todo
#	run "$TODO_SCRIPT" done 8 9
#	assert_success
#	assert_output "✅ 8  ${MOCK_TASKS[8]}"
#	assert_output "✅ 9  ${MOCK_TASKS[9]}"
#}

#@test "done: valid and invalid indexes: skips invalid indexes and inserts 'done' mark into lines corresponding to valid indexes" {}
