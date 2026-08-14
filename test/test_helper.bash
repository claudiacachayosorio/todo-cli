#!/usr/bin/env bash
# =========================================================================== #
# Description: Helper functions for todo testing suite.

todo_render_mock_tasks() {
	local mock_tasks=("$@")
	printf "%s" "${mock_tasks[1]}"
	local task; for task in "${mock_tasks[@]:2}"; do
		printf "\n%s" "$task"
	done
}

todo_seed_storage() {
	local task_count="${1:-${#MOCK_TASKS[@]}}"
	printf "%s\n" "${MOCK_TASKS[@]:1:task_count}" > "$TODO_FILE"
}

todo_assert_storage_persists() {
	local mock_tasks_rendered
	mock_tasks_rendered="$(todo_render_mock_tasks "${MOCK_TASKS[@]}")"

	[[ -f "$TODO_FILE" ]]
	run cat "$TODO_FILE"
	assert_output "$mock_tasks_rendered"
}

todo_assert_storage_empty() {
	assert_success
	assert_file_exists "$TODO_FILE"
	assert_file_empty "$TODO_FILE"
	assert_output --partial "Your todo.txt file is empty!"
}

todo_execute_help() {
	local subcmd="${1:-}"
	run "$TODO_SCRIPT" "$subcmd"
	assert_success
	assert_line --index 0 "USAGE"
}

todo_assert_exit() {
	local code="$1"
	if [[ "$exit" -eq 0 ]]; then
		assert_success
	else
		assert_failure "$code"
	fi
}

todo_execute_ui_toggle() {
	local icon_plain="$1" exit="$2"
	local subcmd="$3" run_1_arg="$4" run_2_arg="$5"

	NO_COLOR=1 run "$TODO_SCRIPT" "$subcmd" "$run_1_arg"
	todo_assert_exit "$exit"
	assert_output --partial "$icon_plain"

	run "$TODO_SCRIPT" "$subcmd" "$run_2_arg"
	todo_assert_exit "$exit"
	refute_output --partial "$icon_plain"
}

todo_execute_usage_failure() {
	local error_desc="$1"; shift
	local cli_args=("$@")

	run --separate-stderr "$TODO_SCRIPT" "${cli_args[@]}"
	assert_failure 2
	refute_output
	assert_stderr_line --index 0 "ERROR: ${error_desc}"
	assert_stderr_line --index 1 "Try 'bash todo help' for more information."
}

todo_format_cmd_success() {
	local icon="$1" index="$2" start="${3:-1}"
	local mock_tasks=("" "${MOCK_TASKS[@]:$start}")
	printf "%s %s %s\n" "$icon" "$index" "${mock_tasks[$index]}"
}

todo_execute_add_cmd() {
	local index="$1"; shift
	local task_words=("$@")
	local expected_output
	expected_output="$(todo_format_cmd_success "${UI[ADD]}" "$index")"

	run "$TODO_SCRIPT" add "${task_words[@]}"
	assert_success
	assert_output "$expected_output"

	assert_file_exists "$TODO_FILE"
	run cat "$TODO_FILE"
	assert_line --index -1 "${MOCK_TASKS[$index]}"
}

todo_assert_valid_index() {
	local expected_output
	expected_output="$(todo_format_cmd_success "$@")"
	assert_success
	assert_output --partial "$expected_output"
}

todo_execute_valid_index() {
	local subcmd="$1" icon="$2"; shift 2
	local start=""
	if [[ "$1" =~ ^: ]]; then start="${1#:}"; shift; else :; fi

	local indexes=("$@")
	local expected_output
	run "$TODO_SCRIPT" "$subcmd" "${indexes[@]}"
	assert_success

	local i; for i in "${indexes[@]}"; do
		expected_output="$(todo_format_cmd_success "$icon" "$i" "$start")"
		assert_output --partial "$expected_output"
	done
}

todo_format_index_error() {
	declare -A index_errors
	index_errors[text]="'text' is not a number."
	index_errors[0]="Task index must be greater than zero."
	index_errors[6]="Task 6 does not exist."

	local invalid_index="$1"
	printf "%s %s Skipping.\n" "${UI[SKIP]}" "${index_errors["$invalid_index"]}"
}

todo_assert_invalid_index() {
	local invalid_index="$1"
	local expected_output
	expected_output="$(todo_format_index_error "$invalid_index")"
	assert_output --partial "$expected_output"
}

todo_execute_invalid_index() {
	local subcmd="$1" invalid_index="$2"
	local expected_output
	expected_output="$(todo_format_index_error "$invalid_index")"
	run "$TODO_SCRIPT" "$subcmd" "$invalid_index"
	assert_output "$expected_output"
	assert_failure 2
}

todo_assert_tasks_removed() {
	local removed_tasks=("$@")
	local mock_tasks=("${MOCK_TASKS[@]}")
	local expected_file_content

	local i; for i in "${removed_tasks[@]}"; do
		unset "mock_tasks[$i]"
	done
	mock_tasks=("${mock_tasks[@]}")

	expected_file_content="$(todo_render_mock_tasks "${mock_tasks[@]}")"
	run cat "$TODO_FILE"
	assert_output "$expected_file_content"
}
