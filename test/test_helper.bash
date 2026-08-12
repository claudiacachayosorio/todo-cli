#!/usr/bin/env bash
# =========================================================================== #
# Description: Helper functions for todo testing suite.

todo_seed_storage() {
	local task_count="${1:-${#MOCK_TASKS[@]}}"
	[[ -d "$DATA_DIR" ]]
	printf "%s\n" "${MOCK_TASKS[@]:1:task_count}" > "$TODO_FILE"
}

todo_assert_storage_persists() {
	[[ -f "$TODO_FILE" ]]
	run cat "$TODO_FILE"
	assert_output "$MOCK_TASKS_RENDERED"
}

todo_assert_new_task() {
	local index="$1"
	[[ -f "$TODO_FILE" ]]
	run cat "$TODO_FILE"
	assert_line --index -1 "${MOCK_TASKS[$index]}"
}

todo_execute_usage_failure() {
	local err_desc="$1"; shift
	local cli_args=("$@")

	run --separate-stderr "$TODO_SCRIPT" "${cli_args[@]}"
	assert_failure 2
	refute_output
	assert_stderr_line --index 0 "ERROR: ${err_desc}"
	assert_stderr_line --index 1 "Try 'bash todo help' for more information."
}

todo_execute_invalid_index() {
	local subcmd="$1" index="$2" err_desc="$3"
	run "$TODO_SCRIPT" "$subcmd" "$index"
	assert_output "⏭️ ${err_desc} Skipping."
	assert_failure 2
}

todo_execute_index_cmd() {
	local subcmd="$1" label="$2"; shift 2
	local indexes=("$@")

	run "$TODO_SCRIPT" "$subcmd" "${indexes[@]}"
	assert_success

	local i; for i in "${indexes[@]}"; do
		assert_output --partial "${label} ${i} ${MOCK_TASKS[$i]}"
	done
}

todo_execute_add_cmd() {
	local new_index="$1"; shift
	local task_words=("$@")

	run "$TODO_SCRIPT" add "${task_words[@]}"
	assert_success
	assert_output "✨ ${new_index} ${task_words[*]}"
}

###

todo_assert_tasks_removed() {
	local removed_tasks_indexes=("$@")
	local mock_tasks=("${MOCK_TASKS[@]}")
	local mock_tasks_updated expected_content

	local i; for i in "${removed_tasks_indexes[@]}"; do
		unset "mock_tasks[$i]"
	done

	mock_tasks_updated=("${mock_tasks[@]}")
	printf -v expected_content "%s\n" "${mock_tasks_updated[@]:1}"
	assert_todo_content "$expected_content"
}
