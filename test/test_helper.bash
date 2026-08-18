#!/usr/bin/env bash
# =========================================================================== #
# Description: Helper functions for todo testing suite.

# SETTINGS ================================================================== #

bats_require_minimum_version 1.5.0

readonly BATS_LIB_PATH="${BATS_TEST_DIRNAME}/test_helper"
readonly TODO_DIR="$(cd "$BATS_TEST_DIRNAME/.." >/dev/null 2>&1 && pwd)"
readonly TODO_SCRIPT="${TODO_DIR}/todo"

declare -g TASKS=("")
TASKS[1]="this is the first task"
TASKS[2]="this is the second task"
TASKS[3]="this is the third task"
TASKS[4]="this is the fourth task"
readonly TASKS

todo_setup() {
	bats_load_library bats-support
	bats_load_library bats-assert
	bats_load_library bats-file
	export DATA_DIR="$BATS_TEST_TMPDIR"
}

# HELPERS =================================================================== #

todo_assert_storage_empty() {
	assert_file_exists "$TODO_FILE"
	assert_file_empty "$TODO_FILE"
	assert_output --partial "Your todo.txt is empty!"
}

todo_assert_storage_content() {
	local expected="${1:-}"
	if [[ -z "$expected" ]]; then
		printf -v expected "%s\n" "${TASKS[@]:1}"
	fi

	assert_file_exists "$TODO_FILE"
	run --keep-empty-lines cat "$TODO_FILE"
	assert_output "$expected"
}

todo_execute_usage_failure() {
	local error_desc="$1"
	shift
	local cli_args=("$@")

	run --separate-stderr "$TODO_SCRIPT" "${cli_args[@]}"
	assert_failure 2
	refute_output
	assert_stderr "ERROR: ${error_desc}"
}

todo_assert_summary() {
	local todo="${1:-0}" \
	      done="${2:-0}" \
				total \
	      summary

	total="$(( todo + done ))"
	summary="${todo} todo | ${done} done | ${total} total"
	assert_line "$summary"

	if [[ "${#lines[@]}" -gt 1 ]]; then
		assert_output --partial $'\n'"${todo} todo"
	else :; fi
}

todo_assert_task_success() {
	local label="$1" \
	      index="$2"
	local task="${3:-${TASKS[$index]}}"
	assert_line "${label} line ${index}: \"${task}\""
}

todo_execute_add_cmd() {
	local index="$1"
	shift
	local task_words=("$@") \
	      task="$*"

	run --keep-empty-lines "$TODO_SCRIPT" "add" "${task_words[@]}"
	assert_success
	todo_assert_task_success "[+] Added" "$index" "$task"
}

todo_execute_valid_index() {
	local subcmd="$1" \
	      label="$2"
	shift 2
	local prefix="" \
	      task=""

	[[ ! "$1" =~ ^[0-9]$ ]] && prefix="$1"; shift
	local i indexes=("$@")

	run --keep-empty-lines "$TODO_SCRIPT" "$subcmd" "${indexes[@]}"
	assert_success

	for i in "${indexes[@]}"; do
		if [[ -n "$prefix" ]]; then task="${prefix}${TASKS[$i]}"; fi
		todo_assert_task_success "$label" "$i" "$task"
	done
}

todo_assert_invalid_index() {
	local index="$1"
	local error="${2:-$index}"

	local -A index_errors
	index_errors[text]="Task index must be number."
	index_errors[0]="Task index must be greater than zero."
	index_errors["${#TASKS[@]}"]="Task does not exist."
	index_errors[checked]="Task is already marked as done."
	index_errors[unchecked]="Task is still marked as todo."

	assert_line "Skipping ${index}: ${index_errors[$error]}"
}

todo_execute_invalid_index() {
	local subcmd="$1" \
	      index="$2"
	local error="${3:-$index}"

	run "$TODO_SCRIPT" "$subcmd" "$index"
	todo_assert_invalid_index "$index" "$error"
	assert_failure 2
}
