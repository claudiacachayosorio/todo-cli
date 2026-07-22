#!/bin/bash

# ===================================================================================== #
# Description:		Displays usage manual.
# Synopsis:			bash todo.sh help
# ===================================================================================== #


# Settings
# ===================================================================================== #

set -euo pipefail


# Functions
# ===================================================================================== #

usage() {
	cat << EOF

USAGE
bin/todo <command> [<args>]

COMMANDS
add [+<list-name>] <task>
list [<list-name>] [<list-length>]
done <task-number> ...
undo <task-number> ...
delete [<list-name>] <task-number> ...
edit <task-number> <new-name>

EOF
	return 0
}


# Point of entry
# ===================================================================================== #

usage
