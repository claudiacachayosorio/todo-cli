#!/usr/bin/env bash
# =========================================================================== #
# Description:	Task manager for the command line
# Synopsis:			./todo.sh <command> [<argument>...]
# =========================================================================== #

set -euo pipefail

readonly TODO_APP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TODO_DATA_DIR="${TODO_APP_ROOT}/data"
readonly TODO_DATA_FILE="${TODO_DATA_DIR}/todo.txt"
readonly TODO_DATA_ARCHIVE="${TODO_DATA_DIR}/done.txt"

mkdir -p "$TODO_DATA_DIR"
touch "$TODO_DATA_FILE" "$TODO_DATA_ARCHIVE"

# =========================================================================== #
# Helpers & Utilities
# =========================================================================== #

# Arguments:
# $1		STR - Error description (optional)
# $2		STR - Error location (optional)
_todo_err() {
	local err_desc="${1:-unknown error}"
	local err_loc="${2:-${FUNCNAME[1]}}"
	cat <<-EOF >&2
	[ERROR] ${err_desc}
	--> ${err_loc}
	EOF
}

# Arguments:
# $1		STR - Source file path: "$TODO_DATA_FILE", "$TODO_DATA_ARCHIVE"
# $2		INT - Line number
_todo_assert_task_exists() {
	local src="${1:-}" num="${2:-}"
	if [[ -z "$src" ]];	then _todo_err "arg missing: 1) source file path"; return 1; fi
	if [[ -z "$num" ]];	then _todo_err "arg missing: 2) line number"; return 1; fi
	if [[ -f "$src" ]];	then _todo_err "'${src##*/}' was not found in ${TODO_DATA_DIR}"; return 1; fi

	local line_count; line_count="$(wc -l < "$src")"
	local err_loc="${FUNCNAME[1]} => ${FUNCNAME[0]}"

	if [[ ! "$num" =~ ^[0-9]+$ ]]; then
		_todo_err "line number '${num}' is not an integer" "${err_loc}"; return 1
	elif [[ $num -gt $line_count ]]; then
		_todo_err "line '${num}' was not found in ${src##*/}" "${err_loc}"; return 1
	elif [[ $num -eq 0 ]]; then
		_todo_err "line number can't be 0" "${err_loc}"; return 1;
	else return 0;
	fi
}

# Arguments:
# $1		STR - Line to append
# $2		STR - Target path: "$TODO_DATA_FILE", "$TODO_DATA_ARCHIVE"
# $3		STR - Subcommand function name: "todo_add", "todo_done", "todo_undo"
# $4		INT - Former line number (optional)
_todo_insert_task() {
	local line="${1:-}" dest="${2:-}" func="${3:-}" num="${4:-}"
	if [[ -n "$line" ]];	then _todo_err "arg missing: 1) task string"; return 1; fi
	if [[ -n "$dest" ]];	then _todo_err "arg missing: 2) dest file path"; return 1; fi
	if [[ -n "$func" ]];	then _todo_err "arg missing: 3) subcommand function"; return 1; fi
	if [[ -f "$dest" ]];	then _todo_err "'${dest##*/}' was not found in ${TODO_DATA_DIR}"; return 1; fi

	local formatted_line current_date

	if [[ "$func" == "todo_add" || "$func" == "todo_done" ]]
		current_date="$(date +%F)";
		formatted_line="${current_date} ${line}"
	elif [[ "$func" == "todo_undo" ]]; then
		formatted_line="${line#[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] }"
	else
		_todo_err "'${func}' is not a valid subcommand function"; return 1
	fi

	printf "%s\n" "$formatted_line" >> "$dest"
	if ! grep -qF "$formatted_line" "$dest"; then
		_todo_err "failed to insert task${num:+" $num"} into ${dest##*/}"; return 1
	fi
}

# Arguments:
# $1		STR - Source filename: "todo.txt", "done.txt"
# $2		STR - Target filename: "todo.txt", "done.txt" (optional)
# $...	INT - Line numbers
_todo_move_lines() {
	local src_name="${1:-}" src="${TODO_DATA_DIR}/${src_name}" arg_min="2"; shift
	if [[ -z "$src" ]];		then _todo_err "arg missing: 1) source filename"; return 1; fi
	if [[ ! -f "$src" ]];	then _todo_err "'${src_name}' was not found in ${TODO_DATA_DIR}"; return 1; fi

	local dest_name="" dest=""
	if [[ "${1:-}" =~ \.txt$ ]]; then
		dest_name="$1"; dest="${TODO_DATA_DIR}/${dest_name}"; arg_min="3"; shift
		if [[ "$src" == "$dest" ]];	then _todo_err "'${dest_name}' can't both be source and dest"; return 1; fi
	fi

	if [[ $# -gt 0 ]]; then _todo_err "arg missing: ${arg_min}) line number"; return 1; fi

	local line num; for num in "$@"; do
		_todo_assert_task_exists "$src" "$num"
		line="$(sed -n "${num}p" "$srch")"

		if [[ -n "$dest" ]]; then
			_todo_insert_line "$line" "$dest" "${FUNCNAME[1]}" "$num"
		fi

		sed -i "${num}d" "$src"
		if grep -qF "$line" "$src"; then
			_todo_err "failed to remove task ${num} from ${src_name}"; return 1
		fi
	done
}

# =========================================================================== #
# Main execution
# =========================================================================== #

# Synopsis: bash todo.sh help
todo_help() {
	cat <<- EOF
	USAGE
	./todo.sh <command> [<argument>...]

	COMMANDS
	add   <task>
	del   <file-stem> <line-number>...
	done  <line-number>...
	undo  <line-number>...
	EOF
	exit 0
}

# Synopsis: ./todo.sh add <task>
todo_add() {
	if [[ $# -eq 0 ]]; then _todo_err "missing arguments"; return 1; fi
	local task; task="$(awk '$1=$1' <<< "$*")"
	_todo_insert_line "$task" "$TODO_DATA_FILE" "${FUNCNAME[0]}"
}

# Synopsis: ./todo.sh del <file-stem> <line-number>...
todo_del() {
	if [[ $# -lt 2 ]]; then _todo_err "missing arguments"; return 1; fi
	local src_name="${1}.txt"; shift
	_todo_move_lines "$src_name" "$@"
}

# Synopsis: ./todo.sh done <line-number>...
todo_done() {
	if [[ $# -eq 0 ]]; then _todo_err "missing arguments"; return 1; fi
	_todo_move_lines "todo.txt" "done.txt" "$@"
}

# Synopsis: ./todo.sh undo <line-number>...
todo_undo() {
	if [[ $# -eq 0 ]]; then _todo_err "missing arguments"; return 1; fi
	_todo_move_lines "done.txt" "todo.txt" "$@"
}

main() {
	if [[ $# -eq 0 ]]; then todo_help; return 1; fi

	local cmd="$1"; shift
	case "$cmd" in
		add)	todo_add	"$@" ;;
		del)	todo_del	"$@" ;;
		done)	todo_done	"$@" ;;
		undo)	todo_undo	"$@" ;;
		help)	todo_help	"$@" ;;
		*)		_todo_err "${cmd} is not a valid command"; return 1 ;;
	esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
