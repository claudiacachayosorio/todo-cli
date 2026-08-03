#!/usr/bin/env bash
# =========================================================================== #
# Description:	Subcommand functions for todo-cli.
# =========================================================================== #

# bash todo.sh help
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

# bash todo.sh add
# =========================================================================== #
todo_add() {
	_todo_validate_min_arg_count "1" "$#" "todo.sh add"
	local -r raw_input="$*"

	local task_description
	task_description="$(_todo_sanitize_string "$raw_input")"
	local date_created
	date_created="$(date +%F)"

	local -r task="${date_created} ${task_description}"
	printf "%s\n" "$task" >> "$TODO_DB_ACTIVE"
	_todo_assert_task_exists "$task" "$TODO_DB_ACTIVE"
}

# bash todo.sh del
# =========================================================================== #
todo_del() {
	echo "del: '${*}'"
	#_todo_validate_min_arg_count "1" "$#" "todo.sh del"
	#local total_deleted_lines="$#"
	#local data_path="$TODO_DB_ACTIVE"
	#local line_count
	#local line_number

	#if [[ $1 =~ ^[a-z]+$ ]]; then
	#	data_path="${TODO_DB_ACTIVE}/${1}.txt"
	#	_todo_assert_file_exists "$data_path"
	#	shift
	#fi

	#line_count="$(wc -l < $data_path)"

	#for line_number in "$@"; do
	#	if [[ ! "$line_number" =~ ^[0-9]+$ ]]; then
	#		_todo_log_error "'${line_number}' is not an integer"
	#		return 1

	#	elif [[ "$line_number" -eq 0 || "$line_number" -gt "$line_count" ]]; then
	#		_todo_log_error "line ${line_number} not found"
	#		return 1

	#	else
	#		sed -i "${line_number}d" "$data_path"
	#	fi
	#done
}

# bash todo.sh done
# =========================================================================== #
todo_done() {
	echo "done: '${*}'"
}

# bash todo.sh undo
# =========================================================================== #
todo_undo() {
	echo "undo: '${*}'"
}

# bash todo.sh list
# =========================================================================== #
_todo_get_all_tasks() {
	local -r src="$1"
	_todo_assert_file_not_empty "$src"
	cat -n "$src"
}

_todo_stream_data() {
	local -r keywords="$1"
	local stream="$2"
	local keyword

	for keyword in $keywords; do
		stream="$(echo "$stream" | grep -iwF "$keyword")"
	done
	echo "$stream"
}

_todo_generate_stream() {
	local data="$1"
	local query_str="$2"
	local query_blocks
	local block

	IFS="|" read -ra query_blocks <<< "$query_str"
	for block in "${query_blocks[@]}"; do
		_todo_stream_data "$block" "$data"
	done
}

_todo_filter_tasks() {
	local tasks="$1"
	local raw_query="$2"
	local clean_query
	clean_query="$(sed -E "s/${ALL_WS}or${ALL_WS}/|/gI" <<< "$raw_query")"
	_todo_generate_stream "$tasks" "$clean_query" | sort -nu
}

_todo_get_list() {
	local path="$1"
	local query="$2"
	local all_tasks

	if [[ -z "$query" ]]; then
		_todo_get_all_tasks "$path"
	else
		all_tasks="$(_todo_get_all_tasks "$path")"
		_todo_filter_tasks "$all_tasks" "$query"
	fi
}

_todo_get_footer() {
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

_todo_print_list() {
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

_todo_format_task_layout() {
	local -r str="$1"
	local -r date="${2:-TODO_DATE_REGEX}"
	local -r sep="${3:-|}"
	sed -E "s/^([0-9]+) ?:?(${date}) /\1${sep}\2${sep}/" <<< "$str"
}

_todo_get_date_cmd_format() {
	local -r display_format="${1:-TODO_DISPLAY_DATE_FORMAT}"
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

_todo_format_date() {
	local -r tasks="$1"
	local -r current_regex="${2:-TODO_DATE_REGEX}"
	local -r cfg_format="${3:-TODO_DISPLAY_DATE_FORMAT}"
	local cmd_format
	local line
	local src_date
	local formatted_date

	cmd_format="$(_todo_get_date_cmd_format "$cfg_format")"

	while IFS= read -r line; do
		if [[ "$line" =~ $current_regex ]]; then
			src_date="${BASH_REMATCH[0]}"
			formatted_date="$(date -d "$src_date" "$cmd_format")"
			echo "${line/$src_date/$formatted_date}"
		fi
	done <<< "$tasks"
}

_todo_handle_date() {
	local -r str="$1"
	local -r sep="$2"

	if [[ "$TODO_DISPLAY_DATE" == "false" ]]; then
		sed -E "s/${TODO_DATE_REGEX}${sep}//g" <<< "$str"
		return 0
	fi

	if [[ "${TODO_DISPLAY_DATE_FORMAT^^}" != "YYYY-MM-DD" ]]; then
		_todo_format_date "$str" "$TODO_DATE_REGEX" "$TODO_DISPLAY_DATE_FORMAT"
	fi
}

_todo_format_tasks() {
	local -r tasks_str="$1"
	_todo_sanitize_string "$tasks_str" \
	| _todo_format_task_layout "$TODO_DATE_REGEX" "|" \
	| _todo_handle_date "|" \
	| column -t -s "|" -o "$TODO_COL_SPACING"
}

todo_list() {
	echo "list: '${*}'"
	#local src_path="$TODO_DB_ACTIVE"
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

	#_todo_assert_file_exists "$src_path"
	#_todo_assert_file_not_empty "$src_path"

	#query="$*"
	#queried_list="$(_todo_get_list "$src_path" "$query")"
	#list_content="$(_todo_format_tasks "$queried_list" "$TODO_DISPLAY_DATE")"

	#list_footer="$(_todo_get_footer "$src_path" "$list_content")"
	#_todo_print_list "$list_content" "$list_footer"
}
