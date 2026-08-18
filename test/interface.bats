#!/usr/bin/env bats
# =========================================================================== #
# Description: Testing suite for todo-cli's interface functions.
# Command:     bats test/interface.bats

setup() {
	load test_helper
	todo_setup
	source "$TODO_SCRIPT"
}

todo_test_help_cmd() {
	local arg="$1"
	run "$TODO_SCRIPT" "$arg"
	assert_success
	assert_line --index 0 "USAGE"
}

todo_register_help_cmd_tests() {
	local arg desc_name
	for arg in "" "help" "--help"; do
		desc_name="${arg:-no arguments}"
		bats_test_function \
			--description "${desc_name}: prints usage guide" \
			-- todo_test_help_cmd "$arg"
	done
}

todo_register_help_cmd_tests

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
