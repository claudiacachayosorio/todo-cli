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



# Functions
# ================================================================================================= #

# View all todo tasks
#view_todos() {}

# View all done tasks
#view_done() {}

# Add a new todo
add_todo() {
	local new_todo
	echo "input: todo" #temp
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



# Point of entry
# ================================================================================================= #
