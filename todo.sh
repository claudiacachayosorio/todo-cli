#!/bin/bash

# ===================================================================================== #
# todo.sh: A simple command-line todo list manager										#
# ===================================================================================== #



# Usage
# ===================================================================================== #

usage() {
	cat << EOF

Usage: bash todo.sh <command> [<args>]

Commands:
  li [done]                  View list of tasks.
  t <task> [--<tasks>...]    Add new tasks.
  del [<line-number>]        Delete one or more tasks.

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

# Add new tasks
# bash todo.sh t
add_task() {
	local t_input=$1
	local t_dlm="[[:space:]]*--[[:space:]]*"

	while [[ -z $t_input ]]
	do
		read t_input
	done

	echo $t_input | sed "s/$t_dlm/\n/g" >> $TODOTXT	
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
		li)
			view_list $2
			set --
			;;
		t)
			shift 1
			add_task "$*"
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
