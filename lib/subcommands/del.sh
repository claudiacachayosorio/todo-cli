#!/bin/bash

# ===================================================================================== #
# Description:	Deletes tasks from txt file.
# Synopsis:		bash todo.sh del [<filename>] <line-number>...
# ===================================================================================== #


delete_tasks() {
	local total_deleted_lines="$#"
	local data_path="$TODO_ACTIVE_DATA"
	local line_count
	local line_number

	if [[ $1 =~ ^[a-z]+$ ]]; then
		data_path="${TODO_DATA_DIR}/${1}.txt"
		assert_file_exists "$data_path"
		shift
	fi

	line_count="$(wc -l < $data_path)"

	for line_number in "$@"; do
		if [[ ! "$line_number" =~ ^[0-9]+$ ]]; then
			log_error "'${line_number}' is not an integer"
			return 1

		elif [[ "$line_number" -eq 0 || "$line_number" -gt "$line_count" ]]; then
			log_error "line ${line_number} not found"
			return 1

		else
			sed -i "${line_number}d" "$data_path"
		fi
	done
}


# EXECUTION FLOW ====================================================================== #

validate_arg_count "$#" "min" "1"
delete_tasks "$@"
