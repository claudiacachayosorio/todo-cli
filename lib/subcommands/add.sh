#!/bin/bash

# ===================================================================================== #
# Description:	Adds tasks to txt file.
# Synopsis:		bash todo.sh add <task [+<project-tag>...] [@<context-tag>...] ...>
# ===================================================================================== #


# EXECUTION FLOW ====================================================================== #

validate_arg_count "$#" "min" "1"

TASK_CONTENT="$*"
DATE_CREATED="$(date +%F)"
NEW_TASK="${DATE_CREATED} ${TASK_CONTENT}"

printf "%s\n" "$NEW_TASK" >> "$TODO_ACTIVE_DATA"
assert_task_exists "$NEW_TASK" "$TODO_ACTIVE_DATA"
