#!/usr/bin/env bash
# =========================================================================== #
# Description: Helper functions for todo testing suite.

setup_tmpdir() {
	export CONFIG_FILE="${BATS_TEST_TMPDIR}/todo.conf"
	export MOCK_DATA_DIR="${BATS_TEST_TMPDIR}/data"
	export MOCK_TODO_FILE="${MOCK_DATA_DIR}/todo.txt"
	printf "DATA_DIR=\"%s\"\n" "$MOCK_DATA_DIR" > "$CONFIG_FILE"
}

seed_todo() {
	mkdir -p "$MOCK_DATA_DIR"
	printf "%s\n" "${MOCK_TASKS[@]:1}" > "$MOCK_TODO_FILE"
}

seed_todo_partial() {
	mkdir -p "$MOCK_DATA_DIR"
	[[ ! -s "$MOCK_TODO_FILE" ]]

	local mock_task_indexes=("$@")
	local i; for i in "${mock_task_indexes[@]}"; do
		printf "%s\n" "${MOCK_TASKS[$i]}" >> "$MOCK_TODO_FILE"
	done
}

run_and_assert_todo_content() {
	local expected_content="$1"
	[[ -f "$MOCK_TODO_FILE" ]]
	run cat "$MOCK_TODO_FILE"
	assert_output "$expected_content"
}

run_and_assert_tasks_removed() {
	local removed_tasks_indexes=("$@")
	local mock_tasks=("${MOCK_TASKS[@]}")
	local mock_tasks_updated expected_content

	local i; for i in "${removed_tasks_indexes[@]}"; do
		unset "mock_tasks[$i]"
	done

	mock_tasks_updated=("${mock_tasks[@]}")
	printf -v expected_content "%s\n" "${mock_tasks_updated[@]:1}"
	run_and_assert_todo_content "$expected_content"
}

run_and_assert_command_error() {
	local subcmd="$1" err_desc="$2"
	run --separate-stderr "$APP_SCRIPT" "$subcmd"
	assert_failure 2
	refute_output
	assert_stderr_line --index 0 "ERROR: ${err_desc}"
	assert_stderr_line --index 1 "Try 'bash todo help' for more information."
}

run_and_assert_index_error() {
	local subcmd="$1" index="$2" err_desc="$3"
	run "$APP_SCRIPT" "$subcmd" "$index"
	assert_output "⏭️ ${err_desc} Skipping."
	assert_failure 2
}

run_and_assert_invalid_indexes() {
	local subcmd="$1"
	app_seed_todo
	run_and_assert_index_error "$subcmd" "hey" "'hey' is not a number."
	run_and_assert_todo_content "$MOCK_TASKS_RENDERED"
	run_and_assert_index_error "$subcmd" "0" "Task index must be greater than zero."
	run_and_assert_todo_content "$MOCK_TASKS_RENDERED"
	run_and_assert_index_error "$subcmd" "99" "Task 99 does not exists."
	run_and_assert_todo_content "$MOCK_TASKS_RENDERED"
}

assert_todo_empty() {
	assert_file_exists "$MOCK_TODO_FILE"
	assert_file_empty "$MOCK_TODO_FILE"
	assert_output "Your todo.txt file is empty!"
}

run_and_assert_todo_empty() {
	local subcmd="$1"
	[[ ! -s "$MOCK_TODO_FILE" ]]
	run "$APP_SCRIPT" "$subcmd" 1
	assert_todo_empty
	assert_success
}
