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
	printf "%s\n" "${TASKS[@]:1}" > "$TODO_FILE"
	run "$TODO_SCRIPT" --init-only
	assert_success
	todo_assert_storage_content
}

todo_register_missing_args_tests() {
	local subcmds=("add" "del" "do" "undo") \
	      subcmd \
				error_desc

	for subcmd in "${subcmds[@]}"; do
		if [[ "$subcmd" == "add" ]]; then
			error_desc="Task description cannot be empty."
		else
			error_desc="Task index required."
		fi

		bats_test_function \
			--description "validation: missing args (${subcmd}): prints error and exits 2" \
			-- todo_test_usage_failure "$error_desc" "$subcmd"
	done
}
todo_register_missing_args_tests

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
