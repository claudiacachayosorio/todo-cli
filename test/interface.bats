#!/usr/bin/env bats
# =========================================================================== #
# Description: Testing suite for todo-cli's interface functions.
# Command:     bats test/interface.bats

load test_helper
setup() {
	todo_setup
}

todo_test_help_cmd() {
	local arg="$1"
	run "$TODO_SCRIPT" "$arg"
	assert_success
	assert_line --index 0 "USAGE"
}
todo_register_help_cmd_tests() {
	local args=("$@")
	local arg desc_name

	for arg in "${args[@]}"; do
		desc_name="${arg:-no arguments}"
		bats_test_function \
			--description "option: ${desc_name}: prints usage guide" \
			-- todo_test_help_cmd "$arg"
	done
}
todo_register_help_cmd_tests \
"" \
"help" \
"--help"

@test "option: status: prints task summary" {
	local tasks=("${TASKS[@]}")
	tasks[1]="x ${TASKS[1]}"

	todo_print_tasks "${tasks[@]}" > "$TODO_FILE"
	run "$TODO_SCRIPT" "status"
	assert_success
	todo_assert_summary 3 1
}

@test "option: invalid: prints error and exits 2" {
	local error_desc="'cmd' is not a valid command."
	run --separate-stderr "$TODO_SCRIPT" "cmd"
	todo_assert_usage_failure "$error_desc"
}
