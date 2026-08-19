#!/usr/bin/env bats
# =========================================================================== #
# Description: Testing suite for todo-cli's del subcommand.
# Command:     bats test/del.bats

load test_helper
setup() {
	todo_setup
	source "$TODO_SCRIPT"
	todo_print_tasks > "$TODO_FILE"
	export LABEL="[-] Deleted"
}

@test "success: valid index: replaces targeted task with empty line" {
	local tasks=("${TASKS[@]}")
	todo_execute_valid_index "del" "$LABEL" 1
	todo_assert_summary 3
	tasks[1]=""
	todo_assert_storage_content "${tasks[@]}"
}

@test "success: multiple valid indexes: replaces targeted tasks with empty lines" {
	local tasks=("${TASKS[@]}")
	todo_execute_valid_index "del" "$LABEL" 1 2
	todo_assert_summary 2
	tasks[1]=""
	tasks[2]=""
	todo_assert_storage_content "${tasks[@]}"
}

@test "success: end of file task: trims leftover trailing newlines" {
	local tasks=("${TASKS[@]}")
	tasks[3]=""
	todo_print_tasks "${tasks[@]}" > "$TODO_FILE"
	todo_execute_valid_index "del" "$LABEL" "4"
	todo_assert_summary 2
	todo_assert_storage_content "${tasks[@]:0:3}"
}

@test "success: last remaining task: empties storage" {
	printf "\n%s\n" "${TASKS[2]}" > "$TODO_FILE"
	todo_execute_valid_index "del" "$LABEL" 2
	todo_assert_summary 0
	todo_assert_storage_empty
}

todo_register_invalid_index_del_tests() {
	local error
	for error in "${!INDEX_ERRORS[@]}"; do
		[[ "$error" == "checked" ]]   && continue
		[[ "$error" == "unchecked" ]] && continue
		bats_test_function \
			--description "failure: ${error} index: prints error and exits 2" \
			-- todo_test_invalid_index "del" "$error"
	done
}
todo_register_invalid_index_del_tests
