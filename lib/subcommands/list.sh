#!/bin/bash

# ===================================================================================== #
# Description:		Prints list of queried tasks.
# Synopsis:			bash todo.sh list [<file-stem>:] [<search-term>
#					[OR <search-term> ...] ...]
# ===================================================================================== #
# TODO: footer number of tasks (list length) out of total number of tasks (file length)

get_list() {
	local path="$1"
	local length=$2
	local output
	output=$(cat -n "$path")
	echo "$output"
}

print_list() {
	local list="$1"
	cat <<- EOF

	$list

	EOF
}


# EXECUTION FLOW ====================================================================== #

DATA_STEM="todo"

if [[ "$1" =~ ^[a-z]+:$ ]]
then
	DATA_STEM=${1%:}
	shift
fi

SEARCH_TERMS="$@"

DATA_PATH="${DATA_DIR}/${DATA_STEM}.txt"
assert_file_exists "$DATA_PATH"

LIST_CONTENT=$(get_list "$DATA_PATH")
print_list "$LIST_CONTENT"
