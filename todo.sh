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
  add <task-name> [+ <task-name> ...]
  list [{todo | done}[=<number-limit>] ...]
  done <task-number> ...
  undo <task-number> ...
  delete <task-number> ...
  edit <task-number> <new-name>
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
TXT_DIR="./txt/"
TODO_TXT="${TXT_DIR}todo.txt"
DONE_TXT="${TXT_DIR}done.txt"




# Functions
# ===================================================================================== #

# Add new tasks
# bash todo.sh add

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
	local task_output=$(sed "s/$task_delim/\n/g" <<< $task_input)

	# Append tasks to txt file
	printf "%s\n" "$task_output" >> $TODO_TXT	\
		&&	grep -xn "$task_output" $TODO_TXT	\
		|	awk -F':' '{ printf " + %3d  %s\n", $1, substr($0, index($0, ":") + 1) }'
}


# View task list
# bash todo.sh list

print_list() {
	# If all required arguments
	if [[ -n $1 && -n $2 ]]
	then
		# Arguments
		local option_str=$1
		local header=$2

		# Get list from txt file
		local file_basename=$(tr -d '=0-9' <<< $option_str)
		local file_path="${TXT_DIR}${file_basename}.txt"
		local file_output=$(cat -n "$file_path")

		# Get list length limit
		local length_limit=$(tr -d 'a-z=' <<< $option_str)

		# If length limit is specified
		if [[ $length_limit =~ ^[0-9]+$ ]]
		then
			local file_output=$(tail -n "$length_limit" <<< "$file_output")
		fi

		# Formatted output
		cat <<- EOF

		$header

		$file_output

		EOF
	fi
}

list_tasks() {
	# Default options
	local default="todo"

	# If no options specified
	if [[ $# -eq 0 ]]
	then
		set -- "$@" "$default"
	fi

	# Parse options
	while [[ $# -gt 0 ]]
	do
		case "$1" in
			# Tasklist from todo.txt
			todo|todo=*)
				local header="tasks to do:"
				print_list "$1" "$header"
				shift
				;;

			# Tasklist from done.txt
			done|done=*)
				local header="tasks done:"
				print_list "$1" "$header"
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


# Delete tasks
# bash todo.sh delete

#delete_task() {}


# Edit a task
# bash todo.sh edit

#edit_task() {}




# Point of entry
# ===================================================================================== #

# Parse arguments
case $COMMAND in
	help)		usage ;;
	add)		add_task "$OPTIONS_STR" ;;
	list)		list_tasks "${OPTIONS[@]}" ;;
	done)		mark_as_done "${OPTIONS[@]}" ;;
	undo)		mark_as_todo "${OPTIONS[@]}" ;;
	edit)		rewrite_task "${OPTIONS[@]}" ;;
	delete)		delete_task "${OPTIONS[@]}" ;;
	*)			echo "error: invalid command" ;;
esac
