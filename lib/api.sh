#!/bin/bash

# ===================================================================================== #
# Description:	Data manipulation functions for todo-cli
# ===================================================================================== #

# ===================================================================================== #
# Command:		bash todo.sh add
# ===================================================================================== #

todo_add() {
	echo "add: $*"
	#validate_arg_count "min" "1" "$#"
	#local -r task_content="$*"
	#local date_created
	#local new_task

	#date_created="$(date +%F)"
	#new_task="${date_created} ${task_content}"
	#printf "%s\n" "$new_task" >> "$TODO_ACTIVE_DATA"
	#assert_task_exists "$new_task" "$TODO_ACTIVE_DATA"
}

# ===================================================================================== #
# Command:		bash todo.sh remove | bash todo.sh rm
# ===================================================================================== #

todo_remove() {
	echo "remove: $*"
#	validate_arg_count "min" "1" "$#"
#	local total_deleted_lines="$#"
#	local data_path="$TODO_ACTIVE_DATA"
#	local line_count
#	local line_number

#	if [[ $1 =~ ^[a-z]+$ ]]; then
#		data_path="${TODO_DATA_DIR}/${1}.txt"
#		assert_file_exists "$data_path"
#		shift
#	fi

#	line_count="$(wc -l < $data_path)"

#	for line_number in "$@"; do
#		if [[ ! "$line_number" =~ ^[0-9]+$ ]]; then
#			log_error "'${line_number}' is not an integer"
#			return 1

#		elif [[ "$line_number" -eq 0 || "$line_number" -gt "$line_count" ]]; then
#			log_error "line ${line_number} not found"
#			return 1

#		else
#			sed -i "${line_number}d" "$data_path"
#		fi
#	done
}

# ===================================================================================== #
# Command:		bash todo.sh done
# ===================================================================================== #

todo_done() {
	echo "done: $*"
}

# ===================================================================================== #
# Command:		bash todo.sh undo
# ===================================================================================== #

todo_undo() {
	echo "undo: $*"
}
