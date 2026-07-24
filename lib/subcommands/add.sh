#!/bin/bash

# ===================================================================================== #
# Description:		Adds tasks to txt file.
# Synopsis:			bash todo.sh add [<file-stem>:] <task [+<project-tag>...]
#					[@<context-tag>...] ...>
# ===================================================================================== #


add_tasks() {
	local dest="$1"
	local task="$2"
	printf "%s\n" "$task" >> "$dest"
}


# EXECUTION FLOW ====================================================================== #

validate_arg_count "1" "x" "$@"

DEST_STEM="todo"

if [[ "$1" =~ ^[a-z]+:$ ]]
then
	if [[ "$1" == "done:" ]]
	then
		log_error "new tasks cannot be added to done.txt"
		return 1
	else
		DEST_STEM=${1%:}
		shift
	fi
fi

TASK_CONTENT="$*"

DEST_PATH="${DATA_DIR}/${DEST_STEM}.txt"
assert_file_exists "$DEST_PATH"

DATE_CREATED=$(date +%F)
NEW_TASK="[${DATE_CREATED}] ${TASK_CONTENT}"

add_tasks "$DEST_PATH" "$NEW_TASK"
assert_task_exists "$DEST_PATH" "$NEW_TASK"
