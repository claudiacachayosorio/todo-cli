#!/bin/bash

# ===================================================================================== #
# Description:	Prints list of queried tasks.
# Synopsis:		bash todo.sh list [<filename>] [<keyword> [OR <keyword> ...] ...]
# ===================================================================================== #

get_full_list() {
	local path="$1"
	local space="^[[:space:]]*([0-9]+)[[:space:]]*"
	local date="\[[0-9]{4}-[0-9]{2}-[0-9]{2}\][[:space:]]*"
	cat -n "$path" | sed -E "s/${space}/\1 /g; s/${date}//g"
}

generate_stream() {
	local input="$1"
	local query="$2"

	local or_blocks
	IFS="|" read -ra or_blocks <<< "$query"

	local block
	local current_stream

	for block in "${or_blocks[@]}"
	do
		current_stream="$input"
		local term

		for term in $block
		do
			current_stream=$(echo "$current_stream" | grep -iwF "$term")
		done

		echo "$current_stream"
	done
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
	--
	$footer

	EOF
}


# EXECUTION FLOW ====================================================================== #

SRC_PATH="$TODOTXT"

if [[ $# -gt 0 ]]
then
	if [[ "$1" =~ ^[a-z]+.txt$ ]]
	then
		SRC_PATH=$(get_data_path "$1")
		shift
	fi
fi

assert_file_not_empty "$SRC_PATH"
INDEXED_TASKS=$(get_full_list "$SRC_PATH")
LIST_CONTENT="$INDEXED_TASKS"

if [[ -n "$*" ]]
then
	RAW_QUERY="$*"
	QUERY_STRING=$(sed -E "s/[[:space:]]or[[:space:]]/|/gI" <<< "$RAW_QUERY")
	LIST_CONTENT=$(generate_stream "$INDEXED_TASKS" "$QUERY_STRING" | sort -nu)
fi

LIST_FOOTER=$(get_footer "$SRC_PATH" "$LIST_CONTENT")
print_list "$LIST_CONTENT" "$LIST_FOOTER"
