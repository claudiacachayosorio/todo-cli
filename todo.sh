#!/bin/bash

# ================================================================================================= #
# todo.sh: A simple command-line todo list manager													#
# ================================================================================================= #
# To execute this script, run: ./todo.sh <arguments>												#



# Global variables
# ================================================================================================= #

# Run command
RUN=$0

# Paths
TODOTXT="./todo.txt"
DONETXT="./done.txt"



# Usage
# ================================================================================================= #

usage() {
	echo ""
	echo "Usage: $RUN <arguments>"
	echo ""
	echo "Options:"
}

usage



# Parse arguments
# ================================================================================================= #

#while [[ $# -gt 0 ]]
#do
	#case $1 in
	#esac
#done



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
