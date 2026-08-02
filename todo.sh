#!/bin/bash

# =========================================================================== #
# Description:	todo-cli's main script.
# Command:		bash todo.sh
# =========================================================================== #

set -euo pipefail
shopt -s extglob

readonly TODO_APP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

readonly TODO_CONFIG="${TODO_APP_ROOT}/todo.conf"
if [[ -f "$TODO_CONFIG" ]]; then
	source "$TODO_CONFIG"
fi

readonly TODO_LIB_DIR="${TODO_APP_ROOT}/lib"
source "${TODO_LIB_DIR}/vars.sh"
source "${TODO_LIB_DIR}/utils.sh"
source "${TODO_LIB_DIR}/app.sh"

readonly TODO_DATA_DIR="${TODO_APP_ROOT}/data"
readonly TODO_ACTIVE_DATA="${TODO_DATA_DIR}/todo.txt"
readonly TODO_ARCHIVE_DATA="${TODO_DATA_DIR}/done.txt"
mkdir -p "$TODO_DATA_DIR"
touch "$TODO_ACTIVE_DATA"
touch "$TODO_ARCHIVE_DATA"

main() {
	if [[ $# -eq 0 ]]; then
		todo_help
	fi

	local -r command="$1"
	shift

	case "$command" in
		add)	todo_add "$@" ;;
		del)	todo_del "$@" ;;
		done)	todo_done "$@" ;;
		undo)	todo_undo "$@" ;;
		list)	todo_list "$@" ;;
		help)	todo_help "$@" ;;
		*)
			log_error "'${command}': Invalid command."
			return 1 ;;
	esac
}

main "$@"
