#!/usr/bin/env bats
# =========================================================================== #
# Description: Test suite for todo-cli project.
# Command:     bats test/

bats_require_minimum_version 1.5.0

readonly BATS_LIB_PATH="${BATS_TEST_DIRNAME}/test_helper"
readonly APP_DIR="$(cd "$BATS_TEST_DIRNAME/.." >/dev/null 2>&1 && pwd)"
readonly APP_SCRIPT="${APP_DIR}/todo"

readonly MOCK_TASKS=(""
	"x refill flour containers"
	"x prep chocolate cake mixes"
	"x test out swiss meringue buttercream recipe"
	"x use up bananas in peanut butter banana bread"
	"x replace scale batteries"
	"research lemon tart recipes"
	"make cookie dough to freeze"
	"taste test lemon cookie recipe"
	"clear out any expired produce"
	"power clean fridge and freezer"
)

setup() {
	bats_load_library bats-support
	bats_load_library bats-assert
	bats_load_library bats-file
	load "test_helper"
	app_setup_tmpdir
	source "$APP_SCRIPT"
}

# bats --filter "^storage:" test/
# =========================================================================== #
@test "storage: fresh run: creates data directory and todo.txt file" {
	[[ ! -d "$MOCK_DATA_DIR" ]]
	run "$APP_SCRIPT" --init-only
	assert_success
	refute_output
	assert_dir_exists "$MOCK_DATA_DIR"
	assert_file_exists "$MOCK_TODO_FILE"
}

#@test "storage: existing todo.txt: preserves file content" {}

# bats --filter "^global:" test/
# =========================================================================== #
@test "global: no arguments: prints help and exits 0" {
	run "$APP_SCRIPT"
	assert_success
	assert_line --index 0 "USAGE"
}

@test "global: invalid subcommand: prints error and exits 2" {
	app_run_command_error "hey" "hey is not a valid command."
}

# bats --filter "^help:" test/
# =========================================================================== #
@test "help: prints help and exits 0" {
	run "$APP_SCRIPT" help
	assert_success
	assert_line --index 0 "USAGE"
}

# bats --filter "^add:" test/
# =========================================================================== #
@test "add: no arguments: prints error and exits 2" {
	app_run_command_error "add" "Task description cannot be empty."
}

#@test "add: missing todo.txt: intializes storage and saves new task" {}

@test "add: existing tod.txt with data: appends new task" {
	local task="feed sourdough starter"
	app_seed_todo

	run "$APP_SCRIPT" add "$task"
	assert_success
	assert_output "✨ 11 ${task}"

	assert_file_exists "$MOCK_TODO_FILE"
	app_run_task_match 11 "$task"
}

# bats --filter "^del:" test/
# =========================================================================== #
#@test "del: no arguments: prints error and exits 2" {
#	app_run_command_error "del" "Task index required."
#}

#@test "del: invalid index numbers: prints error and leaves data intact" {
#	app_run_invalid_index_numbers "del"
#}

#@test "del: empty todo.txt: prints 'empty todo' message and exits 0" {
#	app_run_empty_todo "del"
#}

#@test "del: valid index: removes line corresponding to index" {
#	local tasks=("${MOCK_TASKS[@]}")
#	app_seed_todo

#	run "$APP_SCRIPT" del 6
#	assert_success
#	assert_output "🗑️ 6  ${MOCK_TASKS[6]}"
#	app_run_todo_content 6
#}

#@test "del: multiple indexes: removes lines corresponding to indexes provided" {
#	local tasks=("${MOCK_TASKS[@]}")
#	app_seed_todo

#	run "$APP_SCRIPT" del 1 9
#	assert_success
#	assert_output "🗑️ 1  ${MOCK_TASKS[1]#x }"
#	assert_output "🗑️ 9  ${MOCK_TASKS[9]}"
#	app_run_todo_content 1 9
#}

#@test "del: one task exists: removes line and prints 'empty todo' message" {
#	app_seed_todo_partial 1
#	run "$APP_SCRIPT" del 1
#	assert_success
#	assert_output "🗑️ 1 ${MOCK_TASKS[1]#x }"
#	app_assert_empty_todo
#}

#@test "del: valid and invalid indexes: skips invalid indexes and only removes lines corresponding to valid indexes" {}

# bats --filter "^done:" test/
# =========================================================================== #
#@test "done: no arguments: prints error and exits 2" {
#	app_run_command_error "done" "Task index required."
#}

#@test "done: invalid task numbers: prints error and leave data intact" {
#	app_run_invalid_index_numbers "done"
#}

#@test "done: task already done: print error and leaves data intact" {
#	app_seed_todo
#	app_run_index_error "done" "4" "Task 4 is already marked as done."
#	app_run_todo_content
#}

#@test "done: empty todo.txt: prints 'empty todo' message and exits 0" {
#	app_run_empty_todo "done"
#}

#@test "done: valid index: inserts 'done' mark into line corresponding to index" {
#	app_seed_todo
#	run "$APP_SCRIPT" done 6
#	assert_success
#	assert_output "✅ 6  ${MOCK_TASKS[6]}"
#	app_run_task_match 6 "x ${MOCK_TASKS[6]}"
#}

#@test "done: multiple indexes: inserts 'done' mark into lines corresponding to indexes provided" {
#	app_seed_todo
#	run "$APP_SCRIPT" done 8 9
#	assert_success
#	assert_output "✅ 8  ${MOCK_TASKS[8]}"
#	assert_output "✅ 9  ${MOCK_TASKS[9]}"

#	app_run_task_match 8 "x ${MOCK_TASKS[8]}"
#	app_run_task_match 9 "x ${MOCK_TASKS[9]}"
#}

#@test "done: valid and invalid indexes: skips invalid indexes and inserts 'done' mark into lines corresponding to valid indexes" {}
