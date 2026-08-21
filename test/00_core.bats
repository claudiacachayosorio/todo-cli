#!/usr/bin/env bats
# =========================================================================== #
# Description: Testing suite for todo-cli's core functions.
# Command:     bats test/00_core.bats

load test_helper
setup() {
	todo_setup
}

@test "storage: missing todo.txt: creates file" {
	run "$TODO_SCRIPT" --init-only
	assert_success
	assert_file_exists "$TODO_FILE"
}

@test "storage: existing data: preserves data" {
	todo_print_tasks > "$TODO_FILE"
	run "$TODO_SCRIPT" --init-only
	assert_success
	todo_assert_storage_content
}

todo_test_missing_args() {
	local subcmd="$1"
	local error_desc="Task index required."

	if [[ "$subcmd" == "add" ]]; then
		error_desc="Task description cannot be empty."
	fi
	run --separate-stderr "$TODO_SCRIPT" "$subcmd"
	todo_assert_usage_failure "$error_desc"
}
todo_register_missing_args_tests() {
	local subcmds=("$@")
	local subcmd
	for subcmd in "${subcmds[@]}"; do
		bats_test_function \
			--description "validation: missing args (${subcmd}): prints error and exits 2" \
			-- todo_test_missing_args "$subcmd"
	done
}
todo_register_missing_args_tests \
"add" \
"do" \
"undo" \
"del"

todo_test_missing_data() {
	local subcmd="$1"
	run "$TODO_SCRIPT" "$subcmd" 1
	assert_success
	todo_assert_storage_empty
}
todo_register_missing_data_tests() {
	local subcmds=("$@")
	local subcmd
	for subcmd in "${subcmds[@]}"; do
		bats_test_function \
			--description "validation: missing data (${subcmd}): prints message and exits 0" \
			-- todo_test_missing_data "$subcmd"
	done
}
todo_register_missing_data_tests \
"do" \
"undo" \
"del"
