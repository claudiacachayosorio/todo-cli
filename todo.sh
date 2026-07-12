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
  t <task-name> [+ <task-name> ...]
  tl [{todo | done}[=<number-limit> | all] ...]
  done <task-number> ...
  undo <task-number> ...
  del <task-number> ...
  rew <task-number> <new-task-name>
  help

EOF
	exit 0
}




# Global variables
# ===================================================================================== #

# Arguments
COMMAND=$1
OPTIONS=("${@:2}")
OPTIONS_STR="${*:2}"

# Paths
TODO_TXT="./todo.txt"
DONE_TXT="./done.txt"




# Core functions
# ===================================================================================== #

# Add new tasks
# bash todo.sh t

add_task() {
	# User input
	local task_input=$1
	local task_delim="[[:space:]]*+[[:space:]]*"

	# If no tasks
	while [[ -z $task_input ]]
	do
		# Prompt user input
		read task_input
	done

	# Format tasks
	local task_output=$(echo $task_input | sed "s/$task_delim/\n/g")

	# Append tasks to txt file
	printf "%s\n" "$task_output" >> $TODO_TXT	\
		# If successful
		&&	grep -xn "$task_output" $TODO_TXT	\
		|	awk -F':' '{ printf " + %3d  %s\n", $1, substr($0, index($0, ":") + 1) }'
}


# View tasklist
# bash todo.sh tl
# TODO: add argument to limit number of tasks displayed (ie: last 5 tasks)

print_tasklist() {
	# If all required arguments
	if [[ -n $1 && -n $2 ]]
	then
		# Required arguments
		local header=$1
		local file_path=$2
		# Get list from txt file
		local file_output=$(cat -n "$file_path")

		# Formatted output
		cat <<- EOF

		$header

		$file_output

		EOF
	fi
}

tasklist_options() {
	# Default options
	local default="todo"
	# Tasklist headers
	local todo_header="tasks to do:"
	local done_header="tasks done:"

	# If no options specified
	if [[ $# -eq 0 ]]
	then
		# Set to default
		set -- "$@" "$default"
	fi

	# Parse options
	while [[ $# -gt 0 ]]
	do
		case "$1" in
			# Tasklist from todo.txt
			todo|todo=*)
				print_list "$todo_header" "$TODO_TXT"
				shift
				;;

			# Tasklist from done.txt
			done|done=*)
				print_list "$done_header" "$DONE_TXT"
				shift
				;;

			# Invalid argument
			*)
				echo "error: '$1': invalid option"
				return 1
				;;
		esac
	done
}


# Mark task as done
# bash todo.sh done

#mark_as_done() {}


# Mark task as todo
# bash todo.sh undo

#mark_as_todo() {}


# Rewrite a task
# bash todo.sh edit

#rewrite_task() {}


# Delete tasks
# bash todo.sh del

#delete_task() {}




# Point of entry
# ===================================================================================== #

# Parse arguments
case $COMMAND in
	t)		add_task "$OPTIONS_STR" ;;
	tl)		tasklist_options "${OPTIONS[@]}" ;;
	done)	mark_as_done "${OPTIONS[@]}" ;;
	undo)	mark_as_todo "${OPTIONS[@]}" ;;
	del)	delete_task "${OPTIONS[@]}" ;;
	rew)	rewrite_task "${OPTIONS[@]}" ;;
	help)	usage ;;
	*)		echo "error: invalid command" ;;
esac
