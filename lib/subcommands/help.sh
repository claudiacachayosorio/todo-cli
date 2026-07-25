#!/bin/bash

# ===================================================================================== #
# Description:	Displays usage manual.
# Synopsis:		bash todo.sh help
# ===================================================================================== #

usage() {
	cat << EOF

USAGE
bash todo.sh <command> [<argument>...]

COMMANDS
add   [<filename>] <task [+<project-tag>...] [@<context-tag>...] ...>
list  [<filename>] [<search-term> [OR <search-term> ...] ...]
done  [<filename>] <line-number>...
del   [<filename>] <line-number>...
move  [from:<filename>] to:<filename> <line-number>...
undo  <line-number>...

EOF
	return 0
}

usage
