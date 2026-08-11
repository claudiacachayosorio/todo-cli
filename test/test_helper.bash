#!/usr/bin/env bash
# =========================================================================== #
# Description: Helper functions for todo testing suite.

todo_setup_tmpdir() {
	export CONFIG_FILE="${BATS_TEST_TMPDIR}/todo.conf"
	export MOCK_DATA_DIR="${BATS_TEST_TMPDIR}/data"
	export MOCK_TODO_FILE="${MOCK_DATA_DIR}/todo.txt"
	printf "DATA_DIR=\"%s\"\n" "$MOCK_DATA_DIR" > "$CONFIG_FILE"
}

todo_seed_all() {
	mkdir -p "$MOCK_DATA_DIR"
	printf "%s\n" "${MOCK_TASKS[@]:1}" > "$MOCK_TODO_FILE"
}

todo_inspect_storage() {
	[[ -f "$MOCK_TODO_FILE" ]]
	run cat "$MOCK_TODO_FILE"
}

todo_assert_cmd_fails() {
	local err_desc="$1"
	assert_failure 2
	refute_output
	assert_stderr_line --index 0 "ERROR: ${err_desc}"
	assert_stderr_line --index 1 "Try 'bash todo help' for more information."
}

todo_assert_invalid_index() {
	local err_desc="$1"
	assert_output "⏭️ ${err_desc} Skipping."
	assert_failure 2
}

todo_assert_storage_empty() {
	assert_file_exists "$MOCK_TODO_FILE"
	assert_file_empty "$MOCK_TODO_FILE"
	assert_output "Your todo.txt file is empty!"
	assert_success
}

###

todo_seed_partial() {
	local mock_task_indexes=("$@")
	mkdir -p "$MOCK_DATA_DIR"
	[[ ! -s "$MOCK_TODO_FILE" ]]

	local i; for i in "${mock_task_indexes[@]}"; do
		printf "%s\n" "${MOCK_TASKS[$i]}" >> "$MOCK_TODO_FILE"
	done
}

todo_assert_storage_exists() {
	assert_dir_exists "$MOCK_DATA_DIR"
	assert_file_exists "$MOCK_TODO_FILE"
}

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

todo_assert_cmd_success() {
	local subcmd="$1" label="$2"; shift 2
	local indexes=("$@")
	local task_output

	seed_todo
	run "$APP_SCRIPT" "$subcmd" "${indexes[@]}"
	assert_success

	local i; for i in "${indexes[@]}"; do
		printf -v task_output "%s %-2s %s\n" "$label" "$i" "${MOCK_TASKS[$i]#x }"
		assert_output --partial "$task_output"
	done
}
