#!/bin/bash

# ===================================================================================== #
# Description:		Adds tasks to txt file.
# Synopsis:			bash todo.sh add <task>
# ===================================================================================== #
# TODO: destination list
# TODO: multiple tasks at once


add_tasks() {
	local task="$1"
	printf "%s\n" "$task" >> "$TODOTXT"
}


main() {
	validate_arg_count "1" "x" "$@"

	local initial_string="$*"
	local date_created
	date_created=$(date +%F)

	local task_string="[${date_created}] ${initial_string}"
	add_tasks "$task_string"
	assert_task_exists "$TODOTXT" "$task_string"
}


main "$@"
