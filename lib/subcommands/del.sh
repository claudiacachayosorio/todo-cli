#!/bin/bash

# ===================================================================================== #
# Description:		Deletes tasks from txt file.
# Synopsis:			bash todo.sh del [<file-stem>] <line-number>...
# ===================================================================================== #


delete_tasks() {
	local total_deleted_lines=$#
	local data_path="$TODOTXT"

	if [[ $1 =~ ^[a-z]+$ ]]
	then
		data_path="${DATA_DIR}/${1}.txt"
		assert_file_exists "$data_path"
		shift
	fi

	local line_count
	line_count=$(wc -l < $data_path)

	local line_number
	for line_number in "$@"
	do
		if [[ ! $line_number =~ ^[0-9]+$ ]]
		then
			log_error "'${line_number}' is not an integer"
			return 1

		elif [[ $line_number -eq 0 || $line_number -gt $line_count ]]
		then
			log_error "line ${line_number} not found"
			return 1

		else
			sed -i "${line_number}d" "$data_path"
		fi
	done
}


main() {
	validate_arg_count "1" "x" "$@"
	delete_tasks "$@"
}


main "$@"
