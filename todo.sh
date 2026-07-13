#!/bin/bash

# ===================================================================================== #
# todo-cli: a simple command line task manager											#
# ===================================================================================== #




# Settings
# ===================================================================================== #

shopt -s extglob




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




# Usage
# ===================================================================================== #

usage() {
	cat << EOF

USAGE
  bash todo.sh <command> [<args>]

COMMANDS
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




# Functions
# ===================================================================================== #

# TODO: add today list?

# Add new tasks
# bash todo.sh add

add_task() {
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
		local option_str=$1
		local list_title=$2
		local header=""

		# Get list from txt file
		local file_basename=$(tr -d '=0-9' <<< $option_str)
		local file_path="${TXT_DIR}${file_basename}.txt"
		local file_output=$(cat -n "$file_path")

		# Get list length
		local file_length=$(wc -l < $file_path)
		local length_limit=$(tr -d 'a-z=' <<< $option_str)

		# If length_limit includes entire file
		if [[ $length_limit -ge $file_length ]]
		then
			length_limit=""
		fi

		case $length_limit in
			# If no limit
			"")
				header="$list_title - ALL"
				;;

			# If limit is specified
			+([0-9]))
				header="$list_title - $length_limit LATEST"
				file_output=$(tail -n "$length_limit" <<< "$file_output")
				;;
				
			# Invalid input
			*)
				echo "error: '$length_limit' is not an integer"
				return 1
				;;
		esac

		# Formatted output
		cat <<- EOF

		$header

		$file_output

		EOF
	fi
}

list_tasks() {
	local default_options="todo"
	local list_title=""

	# If no options specified
	if [[ $# -eq 0 ]]
	then
		set -- "$@" "$default_options"
	fi

	# Parse options
	while [[ $# -gt 0 ]]
	do
		case "$1" in
			# Tasklist from todo.txt
			todo|todo=*)
				list_title="TASKS TO DO"
				print_list "$1" "$list_title"
				shift
				;;

			# Tasklist from done.txt
			done|done=*)
				list_title="TASKS DONE"
				print_list "$1" "$list_title"
				shift
				;;

			# Invalid option
			*)
				echo "error: '$1': invalid option"
				return 1
				;;
		esac
	done
}


# Mark task as done
# bash todo.sh done
# TODO: add timestamp of when completed?

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
