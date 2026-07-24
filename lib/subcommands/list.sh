#!/bin/bash

# ===================================================================================== #
# Description:		Prints list of queried tasks.
# Synopsis:			bash todo.sh list [<file-stem>:] [<search-term>
#					[OR <search-term> ...] ...]
# ===================================================================================== #
# todo: footer number of tasks (list length) out of total number of tasks (file length)


parse_args() {
	if [[ "$1" =~ ^[a-z]+:$ ]]
	then
		list_name=${1%:}
		shift
	fi

	keywords="$@"
}


get_list() {
	local path="$1"
	local length=$2
	local output
	output=$( cat -n "$path" )

	echo "$output"
}


print_list() {
	local list="$1"

	cat <<- EOF

	$list

	EOF
}


main() {
	local list_name="todo"
	local keywords
	parse_args "$@"

	local list_path="${DATA_DIR}/${list_name}.txt"
	assert_file_exists "$list_path"

	local list_content
	list_content=$( get_list "$list_path" )

	print_list "$list_content" 
}


main "$@"
