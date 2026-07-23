#!/bin/bash

# ===================================================================================== #
# Description:		Adds tasks to txt file.
# Synopsis:			bash todo.sh add [<list-name>:] <task> [<@tag> ...]
# ===================================================================================== #
# TODO: multiple tasks at once


parse_args() {
	if [[ "$1" =~ ^[a-z]+:$ ]]
	then
		if [[ "$1" == "done:" ]]
		then
			log_error "new tasks cannot be added to done.txt"
			return 1
		else
			list_name=${1%:}
			shift
		fi
	fi

	raw_task="$*"
}


add_tasks() {
	local dest="$1"
	local task="$2"
	printf "%s\n" "$task" >> "$dest"
}


main() {
	validate_arg_count "1" "x" "$@"

	local list_name="todo"
	local raw_task
	parse_args "$@"

	local dest_path="${DATA_DIR}/${list_name}.txt"
	assert_file_exists "$dest_path"

	local date_created
	date_created=$(date +%F)

	local new_task="[${date_created}] ${raw_task}"
	add_tasks "$dest_path" "$new_task"
	assert_task_exists "$dest_path" "$new_task"
}


main "$@"
