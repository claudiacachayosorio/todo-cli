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
  t <task>                   Add new task.
  t+ <tasks>... ;            Add multiple tasks.
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
	local list_file=$TODOTXT

	if [[ -n $1 ]]
	then
		if [[ $1 == "todo" ]]
		then :

		elif [[ $1 == "done" ]]
		then
			list_file=$DONETXT

		else
			echo "error: '$1' is not a list option"
			return 1
		fi
	fi

	echo ""
	cat -n $list_file
	echo ""
}

# Add a new task
# bash todo.sh t
add_task() {
	local new_task=$1

	while [[ -z $new_task ]]
	do
		read new_task
	done

	echo $new_task >> $TODOTXT
}

# Add multiple tasks
# bash todo.sh t+
add_multiple_tasks() {
	local task_str=""
	local task_arr=()

	read -d ";" task_str
	IFS='\n' read -a task_arr <<< "$task_str"
	#printf "%s\n" "${task_arr[@]}" >> $TODOTXT
	echo $task_arr
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
		t+)
			shift 1
			add_multiple_tasks
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
