#!/bin/bash

# ================================================================================================= #
# todo.sh: A simple command-line todo list manager													#
# ================================================================================================= #



# Usage
# ================================================================================================= #

usage() {
	cat << EOF

Usage: bash todo.sh <command> [<args>]

Commands:
  todo | t
  view | v [todo|done]

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

	read new_todo

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
		todo|t)
			add_todo
			shift
			;;
		*)
			usage
			;;
	esac
done
