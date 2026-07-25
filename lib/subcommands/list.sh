#!/bin/bash

# ===================================================================================== #
# Description:	Prints list of queried tasks.
# Synopsis:		bash todo.sh list [<filename>] [<search-term>
#				[OR <search-term> ...] ...]
# ===================================================================================== #

get_full_list() {
	local path="$1"
	local space="^[[:space:]]*([0-9]+)[[:space:]]*"
	local date="\[[0-9]{4}-[0-9]{2}-[0-9]{2}\][[:space:]]*"
	cat -n "$path" | sed -E "s/${space}/\1 /g; s/${date}//g"
}

filter_output() {
	local data="$1"
	shift

	local keyword
	local output

	for keyword in "$@"
	do
		output=$(echo "$data" | grep -iF "$keyword" || true)
	done

	echo "$output"
}

get_footer() {
	local path="$1"
	local list="$2"

	local file_lc
	file_lc=$(wc -l < "$path")
	local list_lc
	list_lc=$(printf '%s\n' "$list" | wc -l)

	local filename="${path##*/}"
	local stem="${filename%.*}"
	echo "${stem^^}: ${list_lc} of ${file_lc} tasks"
}

print_list() {
	local list="$1"
	local footer="$2"
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

if [[ ! -s "$SRC_PATH" ]]
then
	echo "'${SRC_PATH##*/}' is currently empty"
	return 0
fi

KEYWORDS="$@"
INDEXED_TASKS=$(get_full_list "$SRC_PATH")

if [[ $# -gt 0 ]]
then
	LIST_CONTENT=$(filter_output "$INDEXED_TASKS" "$KEYWORDS")
else
	LIST_CONTENT="$INDEXED_TASKS"
fi

LIST_FOOTER=$(get_footer "$SRC_PATH" "$LIST_CONTENT")
print_list "$LIST_CONTENT" "$LIST_FOOTER"
