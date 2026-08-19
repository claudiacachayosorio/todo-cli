#!/usr/bin/env bash
# =========================================================================== #
# Description: Helper functions for todo testing suite.

# SETTINGS ================================================================== #

bats_require_minimum_version 1.10.0

readonly BATS_LIB_PATH="${BATS_TEST_DIRNAME}/test_helper"
readonly TODO_DIR="$(cd "$BATS_TEST_DIRNAME/.." >/dev/null 2>&1 && pwd)"
readonly TODO_SCRIPT="${TODO_DIR}/todo"

declare -g TASKS=("")
TASKS[1]="this is the first task"
TASKS[2]="this is the second task"
TASKS[3]="this is the third task"
TASKS[4]="this is the fourth task"
readonly TASKS

declare -gA INDEX_ERRORS
INDEX_ERRORS["non-numeric"]="Task index must be number. | string"
INDEX_ERRORS["0"]="Task index must be greater than zero. | 0"
INDEX_ERRORS["out-of-bounds"]="Task does not exist. | 5"
INDEX_ERRORS["checked"]="Task is already marked as done. | 1"
INDEX_ERRORS["unchecked"]="Task is still marked as todo. | 1"
readonly INDEX_ERRORS

todo_setup() {
	bats_load_library bats-support
	bats_load_library bats-assert
	bats_load_library bats-file
	export DATA_DIR="$BATS_TEST_TMPDIR"
}

# HELPERS =================================================================== #

todo_print_tasks() {
	local task_count="${#TASKS[@]}"
	[[ "${1:-}" =~ ^[0-9]$ ]] && { task_count="$1"; shift; }
	local tasks=("${@:-${TASKS[@]}}")
	printf "%s\n" "${tasks[@]:1:$task_count}"
}

todo_assert_storage_empty() {
	assert_file_exists "$TODO_FILE"
	assert_file_empty "$TODO_FILE"
	assert_output --partial "Your todo.txt is empty!"
}

todo_assert_storage_content() {
	local expected_content="${1:-}" \
				actual_content \
	      tasks

	if [[ $# -ne 1 ]]; then
		tasks=("${@:-}")
		run todo_print_tasks "${tasks[@]}"
		assert_success
		expected_content="$output"
	fi

	assert_file_exists "$TODO_FILE"
	run cat "$TODO_FILE"
	assert_success
	actual_content="$output"
	assert_equal "$actual_content" "$expected_content"
}

todo_assert_usage_failure() {
	local error_desc="$1"
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

todo_execute_valid_index() {
	local subcmd="$1" \
	      label="$2"
	shift 2
	local prefix="" \
	      task=""

	[[ ! "$1" =~ ^[0-9]$ ]] && { prefix="$1"; shift; }
	local i indexes=("$@")

	run --keep-empty-lines "$TODO_SCRIPT" "$subcmd" "${indexes[@]}"
	assert_success

	for i in "${indexes[@]}"; do
		if [[ -n "$prefix" ]]; then task="${prefix}${TASKS[$i]}"; fi
		todo_assert_task_success "$label" "$i" "$task"
	done
}

todo_assert_invalid_index() {
	local error="$1"
	local index="${INDEX_ERRORS["$error"]#* | }"
	assert_stderr_line "Skipping ${index}: ${INDEX_ERRORS["$error"]% | *}"
}

todo_test_invalid_index() {
	local subcmd="$1" \
	      error="$2"
	local index="${INDEX_ERRORS["$error"]#* | }"

	run --separate-stderr "$TODO_SCRIPT" "$subcmd" "$index"
	todo_assert_invalid_index "$error"
	assert_failure 2
	todo_assert_storage_content
}

todo_execute_mixed_indexes() {
	local subcmd="$1" \
	      label="$2"
	shift 2
	local expected_count="${@}"

	run --keep-empty-lines --separate-stderr "$TODO_SCRIPT" "$subcmd" 0 4
	assert_success
	todo_assert_invalid_index 0
	todo_assert_task_success "$label" 4
	todo_assert_summary "${expected_count[@]}"
}
