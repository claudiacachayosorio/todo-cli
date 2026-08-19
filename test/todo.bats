#!/usr/bin/env bats
# =========================================================================== #
# Description: Test suite for todo-cli project.
# Command:     bats test/todo.bats

setup() {
	load test_helper
	todo_setup
	source "$TODO_SCRIPT"
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
	tasks[1]="x ${TASKS[1]}"
	printf "%s\n" "${tasks[@]:1}" > "$TODO_FILE"
	printf -v expected "%s\n" "${tasks[@]:1}"

	# non-numeric index: prints error and exits 2
	todo_execute_invalid_index "do" "text"
	todo_assert_storage_content "$expected"

	# index zero: prints error and exits 2
	todo_execute_invalid_index "do" 0
	todo_assert_storage_content "$expected"

	# out-of-bounds index: prints error and exits 2
	todo_execute_invalid_index "do" 5
	todo_assert_storage_content "$expected"

	# task already checked: prints error and exits 2
	todo_execute_invalid_index "do" 1 "checked"
	todo_assert_storage_content "$expected"

	# valid & invalid input: edits only task with valid index
	tasks[4]="x ${TASKS[4]}"
	printf -v expected "%s\n" "${tasks[@]:1}"
	run --keep-empty-lines "$TODO_SCRIPT" "do" 0 4
	assert_success
	todo_assert_invalid_index 0
	todo_assert_task_success "[x] Done" 4 "${tasks[4]}"
	todo_assert_summary 2 2
	todo_assert_storage_content "$expected"
}

# bats --filter "^undo:" test/

@test "undo: unchecks tasks corresponding to valid indexes" {
	local label="[ ] Undone"
	local tasks=("${TASKS[@]/#/x }")
	local expected
	printf "%s\n" "${tasks[@]:1}" > "$TODO_FILE"

	# valid index: removes prefix from corresponding task
	todo_execute_valid_index "undo" "$label" 1
	todo_assert_summary 1 3
	tasks[1]="${TASKS[1]}"
	printf -v expected "%s\n" "${tasks[@]:1}"
	todo_assert_storage_content "$expected"

	# multiple valid indexes: removes prefix from corresponding tasks
	todo_execute_valid_index "undo" "$label" 2 3
	todo_assert_summary 3 1
	tasks[2]="${TASKS[2]}"; tasks[3]="${TASKS[3]}"
	printf -v expected "%s\n" "${tasks[@]:1}"
	todo_assert_storage_content "$expected"
}

@test "undo: handles and skips invalid indexes" {
	local tasks=("${TASKS[@]/#/x }")
	local expected
	tasks[1]="${TASKS[1]}"
	printf "%s\n" "${tasks[@]:1}" > "$TODO_FILE"
	printf -v expected "%s\n" "${tasks[@]:1}"

	# non-numeric index: prints error and exits 2
	todo_execute_invalid_index "undo" "text"
	todo_assert_storage_content "$expected"

	# index zero: prints error and exits 2
	todo_execute_invalid_index "undo" 0
	todo_assert_storage_content "$expected"

	# out-of-bounds index: prints error and exits 2
	todo_execute_invalid_index "undo" 5
	todo_assert_storage_content "$expected"

	# task still unchecked: prints error and exits 2
	todo_execute_invalid_index "undo" 1 "unchecked"
	todo_assert_storage_content "$expected"

	# valid & invalid input: edits only task with valid index
	tasks[4]="${TASKS[4]}"
	printf -v expected "%s\n" "${tasks[@]:1}"
	run --keep-empty-lines "$TODO_SCRIPT" "undo" 0 4
	assert_success
	todo_assert_invalid_index 0
	todo_assert_task_success "[ ] Undone" 4 "${tasks[4]}"
	todo_assert_summary 2 2
	todo_assert_storage_content "$expected"
}
