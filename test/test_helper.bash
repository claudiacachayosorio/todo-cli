#!/usr/bin/env bash
# =========================================================================== #
# Description: Helper functions for todo testing suite.

app_setup_tmpdir() {
	export CONFIG_FILE="${BATS_TEST_TMPDIR}/todo.conf"
	export MOCK_DATA_DIR="${BATS_TEST_TMPDIR}/data"
	export MOCK_TODO_FILE="${MOCK_DATA_DIR}/todo.txt"
	printf "DATA_DIR=\"%s\"\n" "$MOCK_DATA_DIR" > "$CONFIG_FILE"
}

app_seed_todo() {
	mkdir -p "$MOCK_DATA_DIR"
	printf "%s\n" "${MOCK_TASKS[@]:1}" > "$MOCK_TODO_FILE"
}

app_seed_todo_partial() {
	mkdir -p "$MOCK_DATA_DIR"
	[[ ! -s "$MOCK_TODO_FILE" ]]
	local mock_task_indexes=("$@")

	local i; for i in "${mock_task_indexes[@]}"; do
		printf "%s\n" "${MOCK_TASKS[$i]}" >> "$MOCK_TODO_FILE"
	done
}

app_run_todo_content() {
	local tasks_removed=("$@")
	local mock_tasks=("${MOCK_TASKS[@]}")
	local updated_mock_tasks expected_file_content

	if [[ $# -gt 0 ]]; then
		local i; for i in "${tasks_removed[@]}"; do
			unset "mock_tasks[$i]"
		done
	else :; fi

	updated_mock_tasks=("${mock_tasks[@]}")
	printf -v expected_file_content "%s\n" "${updated_mock_tasks[@]:1}"

	[[ -f "$MOCK_TODO_FILE" ]]
	run cat "$MOCK_TODO_FILE"
	assert_output "$expected_file_content"
	return 0
}

app_run_command_error() {
	local subcmd="$1" err_desc="$2"
	run --separate-stderr "$APP_SCRIPT" "$subcmd"
	assert_failure 2
	refute_output
	assert_stderr_line --index 0 "ERROR: ${err_desc}"
	assert_stderr_line --index 1 "Try 'bash todo help' for more information."
}

app_run_index_error() {
	local subcmd="$1" index="$2" err_desc="$3"
	run "$APP_SCRIPT" "$subcmd" "$index"
	assert_output "⏭️ ${err_desc} Skipping."
	assert_failure 2
}

app_run_invalid_index_numbers() {
	app_seed_todo
	local subcmd="$1"

	app_run_index_error "$subcmd" "hey" "'hey' is not a number."
	app_run_todo_content

	app_run_index_error "$subcmd" "0" "Task index must be greater than zero."
	app_run_todo_content

	app_run_index_error "$subcmd" "99" "Task 99 does not exists."
	app_run_todo_content
}

app_assert_empty_todo() {
	assert_file_exists "$MOCK_TODO_FILE"
	assert_file_empty "$MOCK_TODO_FILE"
	assert_output "Your todo.txt file is empty!"
}

app_run_empty_todo() {
	local subcmd="$1"
	[[ ! -s "$MOCK_TODO_FILE" ]]

	run "$APP_SCRIPT" "$subcmd" 1
	app_assert_empty_todo
	assert_success
}

app_run_task_match() {
	local index="$1" expected_output="$2"
	run sed -n "${index}p" "$MOCK_TODO_FILE"
	assert_success
	assert_output "$expected_output"
}
