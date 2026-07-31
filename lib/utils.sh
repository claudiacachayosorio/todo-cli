#!/bin/bash

# ===================================================================================== #
# Description:	Shared utilities for todo.sh and subcommands.
# ===================================================================================== #

COL_INPUT_SEPARATOR="|"
COL_OUTPUT_SEPARATOR=" "
DEFAULT_DATE_FORMAT="YYYY-MM-DD"
DEFAULT_DATE_REGEX="[0-9]{4}-[0-9]{2}-[0-9]{2}"

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
# 	$1 INT	Function's argument count: "$#"
# 	$2 STR	Rule type: "min", "max", "strict"
#	$3 INT	Reference count
validate_arg_count() {
	local -r actual_count=$1
	local -r rule=$2
	local -r ref_count=$3
	local valid_count

	case "$rule" in
		min)	if (( actual_count < ref_count )); then valid_count="false"; fi ;;
		max)	if (( actual_count > ref_count )); then valid_count="false"; fi ;;
		strict)	if (( actual_count != ref_count )); then valid_count="false"; fi ;;
		*)		error_exit "Invalid argument." ;;
	esac

	if [[ "$valid_count" == "false" ]]; then
		log_error "Invalid number of arguments."
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
#	$1 STR	Raw input
clean_spaces() {
	local -r str="$1"
	awk '$1=$1' <<< "$str"
}

# Arguments:
#	$1 STR	Tasks
#	$2 STR	Date regex pattern: "$DEFAULT_DATE_REGEX"
#	$3 STR	Column input separator: "$COL_INPUT_SEPARATOR"
format_task_layout() {
	local -r str="$1"
	local -r date="${2:-DEFAULT_DATE_REGEX}"
	local -r sep="${3:-COL_INPUT_SEPARATOR}"
	sed -E "s/^([0-9]+) ?:?(${date}) /\1${sep}\2${sep}/" <<< "$str"
}

# Arguments:
#	$1 STR	Display date format from config: "$DISPLAY_DATE_FORMAT"
get_date_cmd_format() {
	local -r display_format="${1:-DISPLAY_DATE_FORMAT}"
	local -r year_format="${initial_str//[^Y]/}"
	local cmd_format="+${initial_str^^}"

	case "$year_format" in
		"")		: ;;
		YY)		cmd_format="${cmd_format//YY/%y}" ;;
		YYYY)	cmd_format="${cmd_format//YYYY/%Y}" ;;
		*)		cmd_format="${cmd_format//+(Y)/%Y}" ;;
	esac

	cmd_format="${cmd_format//+(M)/%m}"
	cmd_format="${cmd_format//+(D)/%d}"
	echo "$cmd_format"
}

# Arguments:
#	$1 STR	Tasks
#	$2 STR	Regex pattern for date as stored in txt files: "$DEFAULT_DATE_REGEX"
#	$3 STR	Display date format from config: "$DISPLAY_DATE_FORMAT"
format_date() {
	local -r tasks="$1"
	local -r current_regex="${2:-DEFAULT_DATE_REGEX}"
	local -r cfg_format="${3:-DISPLAY_DATE_FORMAT}"
	local cmd_format
	local line
	local src_date
	local formatted_date

	cmd_format="$(get_date_cmd_format "$cfg_format")"

	while IFS= read -r line; do
		if [[ "$line" =~ $current_regex ]]; then
			src_date="${BASH_REMATCH[0]}"
			formatted_date="$(date -d "$src_date" "$cmd_format")"
			echo "${line/$src_date/$formatted_date}"
		fi
	done <<< "$tasks"
}

# Arguments:
#	$1 STR	Tasks
#	$2 STR	Separator
handle_date() {
	local -r str="$1"
	local -r sep="$2"
	local -r 
	local -r cfg_display_date="$4"

	if [[ "$DISPLAY_DATE" == "false" ]]; then
		sed -E "s/${DEFAULT_DATE_REGEX}${sep}//g" <<< "$str"
		return 0
	fi

	if [[ "${DISPLAY_DATE_FORMAT^^}" != "$DEFAULT_DATE_FORMAT" ]]; then
		format_date "$str" "$DEFAULT_DATE_REGEX" "$DISPLAY_DATE_FORMAT"
	fi
}

# Arguments:
#	$1 STR	Tasks
format_tasks() {
	local -r tasks_str="$1"
	clean_spaces "$tasks_str" \
	| format_task_layout "$DEFAULT_DATE_REGEX" "$COL_INPUT_SEPARATOR" \
	| handle_date "$COL_INPUT_SEPARATOR" \
	| column -t -s "$COL_INPUT_SEPARATOR" -o "$COL_OUTPUT_SEPARATOR"
}
