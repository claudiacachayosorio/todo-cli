#!/bin/bash

# ===================================================================================== #
# Description:	Shared utilities for todo.sh and subcommands.
# ===================================================================================== #

REGEX_DATE="[0-9]{4}-[0-9]{2}-[0-9]{2}"
ALL_WS="[[:space:]]*"

# Arguments:
#	$1 Error message: STR
error_exit() {
	local message="$1"
	echo "Error: ${message}" >&2
	exit 1
}

# Arguments:
#	$1 Error message: STR
log_error() {
	local message="$1"
	echo "Error: ${message}" >&2
}

# Arguments:
# 	$1 Function's argument count: $#
# 	$2 Comparison operator: STR
#		-lt (less than minimum)
#		-gt (greater than maximum)
#		-ne (not equal to fixed count)
#	$3 Minimum, maximum or fixed count: INT
validate_arg_count() {
	local actual_count=$1
	local op=$2
	local ref_count=$3

	if [ $actual_count $op $ref_count ]
	then
		log_error "Invalid number of arguments."
		return 1
	fi
}

# Arguments:
#	$1 File path: STR
assert_file_exists() {
	local path="$1"
	if [[ ! -f $path ]]
	then
		error_exit "File not found."
	fi
}

# Arguments:
#	$1 File path: STR
assert_file_not_empty() {
	local path="$1"
	if [[ ! -s "$path" ]]
	then
		echo "File currently empty."
		return 1
	fi
}

# Arguments:
#	$1 Filename: STR
get_data_path() {
	local filename="$1"
	local path="${TODO_DATA_DIR}/${filename}"
	assert_file_exists "$path"
	echo "$path"
}

# Arguments:
#	$1 Path to txt file: STR
#	$2 Task content: STR
assert_task_deleted() {
	local task_str="$1"
	local path="$2"
	if grep -qF "$task_str" "$path"
	then
		error_exit "Task still exists."
	fi
}

# Arguments:
#	$1 Line number of selected task as ID to validate: INT
#	$2 Path to txt file: STR
validate_task_id() {
	local id="$1"
	local path="$2"

	case "$id" in
		0)	error_exit "Task ID must be a positive integer." ;;

		+([0-9]))
			local line_count
			line_count=$(wc -l < "$path")

			if [[ $id -gt $line_count ]]
			then
				error_exit "Task ${id} not found."
			fi
			;;

		*)	error_exit "${id} is not an integer." ;;
	esac
}

# Arguments:
#	$1 Tasks being formatted: STR
format_task_date() {
	local str="$1"
	local date_subs=""
	if [[ "$INCLUDE_DATE" == "true" ]]
	then
		date_subs="\1|"
	fi

	sed -E "s/\[(${REGEX_DATE})\]${ALL_WS}/${date_subs}/g" <<< "$str"
}

# Arguments:
#	$1 Tasks: STR
format_tasks() {
	local tasks="$1"

	format_task_date "$tasks"						|
	sed -E "s/^${ALL_WS}([0-9]+):?${ALL_WS}/\1|/g"	|
	column -t -s '|' -o ' '
}
