#!/usr/bin/env bats
# =========================================================================== #
# Description: Test suite for todo-cli project.
# Command:     bats test/

# SETUP ===================================================================== #

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

# MAIN SCRIPT =============================================================== #

@test "script creates data directory and todo.txt file if missing" {
	[[ ! -d "$MOCK_DATA_DIR" ]]
	run "$APP_SCRIPT" --init-only
	assert_success
	refute_output
	assert [ -d "$MOCK_DATA_DIR" ]
	assert [ -f "$MOCK_TODO_FILE" ]
}

@test "script prints usage guide when no arguments are provided" {
	run "$APP_SCRIPT"
	assert_success
	assert_line --index 0 "USAGE"
}

@test "script rejects invalid command" {
	app_run_command_error "hey" "hey is not a valid command."
}

# SUBCOMMAND: HELP ========================================================== #

@test "subcommand: 'help' prints usage guide" {
	run "$APP_SCRIPT" help
	assert_success
	assert_line --index 0 "USAGE"
}

# SUBCOMMAND: ADD =========================================================== #

@test "subcommand: 'add' fails without arguments" {
	app_run_command_error "add" "Task description cannot be empty."
}

@test "subcommand: 'add' appends a new line with the provided task string" {
	local task="feed sourdough starter"
	app_seed_todo

	run "$APP_SCRIPT" add "$task"
	assert_success
	assert_output "✨ 11 ${task}"

	assert [ -f "$MOCK_TODO_FILE" ]
	app_run_task_match 11 "$task"
}

# SUBCOMMAND: DEL =========================================================== #

#@test "subcommand: 'del' fails without arguments" {
#	app_run_command_error "del" "Task index required."
#}

#@test "subcommand: 'del' skips invalid task index numbers" {
#	app_run_invalid_index_numbers "del"
#}

#@test "subcommand: 'del' prints a message and exits when todo.txt is already empty" {
#	app_run_empty_todo "del"
#}

#@test "subcommand: 'del' removes a task when provided with its corresponding index" {
#	local tasks=("${MOCK_TASKS[@]}")
#	app_seed_todo

#	run "$APP_SCRIPT" del 6
#	assert_success
#	assert_output "🗑️ 6  ${MOCK_TASKS[6]}"

#	unset "tasks[6]"
#	tasks=("${tasks[@]}")
#	app_run_diff_todo "${tasks[@]}"
#}

#@test "subcommand: 'del' removes multiple tasks when provided with their corresponding indexes" {
#	local tasks=("${MOCK_TASKS[@]}")
#	app_seed_todo

#	run "$APP_SCRIPT" del 1 9
#	assert_success
#	assert_output "🗑️ 1  ${MOCK_TASKS[1]#x }"
#	assert_output "🗑️ 9  ${MOCK_TASKS[9]}"

#	unset "tasks[1]" "tasks[9]"
#	tasks=("${tasks[@]}")
#	app_run_diff_todo "${tasks[@]}"
#}

#@test "subcommand: 'del' prints a message when the last task is deleted" {
#	app_seed_todo_partial 1
#	run "$APP_SCRIPT" del 1
#	assert_success
#	assert_output "🗑️ 1 ${MOCK_TASKS[1]#x }"
#	app_assert_empty_todo
#}

# SUBCOMMAND: DONE ========================================================== #

#@test "subcommand: 'done' fails without arguments" {
#	app_run_command_error "done" "Task index required."
#}

#@test "subcommand: 'done' skips invalid task index numbers" {
#	app_run_invalid_index_numbers "done"
#}

#@test "subcommand: 'done' skips task already marked as done" {
#	app_seed_todo
#	app_run_index_error "done" "4" "Task 4 is already marked as done."
#	app_run_diff_todo "${MOCK_TASKS[@]}"
#}

#@test "subcommand: 'done' prints a success message when todo.txt is empty" {
#	app_run_empty_todo "done"
#}

#@test "subcommand: 'done' marks task as done when provided with its corresponding index" {
#	app_seed_todo
#	run "$APP_SCRIPT" done 6
#	assert_success
#	assert_output "✅ 6  ${MOCK_TASKS[6]}"
#	app_run_task_match 6 "x ${MOCK_TASKS[6]}"
#}

#@test "subcommand: 'done' marks multiple tasks as done when provided with their corresponding indexes" {
#	app_seed_todo
#	run "$APP_SCRIPT" done 8 9
#	assert_success
#	assert_output "✅ 8  ${MOCK_TASKS[8]}"
#	assert_output "✅ 9  ${MOCK_TASKS[9]}"

#	app_run_task_match 8 "x ${MOCK_TASKS[8]}"
#	app_run_task_match 9 "x ${MOCK_TASKS[9]}"
#}
