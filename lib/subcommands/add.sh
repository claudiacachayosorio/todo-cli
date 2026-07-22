#!/bin/bash

# ===================================================================================== #
# Description:		Adds tasks to txt file.
# Synopsis:			bash todo.sh add <task>
# ===================================================================================== #
# todo: add creation date => switch from long string to array of strings?


add_tasks() {
	local task="$1"
	printf "%s\n" "$task" >> "$TODOTXT" && grep -xq "$task" "$TODOTXT"
}


main() {
	validate_arg_count "1" "x" "$@"
	local task_string="$*"
	add_tasks "$task_string"
}


main "$@"
