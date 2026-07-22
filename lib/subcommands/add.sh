#!/bin/bash

# ===================================================================================== #
# Description:		Adds tasks to txt file.
# Synopsis:			bash todo.sh add [+<list-name>] <task>
# ===================================================================================== #
# todo: add creation date => switch from long string to array of strings



# Settings
# ===================================================================================== #

set -euo pipefail



# Functions
# ===================================================================================== #

get_list() {
	local list="todo"

	if [[ "$1" =~ ^\+[a-z]+$ ]]
	then
		list=${1#\+}
		shift
	fi

	echo "$list"
}

add_tasks() {
	local tasks_string="$1"

	printf "%s\n" "$tasks_string" >> "$output_path" \
	&& grep -xq "$tasks_string" "$output_path"
}

main() {
	validate_arg_count "1" "x" "$@"

	local list_name
	list_name=$(get_list "$1")

	local output_path="${DATA_DIR}/${list_name}.txt"
	validate_file_exists "$output_path"

	local raw_tasks="$*"
	local tasks
	tasks=$(format_tasks "$raw_tasks")

	add_tasks "$tasks" "$output_path"
}



# Point of entry
# ===================================================================================== #

main "$@"
