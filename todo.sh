#!/bin/bash

# ===================================================================================== #
# Description:		Parses commands to manage task lists.
# Synopsis:			bash todo.sh <command> [<args>]
# ===================================================================================== #


# Settings ============================================================================ #

set -euo pipefail


# Global variables ==================================================================== #

declare -grx APP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -grx LIB_DIR="${APP_ROOT}/lib"
declare -grx SUB_DIR="${LIB_DIR}/subcommands"
declare -grx DATA_DIR="${APP_ROOT}/txt"

readonly UTILS="${LIB_DIR}/utils.sh"


# Sourcing ============================================================================ #

if [[ -f "$UTILS" ]]
then
	source "$UTILS"
else
	echo "error: utils.sh not found"
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
		log_user_error "'${subcommand}': command not found"
		return 1
	fi
}

case $1 in
	"")		exec_subcommand "help" ;;
	*)		exec_subcommand "$@" ;;
esac
