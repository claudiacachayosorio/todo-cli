#!/bin/bash

# ===================================================================================== #
# Description:	Shared utilities for todo.sh and subcommands.
# ===================================================================================== #


# Arguments:
#	$1 Error message: STR
error_exit() {
	local message="$1"
	echo "error: ${message}" >&2
	exit 1
}


# Arguments:
#	$1 Error message: STR
log_error() {
	local message="$1"
	echo "error: ${message}" >&2
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
		log_error "invalid number of arguments"
		return 1
	fi
}


# Arguments:
#	$1 File path to be validated: STR
assert_file_exists() {
	local path="$1"
	if [[ ! -f $path ]]
	then
		error_exit "'${path##*/}': file not found"
	fi
}


# Arguments:
#	$1 Filename: STR
get_data_path() {
	local filename="$1"
	local path="${DATA_DIR}/${filename}"
	assert_file_exists "$path"
	echo "$path"
}


# Arguments:
#	$1 Path to txt file: STR
#	$2 Task content: STR
assert_task_exists() {
	local path="$1"
	local task="$2"

	if ! grep -qF "$task" "$path"
	then
		error_exit "'${task}' was not found in '${path##*/}'"
	fi
}


# Arguments:
#	$1 Path to txt file: STR
#	$2 Task content: STR
assert_task_deleted() {
	local path="$1"
	local task="$2"

	if grep -qF "$task" "$path"
	then
		error_exit "'${task}' still exists in '${path##*/}'"
	fi
}


# Arguments:
#	$1 Line number of selected task as ID to validate: INT
#	$2 Path to txt file: STR
validate_task_id() {
	local id="$1"
	local path="$2"

	case "$id" in
		0)	error_exit "task id must be a positive integer" ;;

		+([0-9]))
			local line_count
			line_count=$(wc -l < "$path")

			if [[ $id -gt $line_count ]]
			then
				error_exit "task '${id}' not found in ${path##*/}"
			fi
			;;

		*)	error_exit "'${id}' is not an integer" ;;
	esac
}
