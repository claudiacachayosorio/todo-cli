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

KEYWORDS="$@"
INDEXED_TASKS=$(get_full_list "$SRC_PATH")
LIST_CONTENT="$INDEXED_TASKS"

if [[ $# -gt 0 ]]
then
	for KEYWORD in "$@"
	do
		LIST_CONTENT=$(echo "$INDEXED_TASKS" | grep -iF "$KEYWORD" || true)
	done
fi

LIST_FOOTER=$(get_footer "$SRC_PATH" "$LIST_CONTENT")
print_list "$LIST_CONTENT" "$LIST_FOOTER"
