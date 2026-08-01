#!/bin/bash

# ===================================================================================== #
# Description:	Shared utilities for todo-cli.
# ===================================================================================== #

# Arguments:
#	$1 STR	Error message
error_exit() {
	local -r message="$1"
	echo "Error: ${message}" >&2
	exit 1
}

# Arguments:
#	$1 STR	Error message
log_error() {
	local -r message="$1"
	echo "Error: ${message}" >&2
}

# Arguments:
# 	$1 STR	Rule type: "min", "max", "strict"
#	$2 INT	Reference count
# 	$3 INT	Function's argument count: "$#"
#	$4 STR	Custom error message (optional)
validate_arg_count() {
	local -r rule="$1"
	local -r ref_count="$2"
	local -r actual_count="$3"
	local -r err_message="${4:-Invalid number of arguments.}"
	local valid_count

	case "$rule" in
		min)	if (( actual_count < ref_count )); then valid_count="false"; fi ;;
		max)	if (( actual_count > ref_count )); then valid_count="false"; fi ;;
		strict)	if (( actual_count != ref_count )); then valid_count="false"; fi ;;
		*)		error_exit "Invalid argument." ;;
	esac

	if [[ "$valid_count" == "false" ]]; then
		log_error "$err_message"
		return 1
	fi
}

# Arguments:
#	$1 STR	File path
assert_file_exists() {
	local -r path="$1"
	if [[ ! -f $path ]]; then
		error_exit "File not found."
	fi
}

# Arguments:
#	$1 STR	File path
assert_file_not_empty() {
	local -r path="$1"
	if [[ ! -s "$path" ]]; then
		echo "File currently empty."
		return 1
	fi
}

# Arguments:
#	$1 STR	Line number of selected task
#	$2 STR	Path to data file
validate_task_id() {
	local -r id="$1"
	local -r path="$2"
	local line_count
	line_count="$(wc -l < "$path")"

	case "$id" in
		0)			error_exit "Task ID must be a positive integer." ;;
		+([0-9]))	if (( id > line_count )); then error_exit "Task ${id} not found."; fi ;;
		*)			error_exit "${id} is not an integer." ;;
	esac
}

# Arguments:
#	$1 STR	Task content
#	$2 STR	Path to data file
assert_task_exists() {
	local -r str="$1"
	local -r path="$2"
	if ! grep -Fn "$str" "$path"; then
		error_exit "Task was not saved in ${path##*/}."
	fi
}

# Arguments:
#	$1 STR	Raw input
clean_spaces() {
	local -r str="$1"
	awk '$1=$1' <<< "$str"
}
