#!/bin/bash

# ================================================================================================= #
# todo.sh: A simple command-line todo list manager													#
# ================================================================================================= #
# To execute this script, run: ./todo.sh															#



# Global variables
# ================================================================================================= #

todotxt="./todo.txt"
donetxt="./done.txt"



# Functions
# ================================================================================================= #

# view all todo items
#view_todos() {}

# view all done items
#view_done() {}

# create a new todo item
create_todo() {
	local new_todo
	read -p "todo: " new_todo
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

# main menu for todo list manager
#main_menu() {
#}



# Point of entry
# ================================================================================================= #

create_todo
