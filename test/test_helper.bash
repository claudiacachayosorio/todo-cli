#!/usr/bin/env bash
# =========================================================================== #
# Description: Helper functions for todo testing suite.

# VARIABLES ================================================================= #

declare -g TASKS=("")
TASKS[1]="this is the first task"
TASKS[2]="this is the second task"
TASKS[3]="this is the third task"
TASKS[4]="this is the fourth task"
readonly TASKS

# FUNCTIONS ================================================================= #

todo_assert_storage_empty() {
	assert_success
	assert_file_exists "$TODO_FILE"
	assert_file_empty "$TODO_FILE"
	assert_output "todo.txt is empty!"
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
	assert_stderr "ERROR: $error_desc"
}

todo_assert_task_success() {
	local label="$1" index="$2"
	local task="${3:-${TASKS[$index]}}"
	assert_line "${label} line ${index}: \"${task}\""
}

todo_assert_summary() {
	local todo="${1:-4}" done="${2:-0}"
	local total; total="$(( todo + done ))"
	assert_line --index -2 ""
	assert_line --index -1 "${todo} todo | ${done} done | ${total} total"
}

todo_execute_add_cmd() {
	local index="$1"; shift
	local task_words=("$@")
	local task="$*"

	run --keep-empty-lines "$TODO_SCRIPT" "add" "${task_words[@]}"
	assert_success
	todo_assert_task_success "[+] Added" "$index" "$task"
}

todo_execute_valid_index() {
	local subcmd="$1" label="$2"; shift 2
	local indexes=("$@")

	run --keep-empty-lines "$TODO_SCRIPT" "$subcmd" "${indexes[@]}"
	assert_success
	local i; for i in "${indexes[@]}"; do
		todo_assert_task_success "$label" "$i"
	done
}

todo_assert_invalid_index() {
	declare -A index_errors
	index_errors[text]="Task index must be number."
	index_errors[0]="Task index must be greater than zero."
	index_errors[5]="Task does not exist."

	local index="$1"
	assert_line "Skipping ${index}: ${index_errors[$index]}"
}

todo_execute_invalid_index() {
	local subcmd="$1" index="$2"
	run "$TODO_SCRIPT" "$subcmd" "$index"
	todo_assert_invalid_index "$index"
	assert_failure 2
}
