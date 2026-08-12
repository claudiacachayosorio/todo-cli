#!/usr/bin/env bats
# =========================================================================== #
# Description: Test suite for todo-cli project.
# Command:     bats test/

bats_require_minimum_version 1.5.0

readonly BATS_LIB_PATH="${BATS_TEST_DIRNAME}/test_helper"
readonly APP_DIR="$(cd "$BATS_TEST_DIRNAME/.." >/dev/null 2>&1 && pwd)"
readonly APP_SCRIPT="${APP_DIR}/todo"

readonly MOCK_TASKS=(""
	"refill flour containers"
	"prep chocolate cake mixes"
	"test out swiss meringue buttercream recipe"
	"use up bananas in peanut butter banana bread"
	"replace scale batteries"
)

printf -v MOCK_TASKS_UNTRIMMED "%s\n" "${MOCK_TASKS[@]:1}"
readonly MOCK_TASKS_RENDERED="${MOCK_TASKS_UNTRIMMED%$'\n'}"
readonly MOCK_TASK_1_UNQUOTED=("refill" "flour" "containers")

setup() {
	bats_load_library bats-support
	bats_load_library bats-assert
	bats_load_library bats-file

	load test_helper
	todo_setup_tmpdir
	source "$APP_SCRIPT"
}

# STORAGE TESTS ============================================================= #
# bats --filter "^storage:" test/

@test "storage: fresh run: creates todo.txt" {
	[[ ! -f "$MOCK_TODO_FILE" ]]
	run "$APP_SCRIPT" --init-only
	assert_success
	assert_file_exists "$MOCK_TODO_FILE"
}

@test "storage: existing todo.txt: preserves file content" {
	todo_seed_storage
	run "$APP_SCRIPT" --init-only
	assert_success
	assert_file_exists "$MOCK_TODO_FILE"
	todo_assert_storage_persists
}

# GLOBAL TESTS ============================================================== #
# bats --filter "^global:" test/

@test "global: no arguments: prints help and exits 0" {
	run "$APP_SCRIPT"
	assert_success
	assert_line --index 0 "USAGE"
}

@test "global: invalid subcommand: prints error and exits 2" {
	local err_desc="hey is not a valid command."
	todo_execute_usage_failure "$err_desc" "hey"
}

# SUBCOMMAND: HELP ========================================================== #
# bats --filter "^help:" test/

@test "help: prints help and exits 0" {
	run "$APP_SCRIPT" help
	assert_success
	assert_line --index 0 "USAGE"
}

# SUBCOMMAND: ADD =========================================================== #
# bats --filter "^add:" test/

@test "add: no arguments: prints error and exits 2" {
	local err_desc="Task description cannot be empty."
	todo_execute_usage_failure "$err_desc" "add"
}

@test "add: missing todo.txt: intializes storage and inserts new task" {
	[[ ! -f "$MOCK_TODO_FILE" ]]
	todo_execute_add_cmd 1 "${MOCK_TASKS[1]}"
	assert_file_exists "$MOCK_TODO_FILE"
	todo_assert_new_task 1
}

@test "add: existing todo.txt with data: appends new task" {
	todo_seed_storage 4
	todo_execute_add_cmd 5 "${MOCK_TASKS[5]}"
	todo_assert_new_task 5
}

@test "add: unquoted task: inserts arguments to todo.txt as one task" {
	touch "$MOCK_TODO_FILE"
	todo_execute_add_cmd 1 "${MOCK_TASK_1_UNQUOTED[@]}"
	todo_assert_new_task 1
}

# SUBCOMMAND: DEL =========================================================== #
# bats --filter "^del:" test/

@test "del: no arguments: prints error and exits 2" {
	local err_desc="Task index required."
	todo_execute_usage_failure "$err_desc" "del"
}

@test "del: invalid indexes: prints error and leaves data intact" {
	todo_seed_storage
	todo_execute_invalid_index "del" "hey" "'hey' is not a number."
	todo_assert_storage_persists
	todo_execute_invalid_index "del" 0 "Task index must be greater than zero."
	todo_assert_storage_persists
	todo_execute_invalid_index "del" 6 "Task 6 does not exists."
	todo_assert_storage_persists
}

@test "del: empty todo.txt: prints 'empty todo' message and exits 0" {
	[[ ! -s "$MOCK_TODO_FILE" ]]
	run "$APP_SCRIPT" del 1
	assert_file_exists "$MOCK_TODO_FILE"
	assert_file_empty "$MOCK_TODO_FILE"
	assert_output "Your todo.txt file is empty!"
	assert_success
}

#@test "del: valid index: removes line corresponding to index" {
#	local tasks=("${MOCK_TASKS[@]}")
#	seed_todo

#	run "$APP_SCRIPT" del 6
#	assert_success
#	assert_output "🗑️ 6  ${MOCK_TASKS[6]}"
#	assert_tasks_removed 6
#}

#@test "del: multiple indexes: removes lines corresponding to indexes provided" {
#	local tasks=("${MOCK_TASKS[@]}")
#	seed_todo

#	run "$APP_SCRIPT" del 1 9
#	assert_success
#	assert_output "🗑️ 1  ${MOCK_TASKS[1]#x }"
#	assert_output "🗑️ 9  ${MOCK_TASKS[9]}"
#	assert_tasks_removed 1 9
#}

#@test "del: one task exists: removes line and prints 'empty todo' message" {
#	seed_todo_partial 1
#	run "$APP_SCRIPT" del 1
#	assert_success
#	assert_output "🗑️ 1 ${MOCK_TASKS[1]#x }"
#	assert_todo_content "$MOCK_TASKS_RENDERED"
#}

#@test "del: valid and invalid indexes: skips invalid indexes and only removes lines corresponding to valid indexes" {}

# SUBCOMMAND: DONE ========================================================== #
# bats --filter "^done:" test/

#@test "done: no arguments: prints error and exits 2" {
#	run --separate-stderr "$APP_SCRIPT" done
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
#	run "$APP_SCRIPT" done 6
#	assert_success
#	assert_output "✅ 6  ${MOCK_TASKS[6]}"
#}

#@test "done: multiple indexes: inserts 'done' mark into lines corresponding to indexes provided" {
#	seed_todo
#	run "$APP_SCRIPT" done 8 9
#	assert_success
#	assert_output "✅ 8  ${MOCK_TASKS[8]}"
#	assert_output "✅ 9  ${MOCK_TASKS[9]}"
#}

#@test "done: valid and invalid indexes: skips invalid indexes and inserts 'done' mark into lines corresponding to valid indexes" {}
