#!/bin/bash

# ===================================================================================== #
# Description:	Initializes app's shared logic and variables.
# Synopsis:		bash todo.sh <subcommand> [<argument>...]
# ===================================================================================== #


set -euo pipefail
shopt -s extglob


declare -grx APP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -grx DATA_DIR="${APP_ROOT}/data"
declare -grx LIB_DIR="${APP_ROOT}/lib"
declare -grx SUB_DIR="${LIB_DIR}/subcommands"
declare -grx TODOTXT="${DATA_DIR}/todo.txt"
declare -grx DONETXT="${DATA_DIR}/done.txt"
readonly UTILS="${LIB_DIR}/utils.sh"


if [[ -f "$UTILS" ]]
then
	source "$UTILS"
else
	echo "error: utils.sh not found" >&2
	exit 1
fi


exec_subcommand() {
	local subcommand="$1"
	local script="${SUB_DIR}/${subcommand}.sh"

	if [[ -f "$script" ]]
	then
		shift
		source "$script" "$@"
	else
		log_error "'${subcommand}': command not found"
		return 1
	fi
}


if [[ $# -eq 0 ]]
then
	exec_subcommand "help"
else
	exec_subcommand "$@"
fi
