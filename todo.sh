#!/bin/bash

# ================================================================================================= #
# todo.sh: A simple command-line todo list manager													#
# ================================================================================================= #
# To execute this script, run: ./todo.sh <command>													#



# Global variables
# ================================================================================================= #

# Paths
todotxt="./todo.txt"
donetxt="./done.txt"



# Usage
# ================================================================================================= #

usage() {
	echo "usage: $0	<command>"
	echo ""
	echo "Options:"
}



# Parse arguments
# ================================================================================================= #

while [[ $# -gt 0 ]]
do
	case $1 in
	esac
done



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
	echo $new_todo >> $todotxt
}

# Delete a todo
#delete_todo() {}

# Reword a todo
#reword_todo() {}

# Move a task from todo to done
#todo_to_done() {}

# Move a task from done to todo
#done_to_todo() {}
