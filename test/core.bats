#!/usr/bin/env bats
# =========================================================================== #
# Description: Testing suite for todo-cli's core functions.
# Command:     bats test/core.bats

load test_helper
setup() {
	todo_setup
	source "$TODO_SCRIPT"
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
	local subcmd="$1" \
	      error_desc="Task index required."

	if [[ "$subcmd" == "add" ]]; then
		error_desc="Task description cannot be empty."
	fi

	run --separate-stderr "$TODO_SCRIPT" "$subcmd"
	todo_assert_usage_failure
}
todo_register_missing_args_tests() {
	local subcmds=("add" "del" "do" "undo") \
	      subcmd
		bats_test_function \
			--description "validation: missing args (${subcmd}): prints error and exits 2" \
			-- todo_test_missing_args "$subcmd"
	done
}
todo_register_missing_args_tests

todo_test_missing_data() {
	local subcmd="$1"
	run "$TODO_SCRIPT" "$subcmd" 1
	assert_success
	todo_assert_storage_empty
}
todo_register_missing_data_tests() {
	local subcmds=("del" "do" "undo") \
	      subcmd

	for subcmd in "${subcmds[@]}"; do
		bats_test_function \
			--description "validation: missing data (${subcmd}): prints message and exits 0" \
			-- todo_test_missing_data "$subcmd"
	done
}
todo_register_missing_data_tests
