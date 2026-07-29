#!/bin/bash

# ===================================================================================== #
# Description:	Prints list of queried tasks.
# Synopsis:		bash todo.sh list [<filename>] [<keyword> [OR <keyword> ...] ...]
# ===================================================================================== #

get_all_tasks() {
	local src="$1"
	assert_file_not_empty "$src"
	cat -n "$src"
}

stream_data() {
	local stream="$1"
	local and_keywords="$2"
	local keyword

	for keyword in $and_keywords
	do
		stream=$(echo "$stream" | grep -iwF "$keyword")
	done
	echo "$stream"
}

generate_stream() {
	local data="$1"
	local query_str="$2"
	local or_blocks
	local block

	IFS="|" read -ra or_blocks <<< "$query_str"
	for block in "${or_blocks[@]}"
	do
		stream_data "$data" "$block"
	done
}

filter_tasks() {
	local tasks="$1"
	local raw_query="$2"
	local clean_query

	clean_query=$(sed -E "s/${ALL_WS}or${ALL_WS}/|/gI" <<< "$raw_query")
	generate_stream "$tasks" "$clean_query" | sort -nu
}

get_list() {
	local path="$1"
	local query="$2"
	local all_tasks

	if [[ -z "$query" ]]
	then
		get_all_tasks "$path"
	else
		all_tasks=$(get_all_tasks "$path")
		filter_tasks "$all_tasks" "$query"
	fi
}

get_footer() {
	local path="$1"
	local list="$2"

	local list_lc
	list_lc=$(printf '%s' "$list" | grep -c "^")
	local file_lc
	file_lc=$(wc -l < "$path")

	local filename="${path##*/}"
	local stem="${filename%.*}"
	echo "${stem^^}: ${list_lc} of ${file_lc} tasks"
}

print_list() {
	local list="$1"
	local footer="$2"

	if [[ -z "$list" ]]
	then
		list="No match found."
	fi

	cat <<- EOF

	$list
	
	$footer

	EOF
}


# EXECUTION FLOW ====================================================================== #

SRC_PATH="$TODO_ACTIVE_DATA"

if [[ $# -gt 0 ]]
then
	if [[ "$1" =~ ^[a-z]+.txt$ ]]
	then
		SRC_PATH=$(get_data_path "$1")
		shift
	fi
fi

assert_file_not_empty "$SRC_PATH"

QUERY="$*"
QUERIED_LIST=$(get_list "$SRC_PATH" "$QUERY")
LIST_CONTENT=$(format_tasks "$QUERIED_LIST" "$INCLUDE_DATE")

LIST_FOOTER=$(get_footer "$SRC_PATH" "$LIST_CONTENT")
print_list "$LIST_CONTENT" "$LIST_FOOTER"
