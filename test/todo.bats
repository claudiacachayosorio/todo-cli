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
	"buy vanilla paste"
	"make cookie dough to freeze"
	"taste test lemon cookie recipe"
	"clear out any expired produce"
	"power clean fridge and freezer"
)

printf -v MOCK_TASKS_UNTRIMMED "%s\n" "${MOCK_TASKS[@]:1}"
readonly MOCK_TASKS_RENDERED="${MOCK_TASKS_UNTRIMMED%$'\n'}"

readonly MOCK_NEW_TASK="feed sourdough starter"
readonly MOCK_NEW_TASK_UNQUOTED=("feed" "sourdough" "starter")

setup() {
	bats_load_library bats-support
	bats_load_library bats-assert
	bats_load_library bats-file
	load "test_helper"
	setup_tmpdir
	source "$APP_SCRIPT"
}

# STORAGE TESTS ============================================================= #
# bats --filter "^storage:" test/

@test "storage: fresh run: creates data directory and todo.txt" {
	[[ ! -d "$MOCK_DATA_DIR" ]]
	[[ ! -f "$MOCK_TODO_FILE" ]]

	run "$APP_SCRIPT" --init-only
	assert_success
	assert_dir_exists "$MOCK_DATA_DIR"
	assert_file_exists "$MOCK_TODO_FILE"
}

@test "storage: existing todo.txt: preserves file content" {
	seed_todo

	run "$APP_SCRIPT" --init-only
	assert_success
	assert_file_exists "$MOCK_TODO_FILE"

	run cat "$MOCK_TODO_FILE"
	assert_output "$MOCK_TASKS_RENDERED"
}

# GLOBAL TESTS ============================================================== #
# bats --filter "^global:" test/

@test "global: no arguments: prints help and exits 0" {
	run "$APP_SCRIPT"
	assert_success
	assert_line --index 0 "USAGE"
}

@test "global: invalid subcommand: prints error and exits 2" {
	run_and_assert_command_error "hey" "hey is not a valid command."
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
	run_and_assert_command_error "add" "Task description cannot be empty."
}

@test "add: missing todo.txt: intializes storage and inserts new task" {
	[[ ! -d "$MOCK_DATA_DIR" ]]
	[[ ! -f "$MOCK_TODO_FILE" ]]

	run "$APP_SCRIPT" add "$MOCK_NEW_TASK"
	assert_new_task_success 1

	assert_dir_exists "$MOCK_DATA_DIR"
	assert_file_exists "$MOCK_TODO_FILE"

	run cat "$MOCK_TODO_FILE"
	assert_output "$MOCK_NEW_TASK"
}

@test "add: existing todo.txt with data: appends new task" {
	seed_todo

	run "$APP_SCRIPT" add "$MOCK_NEW_TASK"
	assert_new_task_success 11

	[[ -f "$MOCK_TODO_FILE" ]]
	run cat "$MOCK_TODO_FILE"
	assert_line --index 10 "$MOCK_NEW_TASK"
}

@test "add: unquoted task: inserts arguments to todo.txt as one task" {
	seed_todo

	run "$APP_SCRIPT" add "${MOCK_NEW_TASK_UNQUOTED[@]}"
	assert_new_task_success 11

	[[ -f "$MOCK_TODO_FILE" ]]
	run cat "$MOCK_TODO_FILE"
	assert_line --index 10 "$MOCK_NEW_TASK"
}

# SUBCOMMAND: DEL =========================================================== #
# bats --filter "^del:" test/

#@test "del: no arguments: prints error and exits 2" {
#	run_and_assert_command_error "del" "Task index required."
#}

#@test "del: invalid index numbers: prints error and leaves data intact" {
#	run_and_assert_invalid_indexes "del"
#}

#@test "del: empty todo.txt: prints 'empty todo' message and exits 0" {
#	run_and_assert_todo_empty "del"
#}

#@test "del: valid index: removes line corresponding to index" {
#	local tasks=("${MOCK_TASKS[@]}")
#	seed_todo

#	run "$APP_SCRIPT" del 6
#	assert_success
#	assert_output "🗑️ 6  ${MOCK_TASKS[6]}"
#	run_and_assert_tasks_removed 6
#}

#@test "del: multiple indexes: removes lines corresponding to indexes provided" {
#	local tasks=("${MOCK_TASKS[@]}")
#	seed_todo

#	run "$APP_SCRIPT" del 1 9
#	assert_success
#	assert_output "🗑️ 1  ${MOCK_TASKS[1]#x }"
#	assert_output "🗑️ 9  ${MOCK_TASKS[9]}"
#	run_and_assert_tasks_removed 1 9
#}

#@test "del: one task exists: removes line and prints 'empty todo' message" {
#	seed_todo_partial 1
#	run "$APP_SCRIPT" del 1
#	assert_success
#	assert_output "🗑️ 1 ${MOCK_TASKS[1]#x }"
#	run_and_assert_todo_content "$MOCK_TASKS_RENDERED"
#}

#@test "del: valid and invalid indexes: skips invalid indexes and only removes lines corresponding to valid indexes" {}

# SUBCOMMAND: DONE ========================================================== #
# bats --filter "^done:" test/

#@test "done: no arguments: prints error and exits 2" {
#	run_and_assert_command_error "done" "Task index required."
#}

#@test "done: invalid task numbers: prints error and leave data intact" {
#	run_and_assert_invalid_indexes "done"
#}

#@test "done: task already done: print error and leaves data intact" {
#	seed_todo
#	app_run_index_error "done" "4" "Task 4 is already marked as done."
#	app_run_todo_content
#}

#@test "done: empty todo.txt: prints 'empty todo' message and exits 0" {
#	run_and_assert_todo_empty "done"
#}

#@test "done: valid index: inserts 'done' mark into line corresponding to index" {
#	seed_todo
#	run "$APP_SCRIPT" done 6
#	assert_success
#	assert_output "✅ 6  ${MOCK_TASKS[6]}"
#	app_run_task_match 6 "x ${MOCK_TASKS[6]}"
#}

#@test "done: multiple indexes: inserts 'done' mark into lines corresponding to indexes provided" {
#	seed_todo
#	run "$APP_SCRIPT" done 8 9
#	assert_success
#	assert_output "✅ 8  ${MOCK_TASKS[8]}"
#	assert_output "✅ 9  ${MOCK_TASKS[9]}"

#	app_run_task_match 8 "x ${MOCK_TASKS[8]}"
#	app_run_task_match 9 "x ${MOCK_TASKS[9]}"
#}

#@test "done: valid and invalid indexes: skips invalid indexes and inserts 'done' mark into lines corresponding to valid indexes" {}
