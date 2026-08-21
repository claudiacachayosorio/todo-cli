#!/usr/bin/env bash
# =========================================================================== #
# Description: Helper functions for todo testing suite.

# CONSTANTS & SETTINGS ====================================================== #

bats_require_minimum_version 1.10.0
readonly BATS_LIB_PATH="${BATS_TEST_DIRNAME}/test_helper"
readonly TODO_DIR="$(cd "$BATS_TEST_DIRNAME/.." >/dev/null 2>&1 && pwd)"
readonly TODO_SCRIPT="${TODO_DIR}/todo.sh"

declare -ga TASKS=("")
TASKS[1]="this is the first task"
TASKS[2]="this is the second task"
TASKS[3]="this is the third task"
TASKS[4]="this is the fourth task"
readonly TASKS

declare -gA INDEX_ERRORS
INDEX_ERRORS["index is non-numeric"]="Task index must be number. | string"
INDEX_ERRORS["index is 0"]="Task index must be greater than zero. | 0"
INDEX_ERRORS["index is out-of-bounds"]="Task does not exist. | 5"
INDEX_ERRORS["task is checked"]="Task is already marked as done. | 4"
INDEX_ERRORS["task is unchecked"]="Task is still marked as todo. | 4"
readonly INDEX_ERRORS

todo_setup() {
	bats_load_library bats-support
	bats_load_library bats-assert
	bats_load_library bats-file
	export DATA_DIR="$BATS_TEST_TMPDIR"
	source "$TODO_SCRIPT"
}

# TEST HELPERS ============================================================== #

todo_print_tasks() {
	local task_count="${#TASKS[@]}"
	[[ "${1:-}" =~ ^[0-9]$ ]] && { task_count="$1"; shift; }
	local tasks=("${@:-${TASKS[@]}}")
	touch "$TODO_FILE"
	printf "%s\n" "${tasks[@]:1:$task_count}"
}

todo_assert_storage_empty() {
	assert_file_exists "$TODO_FILE"
	assert_file_empty "$TODO_FILE"
	assert_output --partial "Your todo.txt is empty!"
}

# TODO: keep newlines in outputs (currently false success)
todo_assert_storage_content() {
	local expected_content="${1:-}"
	local actual_content \
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

todo_assert_task_success() {
	local label="$1"
	local index="$2"
	local task="${3:-${TASKS[$index]}}"
	assert_line "${label} line ${index}: \"${task}\""
}

todo_assert_summary() {
	local todo="$1"
	local done="${2:-0}"
	local total; total="$(( todo + done ))"
	local summary="${todo} todo | ${done} done | ${total} total"

	assert_line "$summary"
	if [[ "${#lines[@]}" -gt 1 ]]; then
		assert_output --partial $'\n'$'\n'"$summary"
	else :; fi
}

todo_assert_invalid_index() {
	local error_name="$1"
	local index="${INDEX_ERRORS["$error_name"]#* | }"
	assert_line "Skipping ${index}: ${INDEX_ERRORS["$error_name"]% | *}"
}

todo_execute_mixed_indexes() {
	local subcmd="$1"
	local label="$2"
	shift 2
	local expected_count="${@}"

	run --keep-empty-lines "$TODO_SCRIPT" "$subcmd" 0 4
	assert_success
	todo_assert_invalid_index "index is 0"
	todo_assert_task_success "$label" 4
	todo_assert_summary "${expected_count[@]}"
}

todo_test_invalid_index() {
	local subcmd="$1"
	local error_name="$2"
	local tasks=("${FAILURE_TESTS_TASKS[@]:-${TASKS[@]}}")
	local index="${INDEX_ERRORS["$error_name"]#* | }"

	todo_print_tasks "${tasks[@]}" > "$TODO_FILE"
	run --keep-empty-lines "$TODO_SCRIPT" "$subcmd" "$index"
	assert_failure 2
	todo_assert_invalid_index "$error_name"
	todo_assert_storage_content "${tasks[@]}"
}

todo_register_invalid_index_tests() {
	local subcmd="$1"
	shift
	local index_errors=("$@")
	local error_name

	for error_name in "${index_errors[@]}"; do
		bats_test_function \
			--description "failure: ${error_name}: prints error and exits 2" \
			-- todo_test_invalid_index "$subcmd" "$error_name"
	done
}
