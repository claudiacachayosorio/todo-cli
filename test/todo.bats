#!/usr/bin/env bats
# =========================================================================== #
# Description: Test suite for todo-cli project.
# Command:     bats test/

bats_require_minimum_version 1.5.0

readonly BATS_LIB_PATH="${BATS_TEST_DIRNAME}/test_helper"
readonly TODO_DIR="$(cd "$BATS_TEST_DIRNAME/.." >/dev/null 2>&1 && pwd)"
readonly TODO_SCRIPT="${TODO_DIR}/todo"

setup() {
	bats_load_library bats-support
	bats_load_library bats-assert
	bats_load_library bats-file

	load test_helper
	export DATA_DIR="$BATS_TEST_TMPDIR"
	source "$TODO_SCRIPT"
}

# bats --filter "^interface:" test/

@test "interface: handles routing and usage" {
	local tasks=("${TASKS[@]}")

	todo_execute_help
	todo_execute_help "help"
	todo_execute_help "--help"

	run "$TODO_SCRIPT" "status"
	assert_success
	todo_assert_summary

	tasks[1]="x ${TASKS[1]}"
	printf "%s\n" "${tasks[@]:1}" > "$TODO_FILE"

	run "$TODO_SCRIPT" "status"
	assert_success
	todo_assert_summary 3 1

	local error_desc="'fixt' is not a valid command."
	todo_execute_usage_failure "$error_desc" "fixt"
}

# bats --filter "^storage:" test/

@test "storage: initializes and manages files" {
	run "$TODO_SCRIPT" --init-only
	assert_success
	assert_file_exists "$TODO_FILE"

	printf "%s\n" "${TASKS[@]:1}" > "$TODO_FILE"
	run "$TODO_SCRIPT" --init-only
	assert_success
	todo_assert_storage_content
}

# bats --filter "^validation:" test/

@test "validation: rejects missing arguments for subcommands" {
	local missing_task_error="Task description cannot be empty."
	local missing_index_error="Task index required."

	todo_execute_usage_failure "$missing_task_error" "add"
	todo_execute_usage_failure "$missing_index_error" "del"
	todo_execute_usage_failure "$missing_index_error" "do"
	todo_execute_usage_failure "$missing_index_error" "undo"
}

@test "validation: handles empty storage precondition" {
	run "$TODO_SCRIPT" --init-only
	[[ -f "$TODO_FILE" ]]
	[[ ! -s "$TODO_FILE" ]]

	run "$TODO_SCRIPT" "del" 1
	todo_assert_storage_empty "del"
	run "$TODO_SCRIPT" "do" 1
	todo_assert_storage_empty "do"
	run "$TODO_SCRIPT" "undo" 1
	todo_assert_storage_empty "undo"
}

# bats --filter "^add:" test/

@test "add: creates storage and appends tasks" {
	local task_1_alt="this is a different first task"
	local expected unquoted_task
	read -ra unquoted_task <<< "${TASKS[3]}"

	todo_execute_add_cmd 1 "${TASKS[1]}"
	todo_assert_summary 1
	expected="${TASKS[1]}"$'\n'
	todo_assert_storage_content "$expected"

	todo_execute_add_cmd 2 "${TASKS[2]}"
	todo_assert_summary 2
	expected+="${TASKS[2]}"$'\n'
	todo_assert_storage_content "$expected"

	printf "\n%s\n" "${TASKS[2]}" > "$TODO_FILE"

	todo_execute_add_cmd 1 "$task_1_alt"
	todo_assert_summary 2
	printf -v expected "%s\n%s\n" "$task_1_alt" "${TASKS[2]}"
	todo_assert_storage_content "$expected"

	todo_execute_add_cmd 3 "${unquoted_task[@]}"
	todo_assert_summary 3
	expected+="${TASKS[3]}"$'\n'
	todo_assert_storage_content "$expected"
}

# bats --filter "^del:" test/

@test "del: removes tasks corresponding to valid indexes" {
	local label="[-] Deleted"
	local expected
	printf "%s\n" "${TASKS[@]:1}" > "$TODO_FILE"

	todo_execute_valid_index "del" "$label" 1
	todo_assert_summary 3
	printf -v expected "\n%s" "${TASKS[@]:2}"
	todo_assert_storage_content "$expected"$'\n'

	todo_execute_valid_index "del" "$label" 2 3
	todo_assert_summary 1
	printf -v expected "\n\n\n%s\n" "${TASKS[4]}"
	todo_assert_storage_content "$expected"

	todo_execute_valid_index "del" "$label" 4
	todo_assert_summary 0
	run grep -c "^$" "$TODO_FILE"
	assert_output 4
}

@test "del: handles and skips invalid indexes" {
	local expected
	printf "%s\n" "${TASKS[@]:1}" > "$TODO_FILE"

	todo_execute_invalid_index "del" "text"
	todo_assert_storage_content

	todo_execute_invalid_index "del" 0
	todo_assert_storage_content

	todo_execute_invalid_index "del" 5
	todo_assert_storage_content

	run --keep-empty-lines "$TODO_SCRIPT" "del" 0 4
	assert_success
	todo_assert_invalid_index 0
	todo_assert_task_success "[-] Deleted" 4
	todo_assert_summary 3
	printf -v expected "%s\n" "${TASKS[@]:1:3}"
	todo_assert_storage_content "$expected"$'\n'
}

# bats --filter "^done:" test/

#@test "done: no arguments: prints error and exits 2" {
#	run --separate-stderr "$TODO_SCRIPT" done
#	assert_command_error "Task index required."
#}

#@test "done: invalid task numbers: prints error and leave data intact" {
#	assert_invalid_indexes "done"
#}

#@test "done: task already done: print error and leaves data intact" {
#	seed_todo
#	run_and_assert_index_error "done" "4" "Task 4 is already marked as done."
#	assert_todo_content "$TASKS_RENDERED"
#}

#@test "done: empty todo.txt: prints 'empty todo' message and exits 0" {
#	assert_todo_empty "done"
#}

#@test "done: valid index: inserts 'done' mark into line corresponding to index" {
#	seed_todo
#	run "$TODO_SCRIPT" done 6
#	assert_success
#	assert_output "✅ 6  ${TASKS[6]}"
#}

#@test "done: multiple indexes: inserts 'done' mark into lines corresponding to indexes provided" {
#	seed_todo
#	run "$TODO_SCRIPT" done 8 9
#	assert_success
#	assert_output "✅ 8  ${TASKS[8]}"
#	assert_output "✅ 9  ${TASKS[9]}"
#}

#@test "done: valid and invalid indexes: skips invalid indexes and inserts 'done' mark into lines corresponding to valid indexes" {}
