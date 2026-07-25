#!/bin/bash

# ===================================================================================== #
# Description:	Prints list of queried tasks.
# Synopsis:		bash todo.sh list [<file-stem>:] [<search-term>
#				[OR <search-term> ...] ...]
# ===================================================================================== #
# TODO: footer number of tasks (list length) out of total number of tasks (file length)

get_list() {
	local path="$1"
	local length=$2
	cat -n "$path"
}

print_list() {
	local list="$1"
	cat <<- EOF

	$list

	EOF
}


# EXECUTION FLOW ====================================================================== #

DATA_PATH="$TODOTXT"
if [[ "$1" =~ ^[a-z]+:$ ]]
then
	DATA_PATH=$(get_data_path "$1")
	shift
fi

SEARCH_TERMS="$@"

LIST_CONTENT=$(get_list "$DATA_PATH")
print_list "$LIST_CONTENT"
