#!/bin/bash

# ===================================================================================== #
# Description:		Displays usage manual.
# Synopsis:			bash todo.sh help
# ===================================================================================== #

usage() {
	cat << EOF

USAGE
bash todo.sh <command> [<argument>...]

COMMANDS
add   [<file-stem>:] <task [+<project-tag>...] [@<context-tag>...] ...>
list  [<file-stem>:] [<search-term> [OR <search-term> ...] ...]
del   [<file-stem>] <line-number>...
done  [<file-stem>] <line-number>...
move  [<from-file-stem>] <line-number> <to-file-stem>
undo  <line-number>...

EOF
	return 0
}

usage
