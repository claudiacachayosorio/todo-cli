#!/usr/bin/env bats
# =========================================================================== #
# Description: Testing suite for todo-cli's interface functions.
# Command:     bats test/99_interface.bats

load test_helper
setup() {
	todo_setup
}

@test "cli: invalid argument: prints error and exits 2" {
	local error_desc="'cmd' is not a valid command."
	run --separate-stderr "$TODO_SCRIPT" "cmd"
	todo_assert_usage_failure "$error_desc"
}

todo_test_help_cmd() {
	local arg="$1"
	run "$TODO_SCRIPT" "$arg"
	assert_success
	assert_line --index 0 "USAGE"
}
todo_register_help_cmd_tests() {
	local arg args=("$@")
	local test_condition

	for arg in "${args[@]}"; do
		test_condition="${arg:-no arguments}"
		bats_test_function \
			--description "help: '${test_condition}': prints usage guide" \
			-- todo_test_help_cmd "$arg"
	done
}
todo_register_help_cmd_tests "" "help" "--help" "-h"

todo_test_version_flag() {
	local flag="$1"
	run "$TODO_SCRIPT" "$flag"
	assert_success
	assert_line="todo-cli, version 0.1.0"
}
@test "flag: --version: prints current version" {
	todo_test_version_flag "--version"
}
@test "flag: -v: prints current version" {
	todo_test_version_flag "-v"
}

@test "status: mixed tasks: prints task summary" {
	local tasks=("${TASKS[@]}")
	tasks[1]="x ${TASKS[1]}"

	todo_print_tasks "${tasks[@]}" > "$TODO_FILE"
	run "$TODO_SCRIPT" "status"
	assert_success
	todo_assert_summary 3 1
}
