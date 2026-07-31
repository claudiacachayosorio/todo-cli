#!/bin/bash

# ===================================================================================== #
# Description:	Initializes app's shared logic and variables.
# Synopsis:		bash todo.sh <subcommand> [<argument>...]
# ===================================================================================== #

set -euo pipefail
shopt -s extglob

declare -r TODO_APP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -r TODO_CONFIG="${TODO_APP_ROOT}/todo.cfg"

if [[ ! -f "$TODO_CONFIG" ]]; then
	echo "Error: Configuration file not found." >&2
	exit 1
fi

source "$TODO_CONFIG"

declare -r TODO_LIB_DIR="${TODO_APP_ROOT}/${LIB_DIR}"
declare -r TODO_DATA_DIR="${TODO_APP_ROOT}/${DATA_DIR}"
declare -r TODO_TEST_DIR="${TODO_APP_ROOT}/tests"
declare -r TODO_SUB_DIR="${TODO_LIB_DIR}/subcommands"

declare -r TODO_UTILS="${TODO_LIB_DIR}/utils.sh"
declare -r TODO_ACTIVE_DATA="${TODO_DATA_DIR}/${TODO_FILE}"
declare -r TODO_ARCHIVE_DATA="${TODO_DATA_DIR}/${DONE_FILE}"

if [[ ! -f "$TODO_UTILS" ]]; then
	echo "Error: Utilities file not found." >&2
	exit 1
fi

source "$TODO_UTILS"

run_script() {
	local -r stem="$1"
	local -r dir="$2"
	local -r script="${dir}/${stem}.sh"

	if [[ ! -f "$script" ]]; then
		log_error "Script not found."
		return 1
	else
		shift
		source "$script" "$@"
	fi
}

if [[ "$#" -eq 0 ]]; then
	run_script "help" "$TODO_SUB_DIR"
else
	case "$1" in
		test)	run_script "$1" "$TODO_TEST_DIR" ;;
		*)		run_script "$1" "$TODO_SUB_DIR" ;;
	esac
fi
