#!/bin/bash

# ===================================================================================== #
# Description:		Displays usage manual.
# Synopsis:			bash todo.sh help
# ===================================================================================== #

usage() {
	cat << EOF

USAGE
bash todo.sh <command> [<args>]

COMMANDS
add     [<list>:] <task> [+<project> ...] [@<context> ...]
list    [<list>] [<task-count>]
done    [<list>] <task-number> ...
undo    <task-number> ...
delete  [<list>] <task-number> ...

EOF
	return 0
}

usage
