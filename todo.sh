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

# view all todo items
#view_todos() {}

# view all done items
#view_done() {}

# add a new todo item
add_todo() {
	local new_todo
	echo "input: todo" #temp
	read new_todo
	echo $new_todo >> $todotxt
}

# delete a todo item
#delete_todo() {}

# reword a todo item
#reword_todo() {}

# mark a todo item as done
#todo_to_done() {}

# mark a done item as todo
#done_to_todo() {}



# Point of entry
# ================================================================================================= #
