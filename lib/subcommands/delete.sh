#!/bin/bash

# ===================================================================================== #
# Description:		Deletes tasks from txt file.
# Synopsis:			bash todo.sh delete [<list-name>] <task-number> ...
# ===================================================================================== #



# Settings
# ===================================================================================== #

shopt -s extglob



# Main logic
# ===================================================================================== #

delete_tasks() {
	local total_deleted_lines=$#
	local file_path="$TODO_TXT"

	local line_count
	local expected_line_count

	if [[ $1 =~ ^[a-z]+$ ]]
	then
		file_path="${DATA_DIR}/${1}.txt"
		validate_file_exists "$file_path"
		shift
	fi

	line_count=$(wc -l < $file_path)

	local line_number
	for line_number in "$@"
	do
		if [[ ! $line_number =~ ^[0-9]+$ ]]
		then
			log_user_error "'${line_number}' is not an integer"
			return 1

		elif [[ $line_number -eq 0 || $line_number -gt $line_count ]]
		then
			log_user_error "line ${line_number} not found"
			return 1

		else
			sed -i "${line_number}d" "$file_path"
		fi
	done

	expected_line_count=$(( line_count - total_lines ))
	validate_line_count "$file_path" $expected_line_count
}



# Point of entry
# ===================================================================================== #

validate_arg_count "1" "x" "$@"
delete_tasks "$@"
