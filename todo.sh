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
  li [todo | done]           View task list.
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

# View list of tasks
# bash todo.sh li
# TODO: add argument to limit number of tasks displayed (ie: last 5 tasks)
view_list() {
	local li_names=("$@")
	local li_name_i=""

	if [[ "${#li_names[@]}" -eq 0 ]]
	then
		li_names=("todo")
	fi

	for li_name_i in "${li_names[@]}"
	do
		if [[ "$li_name_i" == "todo" ]]
		then
			local li_todo_output=$(cat -n "$TODO_TXT")
			cat <<- EOF

			tasks to do:

			$li_todo_output

			EOF

		elif [[ "$li_name_i" == "done" ]]
		then
			local li_done_output=$(cat -n "$DONE_TXT")
			cat <<- EOF

			tasks done:

			$li_done_output

			EOF

		else
			echo "error: '$li_name_i' is not a list option"
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
	li)
		view_list "${OPTIONS_ARR[@]}"
		;;
	del)
		delete_task
		;;
	*)
		usage
		;;
esac
