#!/bin/bash

# ===================================================================================== #
# Description:	Adds tasks to txt file.
# Synopsis:		bash todo.sh add [<file-stem>:] <task [+<project-tag>...]
#				[@<context-tag>...] ...>
# ===================================================================================== #


# EXECUTION FLOW ====================================================================== #

validate_arg_count "$#" "-lt" "1"

DEST_PATH="$TODOTXT"
if [[ "$1" =~ ^[a-z]+:$ ]]
then
	if [[ "$1" == "done:" ]]
	then
		log_error "new tasks cannot be added to done.txt"
		return 1
	else
		DEST_PATH=$(get_data_path "$1")
		shift
	fi
fi

TASK_CONTENT="$*"
DATE_CREATED=$(date +%F)
NEW_TASK="[${DATE_CREATED}] ${TASK_CONTENT}"

printf "%s\n" "$NEW_TASK" >> "$DEST_PATH"
assert_task_exists "$DEST_PATH" "$NEW_TASK"
