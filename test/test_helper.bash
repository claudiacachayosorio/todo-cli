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
	local i; for i in "$@"; do
		printf "%s\n" "${MOCK_TASKS[$i]}" >> "$MOCK_TODO_FILE"
	done
}

app_run_diff_todo() {
	local mock_tasks="$@"
	[[ -f "$MOCK_TODO_FILE" ]]
	run diff "$MOCK_TODO_FILE" <(printf "%s\n" "${mock_tasks[@]:1}")
	assert_success
	refute_output
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
	local subcmd="$1"
	app_seed_todo

	app_run_index_error "$subcmd" "hey" "'hey' is not a number."
	app_run_diff_todo "${MOCK_TASKS[@]}"

	app_run_index_error "$subcmd" "0" "Task index must be greater than zero."
	app_run_diff_todo "${MOCK_TASKS[@]}"

	app_run_index_error "$subcmd" "99" "Task 99 does not exists."
	app_run_diff_todo "${MOCK_TASKS[@]}"
}

app_assert_empty_todo() {
	assert [[ -f "$MOCK_TODO_FILE" ]]
	refute [[ -s "$MOCK_TODO_FILE" ]]
	assert_output "Your todo.txt file is empty!"
}

app_run_empty_todo() {
	local subcmd="$1"
	[[ ! -s "$MOCK_TODO_FILE" ]]
	run "$APP_SCRIPT" "$subcmd" 1
	assert_success
	app_assert_empty_todo
}

app_run_task_match() {
	local index="$1" expected_output="$2"
	run sed -n "${index}p" "$MOCK_TODO_FILE"
	assert_success
	assert_output "$expected_output"
}
