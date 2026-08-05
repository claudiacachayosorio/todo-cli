#!/usr/bin/env bash
# =========================================================================== #
# Description:	Task manager for the command line
# Synopsis:			./todo.sh <command> [<argument>...]
# =========================================================================== #
set -euo pipefail
set -o errtrace

readonly DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/todo-cli"
readonly TODO_FILE="${DATA_DIR}/todo.txt"
readonly DONE_FILE="${DATA_DIR}/done.txt"

# Arguments:
# $1	INT - Line number
# $1	STR - Error description (optional)
# $2	STR - Context information (optional)
die() {
	local line_number="${1:-?}" description="${2:-unknown error}" context="${3:-}"
	printf "[ERROR] %s\n" "$description" >&2
	printf "--> %s, line %d\n" "${FUNCNAME[1]}" "$line_number" >&2
	if [[ -n "$3" ]]; then printf "--> %s\n" "$context" >&2; fi
	exit 1
}

trap 'die "$LINENO" "failed command" "$BASH_COMMAND"' ERR

# =========================================================================== #
# Helpers & Utilities
# =========================================================================== #

# Arguments:
# $1	STR - Source file path: "$TODO_FILE", "$DONE_FILE"
# $2	INT - Line number
assert_task_exists() {
	local src="${1:-}" num="${2:-}"
	if [[ -z "$src" ]]; then die "$LINENO" "arg missing: 1) source file path"; fi
	if [[ -z "$num" ]]; then die "$LINENO" "arg missing: 2) line number"; fi
	if [[ ! -f "$src" ]]; then die "$LINENO" "'${src##*/}' was not found in ${DATA_DIR}"; fi

	local line_count; line_count="$(wc -l < "$src")"
	local err_loc="Parent function: ${FUNCNAME[1]}"

	if [[ ! "$num" =~ ^[0-9]+$ ]]; then
		die "$LINENO" "line number '${num}' is not an integer" "${err_loc}"
	elif [[ $num -gt $line_count ]]; then
		die "$LINENO" "line '${num}' was not found in ${src##*/}" "${err_loc}"
	elif [[ $num -eq 0 ]]; then
		die "$LINENO" "line number can't be 0" "${err_loc}"
	else return 0; fi
}

# Arguments:
# $1	STR - Line to append
# $2	STR - Target path: "$TODO_FILE", "$DONE_FILE"
# $3	STR - Subcommand function name: "todo_add", "todo_done", "todo_undo"
# $4	INT - Former line number (optional)
insert_task() {
	local line="${1:-}" dest="${2:-}" func="${3:-}" num="${4:-}"
	if [[ -z "$line" ]]; then die "$LINENO" "arg missing: 1) task string"; fi
	if [[ -z "$dest" ]]; then die "$LINENO" "arg missing: 2) dest file path"; fi
	if [[ -z "$func" ]]; then die "$LINENO" "arg missing: 3) subcommand function"; fi
	if [[ ! -f "$dest" ]]; then die "$LINENO" "'${dest##*/}' was not found in ${DATA_DIR}"; fi

	local formatted_line current_date
	if [[ "$func" == "todo_add" || "$func" == "todo_done" ]]
		current_date="$(date +%F)";
		formatted_line="${current_date} ${line}"
	elif [[ "$func" == "todo_undo" ]]; then
		formatted_line="${line#[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] }"
	else
		die "$LINENO" "'${func}' is not a valid subcommand function"
	fi

	printf "%s\n" "$formatted_line" >> "$dest"
	if ! grep -qF "$formatted_line" "$dest"; then
		die "$LINENO" "failed to insert task${num:+" $num"} into ${dest##*/}"
	fi
}

# Arguments:
# $1	STR - Source filename: "todo.txt", "done.txt"
# $2	STR - Target filename: "todo.txt", "done.txt" (optional)
# ...	INT - Line numbers
move_lines() {
	local src_name="${1:-}" src="${DATA_DIR}/${src_name}" arg_min="2"; shift
	if [[ -z "$src" ]]; then die "$LINENO" "arg missing: 1) source filename"; fi
	if [[ ! -f "$src" ]];	then
		die "$LINENO" "'${src_name}' was not found in ${DATA_DIR}";
	fi

	local dest_name="" dest=""
	if [[ "${1:-}" =~ \.txt$ ]]; then
		dest_name="$1"; dest="${DATA_DIR}/${dest_name}"; arg_min="3"; shift
		if [[ "$src" == "$dest" ]];	then
			die "$LINENO" "'${dest_name}' can't both be source and dest file"
		fi
	fi

	if [[ $# -gt 0 ]]; then die "arg missing: ${arg_min}) line number"; fi

	local line num; for num in "$@"; do
		assert_task_exists "$src" "$num"
		line="$(sed -n "${num}p" "$srch")"

		if [[ -n "$dest" ]]; then
			_todo_insert_line "$line" "$dest" "${FUNCNAME[1]}" "$num"
		fi

		sed -i "${num}d" "$src"
		if grep -qF "$line" "$src"; then
			die "$LINENO" "failed to remove task ${num} from ${src_name}"
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
	if [[ $# -eq 0 ]]; then die "$LINENO" "missing arguments"; fi
	local task; task="$(awk '$1=$1' <<< "$*")"
	_todo_insert_line "$task" "$TODO_FILE" "${FUNCNAME[0]}"
}

# Synopsis: ./todo.sh del <file-stem> <line-number>...
todo_del() {
	if [[ $# -lt 2 ]]; then die "$LINENO" "missing arguments"; fi
	local src_name="${1}.txt"; shift
	move_lines "$src_name" "$@"
}

# Synopsis: ./todo.sh done <line-number>...
todo_done() {
	if [[ $# -eq 0 ]]; then die "$LINENO" "missing arguments"; fi
	move_lines "todo.txt" "done.txt" "$@"
}

# Synopsis: ./todo.sh undo <line-number>...
todo_undo() {
	if [[ $# -eq 0 ]]; then die "$LINENO" "missing arguments"; fi
	move_lines "done.txt" "todo.txt" "$@"
}

main() {
	if [[ $# -eq 0 ]]; then todo_help; fi

	mkdir -p "$DATA_DIR"
	touch "$TODO_FILE" "$DONE_FILE"

	local cmd="$1"; shift
	case "$cmd" in
		add)	todo_add	"$@" ;;
		del)	todo_del	"$@" ;;
		done)	todo_done	"$@" ;;
		undo)	todo_undo	"$@" ;;
		help)	todo_help	"$@" ;;
		*)		die "$LINENO" "${cmd} is not a valid command" ;;
	esac
}

main "$@"
