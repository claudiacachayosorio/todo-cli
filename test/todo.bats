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

	# no argument: prints usage guide
	todo_execute_help
	# help option: prints usage guide
	todo_execute_help "help"
	todo_execute_help "--help"

	# status option: prints task summary
	tasks[1]="x ${TASKS[1]}"
	printf "%s\n" "${tasks[@]:1}" > "$TODO_FILE"
	run "$TODO_SCRIPT" "status"
	assert_success
	todo_assert_summary 3 1

	# invalid subcommand: prints error and exits 2
	local error_desc="'fixt' is not a valid command."
	todo_execute_usage_failure "$error_desc" "fixt"
}

# bats --filter "^storage:" test/

@test "storage: initializes and manages files" {
	# missing todo.txt: creates storage
	run "$TODO_SCRIPT" --init-only
	assert_success
	assert_file_exists "$TODO_FILE"

	# existing storage and data: preserves data
	printf "%s\n" "${TASKS[@]:1}" > "$TODO_FILE"
	run "$TODO_SCRIPT" --init-only
	assert_success
	todo_assert_storage_content
}

# bats --filter "^validation:" test/

@test "validation: rejects missing arguments for subcommands" {
	local missing_task_error="Task description cannot be empty."
	local missing_index_error="Task index required."

	# missing arguments: prints error and exits 2
	todo_execute_usage_failure "$missing_task_error" "add"
	todo_execute_usage_failure "$missing_index_error" "del"
	todo_execute_usage_failure "$missing_index_error" "do"
	todo_execute_usage_failure "$missing_index_error" "undo"
}

@test "validation: handles empty storage precondition" {
	run "$TODO_SCRIPT" --init-only
	assert_file_exists "$TODO_FILE"
	assert_file_empty "$TODO_FILE"

	# empty storage: prints message and exits 0
	run "$TODO_SCRIPT" "del" 1
	assert_success
	todo_assert_storage_empty "del"
	run "$TODO_SCRIPT" "do" 1
	assert_success
	todo_assert_storage_empty "do"
	run "$TODO_SCRIPT" "undo" 1
	assert_success
	todo_assert_storage_empty "undo"
}

# bats --filter "^add:" test/

@test "add: creates storage and appends tasks" {
	local task_1_alt="this is a different first task"
	local expected unquoted_task
	read -ra unquoted_task <<< "${TASKS[3]}"

	# missing todo.txt: creates storage and saves new task
	todo_execute_add_cmd 1 "${TASKS[1]}"
	todo_assert_summary 1
	expected="${TASKS[1]}"$'\n'
	todo_assert_storage_content "$expected"

	# existing storage and data: appends new task
	todo_execute_add_cmd 2 "${TASKS[2]}"
	todo_assert_summary 2
	expected+="${TASKS[2]}"$'\n'
	todo_assert_storage_content "$expected"

	printf "\n%s\n" "${TASKS[2]}" > "$TODO_FILE"

	# existing empty line: inserts new task in empty line
	todo_execute_add_cmd 1 "$task_1_alt"
	todo_assert_summary 2
	printf -v expected "%s\n%s\n" "$task_1_alt" "${TASKS[2]}"
	todo_assert_storage_content "$expected"

	# unquoted task: joins arguments into one new task
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

	# valid index: replaces corresponding task with empty line
	todo_execute_valid_index "del" "$label" 1
	todo_assert_summary 3
	printf -v expected "\n%s" "${TASKS[@]:2}"
	todo_assert_storage_content "$expected"$'\n'

	# multiple valid indexes: empties lines corresponding to indexes
	todo_execute_valid_index "del" "$label" 2 3
	todo_assert_summary 1
	printf -v expected "\n\n\n%s\n" "${TASKS[4]}"
	todo_assert_storage_content "$expected"
}

@test "del: handles leftover empty space" {
	local label="[-] Deleted"
	local expected
	printf "\n\n%s\n%s\n" "${TASKS[3]}" "${TASKS[4]}" > "$TODO_FILE"

	# end of file task: removes leftover trailing empty lines
	todo_execute_valid_index "del" "$label" 4
	todo_assert_summary 1
	printf -v expected "\n\n%s\n" "${TASKS[3]}"
	todo_assert_storage_content "$expected"

	# last remaining task: clears entire file
	todo_execute_valid_index "del" "$label" 3
	todo_assert_summary 0
	todo_assert_storage_empty
}

@test "del: handles and skips invalid indexes" {
	local expected
	printf "%s\n" "${TASKS[@]:1}" > "$TODO_FILE"

	# non-numeric index: prints error and exits 2
	todo_execute_invalid_index "del" "text"
	todo_assert_storage_content

	# index zero: prints error and exits 2
	todo_execute_invalid_index "del" 0
	todo_assert_storage_content

	# out-of-bounds index: prints error and exits 2
	todo_execute_invalid_index "del" 5
	todo_assert_storage_content

	# valid & invalid input: deletes only task with valid index
	run --keep-empty-lines "$TODO_SCRIPT" "del" 0 4
	assert_success
	todo_assert_invalid_index 0
	todo_assert_task_success "[-] Deleted" 4
	todo_assert_summary 3
	printf -v expected "%s\n" "${TASKS[@]:1:3}"
	todo_assert_storage_content "$expected"
}

# bats --filter "^do:" test/

@test "do: marks tasks corresponding to valid indexes as done" {
	local label="[x] Done"
	local tasks=("${TASKS[@]}")
	local expected
	printf "%s\n" "${TASKS[@]:1}" > "$TODO_FILE"

	# valid index: adds prefix to corresponding task
	todo_execute_valid_index "do" "$label" "x " 1
	todo_assert_summary 3 1
	tasks[1]="x ${TASKS[1]}"
	printf -v expected "%s\n" "${tasks[@]:1}"
	todo_assert_storage_content "$expected"

	# multiple valid indexes: adds prefix to corresponding tasks
	todo_execute_valid_index "do" "$label" "x " 2 3
	todo_assert_summary 1 3
	tasks[2]="x ${TASKS[2]}"; tasks[3]="x ${TASKS[3]}"
	printf -v expected "%s\n" "${tasks[@]:1}"
	todo_assert_storage_content "$expected"
}

@test "do: handles and skips invalid indexes" {
	local tasks=("${TASKS[@]}")
	local expected
	printf "%s\n" "${TASKS[@]:1}" > "$TODO_FILE"

	# non-numeric index: prints error and exits 2
	todo_execute_invalid_index "do" "text"
	todo_assert_storage_content

	# index zero: prints error and exits 2
	todo_execute_invalid_index "do" 0
	todo_assert_storage_content

	# out-of-bounds index: prints error and exits 2
	todo_execute_invalid_index "do" 5
	todo_assert_storage_content

	# valid & invalid input: deletes only task with valid index
	run --keep-empty-lines "$TODO_SCRIPT" "do" 0 4
	assert_success
	todo_assert_invalid_index 0
	todo_assert_task_success "[x] Done" 4 "x ${TASKS[4]}"
	todo_assert_summary 3 1
	tasks[4]="x ${TASKS[4]}"
	printf -v expected "%s\n" "${tasks[@]:1}"
	todo_assert_storage_content "$expected"
}
