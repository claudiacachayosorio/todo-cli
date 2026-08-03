#!/usr/bin/env bash
# =========================================================================== #
# Description:	Shared utilities for todo-cli.
# =========================================================================== #

# Arguments:
#	$1 STR	Error message (optional)
error_exit() {
	local -r message="${1:-An unknown error has occurred.}"
	echo "Error: ${message}" >&2
	exit 1
}

# Arguments:
#	$1 STR	Error message (optional)
log_error() {
	local -r message="${1:-An unknown error has occurred.}"
	echo "Error: ${message}" >&2
}

# Arguments:
#	$1 INT	Expected argument count
#	$2 INT	Actual argument count: "$#"
#	$3 STR	Command's name for error message (optional)
validate_strict_arg_count() {
	local -r expected="$1"
	local -r actual="$2"
	local -r command="${3-:Command}"
	if [[ "$actual" -ne "$expected" ]]; then
		log_error "${command} requires exactly ${expected} argument(s)."
		return 1
	fi
}

# Arguments:
#	$1 INT	Minimum argument count
#	$2 INT	Actual argument count: "$#"
#	$3 STR	Command's name for error message (optional)
validate_min_arg_count() {
	local -r min="$1"
	local -r actual="$2"
	local -r command="${3-:Command}"
	if [[ "$actual" -lt "$min" ]]; then
		log_error "${command} requires a minimum of ${min} argument(s)."
		return 1
	fi
}

# Arguments:
#	$1 INT	Maximum argument count
#	$2 INT	Actual argument count: "$#"
#	$3 STR	Command's name for error message (optional)
validate_max_arg_count() {
	local -r max="$1"
	local -r actual="$2"
	local -r command="${3-:Command}"
	if [[ "$actual" -gt "$max" ]]; then
		log_error "${command} allows a maximum of ${max} argument(s)."
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
#	$3 STR	Print confirmation message: "true" or "false" (optional)
assert_task_exists() {
	local -r task="$1"
	local -r path="$2"
	local -r print_success="${3:-$PRINT_CONFIRMATION_MESSAGE}"
	local match
	match="$(grep -Fn "$task" "$path")"

	if [[ -z "$match" ]]; then
		error_exit "Task was not saved to ${path##*/}."
	fi

	if [[ "$print_success" == "true" ]]; then
		echo "--"
		echo "${match/:/ }"
	fi
}

# Arguments:
#	$1 STR	Raw input
sanitize_string() {
	local -r str="$1"
	awk '$1=$1' <<< "$str"
}
