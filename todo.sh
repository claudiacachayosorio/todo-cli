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
	local t_file_options=("$@")
	local t_file_basename=""

	if [[ "${#t_file_options[@]}" -eq 0 ]]
	then
		t_file_options=("todo")
	fi

	for t_file_basename in "${t_file_options[@]}"
	do
		if [[ "$t_file_basename" == "todo" ]]
		then
			local t_file_output=$(cat -n "$TODO_TXT")
			cat <<- EOF

			tasks to do:

			$t_file_output

			EOF

		elif [[ "$t_file_basename" == "done" ]]
		then
			local t_file_output=$(cat -n "$DONE_TXT")
			cat <<- EOF

			tasks done:

			$t_file_output

			EOF

		else
			echo "error: '$t_file_basename' is not a valid input"
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
