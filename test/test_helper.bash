#!/usr/bin/env bash
# =========================================================================== #
# Description: Helper functions for todo testing suite.

# VARIABLES ================================================================= #

declare -g TASKS=("")
TASKS[1]="prepare cake mixes"
TASKS[2]="test buttercream recipe"
TASKS[3]="refill flour containers"
TASKS[4]="make banana bread"
readonly TASKS

# FUNCTIONS ================================================================= #

todo_seed_storage() {
	local task_count="${1:-${#TASKS[@]}}"
	printf "%s\n" "${TASKS[@]:1:task_count}" > "$TODO_FILE"
}

todo_assert_storage_empty() {
	assert_success
	assert_file_exists "$TODO_FILE"
	assert_file_empty "$TODO_FILE"
	assert_output "Your todo.txt file is empty!"
}

todo_assert_storage_content() {
	local expected="${1:-}"
	[[ -z "$expected" ]] && printf -v expected "%s\n" "${TASKS[@]:1}"

	[[ -f "$TODO_FILE" ]]
	run --keep-empty-lines cat "$TODO_FILE"
	assert_output "$expected"
}

todo_execute_help() {
	local subcmd="${1:-}"
	run "$TODO_SCRIPT" "$subcmd"
	assert_success
	assert_line --index 0 "USAGE"
}

todo_execute_usage_failure() {
	local error_desc="$1"; shift
	local cli_args=("$@")
	run --separate-stderr "$TODO_SCRIPT" "${cli_args[@]}"
	assert_failure 2
	refute_output
	assert_stderr_line --index 0 "ERROR: $error_desc"
}

todo_assert_confirmation() {
	local label="$1" index="$2"
	assert_output --partial "${label} line ${index}: \"${TASKS[$index]}\""
}

todo_execute_add_cmd() {
	local index="$1"; shift
	local task_words=("$@")

	run "$TODO_SCRIPT" "add" "${task_words[@]}"
	assert_success
	todo_assert_confirmation "[+] Added" "$index"
}

todo_execute_valid_index() {
	local subcmd="$1" label="$2"; shift 2
	local indexes=("$@")
	local expected_output

	run "$TODO_SCRIPT" "$subcmd" "${indexes[@]}"
	assert_success
	local i; for i in "${indexes[@]}"; do
		todo_assert_confirmation "$label" "$i"
	done
}

todo_assert_invalid_index() {
	declare -A index_errors
	index_errors[text]="Task index must be number."
	index_errors[0]="Task index must be greater than zero."
	index_errors[5]="Task does not exist."

	local index="$1"
	assert_output --partial "Skipping ${index}: ${index_errors[$index]}"
}

todo_execute_invalid_index() {
	local subcmd="$1" index="$2"
	run "$TODO_SCRIPT" "$subcmd" "$index"
	todo_assert_invalid_index "$index"
	assert_failure 2
}
