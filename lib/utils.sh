#!/bin/bash

# ===================================================================================== #
# Description:		Shared utilities for todo.sh and subcommands.
# ===================================================================================== #


# Argument:	Error message (string)
error_exit() {
	local message="$1"
	echo "error: ${message}" >&2
	exit 1
}


# Argument:	Error message (string)
log_error() {
	local message="$1"
	echo "error: ${message}" >&2
}


# Arguments:
#	$1		Minimum number of arguments: integer or "x" (if no minimum)
#	$2		Maximum number of arguments: integer or "x" (if no maximum)
#	$3...	All arguments passed into the subcommand: "$@"
validate_arg_count() {
	local min="$1"
	local max="$2"
	shift 2

	case "$min" in
		x)	: ;;

		[1-9])
			if [[ $# -lt $min ]]
			then
				log_error "missing argument"
				return 1
			fi
			;;

		*)	error_exit "'${min}': invalid argument" ;;
	esac

	case "$max" in
		x)	: ;;

		[1-9])
			if [[ $# -gt $max ]]
			then
				log_error "too many arguments"
				return 1
			fi
			;;

		*)	error_exit "'${max}': invalid argument" ;;
	esac
}


# Argument:	File path to be validated (string)
assert_file_exists() {
	local path="$1"

	if [[ ! -f $path ]]
	then
		error_exit "'$(basename "$path")': file not found"
	fi
}


# Arguments:
#	$1		Path to txt file (string)
#	$2		Task content (string)
assert_task_exists() {
	local txt_file="$1"
	local task="$2"

	if ! grep -qF "$task" "$txt_file"
	then
		error_exit "'${task}' was not found in '$(basename "$path")'"
	fi
}


# Arguments:
#	$1		Path to txt file (string)
#	$2		Task content (string)
assert_task_deleted() {
	local txt_file="$1"
	local task="$2"

	if grep -qF "$task" "$txt_file"
	then
		error_exit "'${task}' still exists in '$(basename "$path")'"
	fi
}


# Arguments:
#	$1		Line number of selected task as ID to validate (integer)
#	$2		Path to txt file (string)
validate_task_id() {
	local id=$1
	local path="$2"
	local line_count=$(wc -l "$path")

	case $id in
		0)	error_exit "task id must be a positive integer" ;;

		+([0-9]))
			if [[ $id -gt $line_count ]]
			then
				error_exit "task '${id}' not found in $(basename "$path")"
			fi
			;;

		*)	error_exit "'${id}' is not an integer" ;;
	esac
}


# Arguments:
#	$1		Path to txt file (string)
#	$2		Expected line count after adding/removing lines (integer)
validate_line_count() {
	local path="$1"
	local expected_count=$2
	local current_count
	current_count=$(wc -l < "$path")

	if [[ $current_count -ne $expected_count ]]
	then
		error_exit "unexpected line count"
	fi
}
