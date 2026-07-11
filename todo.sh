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

# Paths
TODOTXT="./todo.txt"
DONETXT="./done.txt"



# Core functions
# ===================================================================================== #

# Add new tasks
# bash todo.sh t
add_task() {
	local t_input=$1

	while [[ -z $t_input ]]
	do
		read t_input
	done

	t_output=$(echo $t_input | sed "s/[[:space:]]*+[[:space:]]*/\n/g")
	printf "%s\n" "$t_output" >> $TODOTXT

	# Confirm new tasks added
	grep -xn "$t_output" $TODOTXT |
		awk -F':' '{
			printf " + %3d  %s\n", $1, substr($0, index($0, ":") + 1)
		}'
}

# View list of tasks
# bash todo.sh li
view_list() {
	local li_file=$TODOTXT

	if [[ -n $1 ]]
	then
		if [[ $1 == "todo" ]]
		then :

		elif [[ $1 == "done" ]]
		then
			li_file=$DONETXT

		else
			echo "error: '$1' is not a list option"
			return 1
		fi
	fi

	echo ""
	cat -n $li_file
	echo ""
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

if [[ $# -eq 0 ]]
then
	usage
fi

while [[ $# -gt 0 ]]
do
	case $1 in
		t)
			shift 1
			add_task "$*"
			set --
			;;
		li)
			view_list $2
			set --
			;;
		del)
			shift 1
			delete_task "$@"
			set --
			;;
		*)
			usage
			;;
	esac
done
