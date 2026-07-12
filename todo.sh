#!/bin/bash

# ===================================================================================== #
# todo-cli: a simple command line task manager											#
# ===================================================================================== #



# Usage
# ===================================================================================== #

usage() {
	cat << EOF

Usage: bash todo.sh <command> [<args>]

Commands:
  t <task> [+ <task> ...]    Add tasks.
  v [todo | done]            View tasks.
  del <line-number ...>      Delete tasks.

EOF
	exit 0
}



# Global variables
# ===================================================================================== #

# Arguments
COMMAND=$1
OPTIONS_ARR=("${@:2}")
OPTIONS_STR="${*:2}"

# Paths
TODO_TXT="./todo.txt"
DONE_TXT="./done.txt"



# Helper functions
# ===================================================================================== #

print_list() {
	if [[ -n $1 && -n $2 ]]
	then
		local list_header=$1
		local file_path=$2
		local file_output=$(cat -n "$file_path")

		cat <<- EOF

		$list_header

		$file_output

		EOF
	fi
}



# Core functions
# ===================================================================================== #

# Add new tasks
# bash todo.sh t
add_task() {
	local t_input=$1
	local t_delim="[[:space:]]*+[[:space:]]*"

	while [[ -z $t_input ]]
	do
		read t_input
	done

	local t_output=$(echo $t_input | sed "s/$t_delim/\n/g")

	printf "%s\n" "$t_output" >> $TODO_TXT	\
		&&	grep -xn "$t_output" $TODO_TXT	\
		|	awk -F':' '{ printf " + %3d  %s\n", $1, substr($0, index($0, ":") + 1) }'
}

# View tasks
# bash todo.sh v
# TODO: add argument to limit number of tasks displayed (ie: last 5 tasks)
view_tasks() {
	local v_file_options=("$@")
	local file_basename=""

	if [[ "${#v_file_options[@]}" -eq 0 ]]
	then
		v_file_options=("todo")
	fi

	for file_basename in "${v_file_options[@]}"
	do
		if [[ "$file_basename" == "todo" ]]
		then
			local list_header="tasks to do:"
			print_list "$list_header" "$TODO_TXT"

		elif [[ "$file_basename" == "done" ]]
		then
			local list_header="tasks done:"
			print_list "$list_header" "$DONE_TXT"

		else
			echo "error: '$file_basename' is not a valid input"
		fi
	done
}

# Delete tasks
# bash todo.sh del
#delete_task() {}

# Rewrite a task
#rewrite_task() {}

# Mark todo task as done
#mark_as_done() {}

# Mark done task as todo
#mark_as_todo() {}



# Parse arguments
# ===================================================================================== #

case $1 in
	t)
		add_task "$OPTIONS_STR"
		;;
	v)
		view_tasks "${OPTIONS_ARR[@]}"
		;;
	del)
		delete_task
		;;
	*)
		usage
		;;
esac
