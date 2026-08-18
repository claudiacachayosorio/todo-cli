#!/usr/bin/env bats
# =========================================================================== #
# Description: Integration tests for todo-cli's interface.
# Command:     bats test/interface.bats

setup() {
	load test_helper
	todo_setup
	source "$TODO_SCRIPT"
}

todo_test_help() {
	local arg="$1"
	run "$TODO_SCRIPT" "$arg"
	assert_success
	assert_line --index 0 "USAGE"
}

for help_arg in "" "help" "--help"; do
	local desc_name="${help_arg:-no arguments}"
	bats_test_function --description "${desc_name}: prints usage guide" -- todo_test_help "$help_arg"
done

@test "status: prints task summary" {
	local tasks=("${TASKS[@]}")
	tasks[1]="x ${TASKS[1]}"
	printf "%s\n" "${tasks[@]:1}" > "$TODO_FILE"

	run "$TODO_SCRIPT" "status"
	assert_success
	todo_assert_summary 3 1
}

@test "invalid subcommand: prints error and exits 2" {
	local error_desc="'cmd' is not a valid command."
	todo_execute_usage_failure "$error_desc" "cmd"
}
