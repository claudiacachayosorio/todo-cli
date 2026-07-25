#!/bin/bash

# ===================================================================================== #
# Description:	Prints list of queried tasks.
# Synopsis:		bash todo.sh list [<file-stem>:] [<search-term>
#				[OR <search-term> ...] ...]
# ===================================================================================== #
# TODO: footer number of tasks (list length) out of total number of tasks (file length)

get_list() {
	local path="$1"
	local terms="$2"

	if [[ -z "$terms" ]]
	then
		cat -n "$path"
	fi
}

format_list() {
	local raw="$1"
	local output="${raw//\[????-??-??\] /}"
	echo "$output"
}

print_list() {
	local list="$1"
	cat <<- EOF

	$list
	EOF
}


# EXECUTION FLOW ====================================================================== #

DATA_PATH="$TODOTXT"
if [[ $# -gt 0 ]]
then
	if [[ "$1" =~ ^[a-z]+:$ ]]
	then
		DATA_PATH=$(get_data_path "$1")
		shift
	fi
fi

SEARCH_TERMS="$@"

RAW_CONTENT=$(get_list "$DATA_PATH" "$SEARCH_TERMS")
LIST_CONTENT=$(format_list "$RAW_CONTENT")
print_list "$LIST_CONTENT"
