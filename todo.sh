#!/bin/bash

# ================================================================================================= #
# todo.sh: A simple command-line todo list manager													#
# ================================================================================================= #



# Usage
# ================================================================================================= #

usage() {
	cat << EOF

Usage: ./todo.sh <command>

Available commands:

  add     Add task to todo list.
  list    View all current tasks in todo list.
  done    View all completed tasks in done list.

EOF
	exit 0
}



# Global variables
# ================================================================================================= #

# Paths
TODOTXT="./todo.txt"
DONETXT="./done.txt"



# Core functions
# ================================================================================================= #

# View all todo tasks
#view_todos() {}

# View all done tasks
#view_done() {}

# Add a new todo
add_todo() {
	local new_todo
	read -p "TODO: " new_todo
	echo $new_todo >> $TODOTXT
}

# Delete a todo
#delete_todo() {}

# Reword a todo
#reword_todo() {}

# Move a task from todo to done
#todo_to_done() {}

# Move a task from done to todo
#done_to_todo() {}



# Parse arguments
# ================================================================================================= #

if [[ -z $1 ]]
then
	usage
fi

while [[ $# -gt 0 ]]
do
	case $1 in
		add)
			add_todo
			shift
			;;
		*)
			usage
			;;
	esac
done
