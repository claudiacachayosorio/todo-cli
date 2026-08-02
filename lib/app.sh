#!/bin/bash

# =========================================================================== #
# Description:	Subcommand functions for todo-cli.
# =========================================================================== #

# =========================================================================== #
# Command:		bash todo.sh help
# =========================================================================== #

todo_help() {
	cat <<- EOF

	USAGE
	bash todo.sh <command> [<argument>...]

	COMMANDS
	add   <task [+<project-tag>...] [@<context-tag>...] ...>
	del   <line-number>...
	done  <line-number>...
	undo  <line-number>...
	list  [<filename>] [<keyword> [or <keyword> ...] ...]

	EOF
	exit 0
}

# =========================================================================== #
# Command:		bash todo.sh add
# =========================================================================== #

todo_add() {
	echo "add: '${*}'"
	#validate_arg_count "min" "1" "$#"
	#local -r task_content="$*"
	#local date_created
	#local new_task

	#date_created="$(date +%F)"
	#new_task="${date_created} ${task_content}"
	#printf "%s\n" "$new_task" >> "$TODO_ACTIVE_DATA"
	#assert_task_exists "$new_task" "$TODO_ACTIVE_DATA"
}

# =========================================================================== #
# Command:		bash todo.sh del
# =========================================================================== #

todo_del() {
	echo "remove: '${*}'"
	#validate_arg_count "min" "1" "$#"
	#local total_deleted_lines="$#"
	#local data_path="$TODO_ACTIVE_DATA"
	#local line_count
	#local line_number

	#if [[ $1 =~ ^[a-z]+$ ]]; then
	#	data_path="${TODO_DATA_DIR}/${1}.txt"
	#	assert_file_exists "$data_path"
	#	shift
	#fi

	#line_count="$(wc -l < $data_path)"

	#for line_number in "$@"; do
	#	if [[ ! "$line_number" =~ ^[0-9]+$ ]]; then
	#		log_error "'${line_number}' is not an integer"
	#		return 1

	#	elif [[ "$line_number" -eq 0 || "$line_number" -gt "$line_count" ]]; then
	#		log_error "line ${line_number} not found"
	#		return 1

	#	else
	#		sed -i "${line_number}d" "$data_path"
	#	fi
	#done
}

# =========================================================================== #
# Command:		bash todo.sh done
# =========================================================================== #

todo_done() {
	echo "done: '${*}'"
}

# =========================================================================== #
# Command:		bash todo.sh undo
# =========================================================================== #

todo_undo() {
	echo "undo: '${*}'"
}

# =========================================================================== #
# Command:		bash todo.sh list
# =========================================================================== #

get_all_tasks() {
	local -r src="$1"
	assert_file_not_empty "$src"
	cat -n "$src"
}

stream_data() {
	local -r keywords="$1"
	local stream="$2"
	local keyword

	for keyword in $keywords; do
		stream="$(echo "$stream" | grep -iwF "$keyword")"
	done
	echo "$stream"
}

generate_stream() {
	local data="$1"
	local query_str="$2"
	local query_blocks
	local block

	IFS="|" read -ra query_blocks <<< "$query_str"
	for block in "${query_blocks[@]}"; do
		stream_data "$block" "$data"
	done
}

filter_tasks() {
	local tasks="$1"
	local raw_query="$2"
	local clean_query
	clean_query="$(sed -E "s/${ALL_WS}or${ALL_WS}/|/gI" <<< "$raw_query")"
	generate_stream "$tasks" "$clean_query" | sort -nu
}

get_list() {
	local path="$1"
	local query="$2"
	local all_tasks

	if [[ -z "$query" ]]; then
		get_all_tasks "$path"
	else
		all_tasks="$(get_all_tasks "$path")"
		filter_tasks "$all_tasks" "$query"
	fi
}

get_footer() {
	local path="$1"
	local list="$2"

	local list_lc
	list_lc="$(printf '%s' "$list" | grep -c "^")"
	local file_lc
	file_lc="$(wc -l < "$path")"

	local filename="${path##*/}"
	local stem="${filename%.*}"
	echo "${stem^^}: ${list_lc} of ${file_lc} tasks"
}

print_list() {
	local list="$1"
	local footer="$2"

	if [[ -z "$list" ]]; then
		list="No match found."
	fi

	cat <<- EOF

	$list
	
	$footer

	EOF
}

format_task_layout() {
	local -r str="$1"
	local -r date="${2:-TODO_DATE_REGEX}"
	local -r sep="${3:-|}"
	sed -E "s/^([0-9]+) ?:?(${date}) /\1${sep}\2${sep}/" <<< "$str"
}

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

format_date() {
	local -r tasks="$1"
	local -r current_regex="${2:-TODO_DATE_REGEX}"
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

handle_date() {
	local -r str="$1"
	local -r sep="$2"
	local -r 
	local -r cfg_display_date="$4"

	if [[ "$DISPLAY_DATE" == "false" ]]; then
		sed -E "s/${TODO_DATE_REGEX}${sep}//g" <<< "$str"
		return 0
	fi

	if [[ "${DISPLAY_DATE_FORMAT^^}" != "$TODO_DATE_FORMAT" ]]; then
		format_date "$str" "$TODO_DATE_REGEX" "$DISPLAY_DATE_FORMAT"
	fi
}

format_tasks() {
	local -r tasks_str="$1"
	clean_spaces "$tasks_str" \
	| format_task_layout "$TODO_DATE_REGEX" "|" \
	| handle_date "|" \
	| column -t -s "|" -o "$TODO_COL_SPACING"
}

todo_list() {
	echo "list: '${*}'"
	#local src_path="$TODO_ACTIVE_DATA"
	#local query
	#local queried_list
	#local list_content
	#local list_footer

	#if [[ $# -gt 0 ]]; then
	#	if [[ "$1" =~ ^[a-z]+.txt$ ]]; then
	#		src_path="${TODO_DATA_DIR}/${1}"
	#		shift
	#	fi
	#fi

	#assert_file_exists "$src_path"
	#assert_file_not_empty "$src_path"

	#query="$*"
	#queried_list="$(get_list "$src_path" "$query")"
	#list_content="$(format_tasks "$queried_list" "$DISPLAY_DATE")"

	#list_footer="$(get_footer "$src_path" "$list_content")"
	#print_list "$list_content" "$list_footer"
}
