#!/usr/bin/env bash
# =========================================================================== #
# Description: Portable task manager for the command line.
# Command:     ./todo.sh

# ERROR HANDLERS ============================================================ #

set -euo pipefail
set -o errtrace

die() {
	local code="${1:-1}"
	local desc="${2:-An unknown error has occurred.}"
	printf "ERROR: %s\n" "$desc" >&2
	exit "$code"
}

trap 'die 1 "Command failed unexpectedly."' ERR

# GLOBALS =================================================================== #

readonly VERSION="0.1.0"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DATA_DIR="${DATA_DIR:-$SCRIPT_DIR}"
readonly TODO_FILE="${DATA_DIR}/todo.txt"

declare -gA LABELS
LABELS[add]="[+] Added"
LABELS[del]="[-] Deleted"
LABELS[do]="[x] Done"
LABELS[undo]="[ ] Undone"
readonly LABELS
readonly DONE_REGEX="^x "

LINE_COUNT=0
INDEX_WIDTH=1

# HELPERS =================================================================== #

init_storage() {
	[[ -d "$DATA_DIR" ]] || die 1 "No directory found at ${DATA_DIR}."
	touch "$TODO_FILE"   || die 1 "Cannot create todo.txt inside ${DATA_DIR}."
	readonly LINE_COUNT="$(wc -l < "$TODO_FILE")"
	local potential_count; potential_count="$(( LINE_COUNT + 1 ))"
	readonly INDEX_WIDTH="${#potential_count}"
}

is_arg_missing() {
	local arg_count="$1"
	local error_desc="${2:-Argument required.}"
	if [[ "$arg_count" -eq 0 ]]; then
		die 2 "$error_desc"
	else return 0; fi
}

is_todo_empty() {
	if ! grep -q '[^[:space:]]' "$TODO_FILE"; then
		[[ -s "$TODO_FILE" ]] && > "$TODO_FILE"
		printf "Your todo.txt is empty!\n"
		exit 0
	else :;	fi
}

print_summary() {
	local todo done total
	total="$(grep -c '[^[:space:]]' "$TODO_FILE")" || true
	done="$(grep -c "^x " "$TODO_FILE")"           || true
	todo="$(( total - done ))"
	printf "%d todo | %d done | %d total\n" "$todo" "$done" "$total"
	is_todo_empty
}

print_task_success() {
	local index="$1"
	local task_output="$2"
	local subcmd="${FUNCNAME[-3]#todo_}"
	printf "%s line %*d: \"%s\"" \
	       "${LABELS[$subcmd]}" "$INDEX_WIDTH" "$index" "$task_output"
}

print_confirmation() {
	local tasks="$1"
	local summary; summary="$(print_summary)"
	printf "%s\n" "$tasks"
	printf "%s\n" "$summary"
}

# TODO: validate index within bounds that isn't empty line
validate_index() {
	local index="$1"
	if [[ ! "$index" =~ ^[0-9]+$ ]]; then
		printf "Skipping %s: Task index must be number.\n" "$index" >&2
		return 1
	elif [[ "$index" -eq 0 ]]; then
		printf "Skipping 0: Task index must be greater than zero.\n" >&2
		return 1
	elif [[ "$index" -gt "$LINE_COUNT" ]]; then
		printf "Skipping %d: Task does not exist.\n" "$index" >&2
		return 1
	else return 0; fi
}

# SUBCOMMANDS =============================================================== #

todo_help() {
	cat <<-EOF
	USAGE
	  ./todo.sh [<command> [<argument>...]]

	COMMANDS
	  add <task>         Add new task to todo.txt
	  do <index>...      Mark task as done
	  undo <index>...    Remove done mark from task
	  del <index>...     Delete task from todo.txt
	  status             Display task count
	  --version, -v      Display version number
	  help, --help, -h   List available commands
	EOF
	exit 0
}

todo_add() {
	local task="$*"
	local index; index="$(( LINE_COUNT + 1 ))"
	local empty_line formatted_task
	empty_line="$(grep -nm 1 '^[[:space:]]*$' "$TODO_FILE")" || true

	if [[ -n "$empty_line" ]]; then
		index="${empty_line%%:*}"
		sed -i "${index}s/.*/${task}/" "$TODO_FILE"
	else
		printf "%s\n" "$task" >> "$TODO_FILE"
	fi

	formatted_task="$(print_task_success "$index" "$task")"
	print_confirmation "$formatted_task"$'\n'
}

todo_do() {
	local i indexes=("$@")
	local sed_args=()
	local done_tasks=""
	local task formatted_task

	for i in "${indexes[@]}"; do
		if ! validate_index "$i"; then continue; fi
		task="$(sed -n "${i}p" "$TODO_FILE")"

		if [[ "$task" =~ $DONE_REGEX ]]; then
			printf "Skipping %d: Task is already marked as done.\n" "$i"; continue
		fi

		formatted_task="$(print_task_success "$i" "x ${task}")"
		done_tasks+="$formatted_task"$'\n'
		sed_args+=("-e" "${i}s/^/x /")
	done

	if [[ "${#sed_args[@]}" -gt 0 ]]; then
		sed -i "${sed_args[@]}" "$TODO_FILE"
		print_confirmation "$done_tasks"
	else exit 2; fi
}

todo_undo() {
	local i indexes=("$@")
	local sed_args=()
	local undone_tasks=""
	local task formatted_task

	for i in "${indexes[@]}"; do
		if ! validate_index "$i"; then continue; fi
		task="$(sed -n "${i}p" "$TODO_FILE")"

		if [[ ! "$task" =~ $DONE_REGEX ]]; then
			printf "Skipping %d: Task is still marked as todo.\n" "$i"; continue
		fi

		formatted_task="$(print_task_success "$i" "${task#x }")"
		undone_tasks+="$formatted_task"$'\n'
		sed_args+=("-e" "${i}s/${DONE_REGEX}//")
	done

	if [[ "${#sed_args[@]}" -gt 0 ]]; then
		sed -i "${sed_args[@]}" "$TODO_FILE"
		print_confirmation "$undone_tasks"
	else exit 2; fi
}

todo_del() {
	local i indexes=("$@")
	local sed_args=()
	local deleted_tasks=""
	local task formatted_task

	for i in "${indexes[@]}"; do
		if ! validate_index "$i"; then continue; fi
		task="$(sed -n "${i}p" "$TODO_FILE")"
		formatted_task="$(print_task_success "$i" "$task")"
		deleted_tasks+="$formatted_task"$'\n'
		sed_args+=("-e" "${i}s/.*//")
	done

	if [[ "${#sed_args[@]}" -gt 0 ]]; then
		sed -i "${sed_args[@]}" "$TODO_FILE"
		print_confirmation "$deleted_tasks"
		sed -i -e :a -e '/\S/!{$d;N;ba;}' "$TODO_FILE"
	else exit 2; fi
}

# MAIN ====================================================================== #

main() {
	init_storage
	local cmd="${1:-}"
	shift

	case "$cmd" in
		add)
			is_arg_missing "$#" "Task description cannot be empty."
			;;
		do|undo|del)
			is_arg_missing "$#" "Task index required."
			is_todo_empty
			;;
		*)
			;;
	esac

	case "$cmd" in
		""|help|--help|-h) todo_help ;;
		--init-only)       exit 0 ;;
		--version|-v)      printf "todo-cli, version %s\n" "$VERSION" ;;
		status)            print_summary ;;
		add)               todo_add "$@" ;;
		do)                todo_do "$@" ;;
		undo)              todo_undo "$@" ;;
		del)               todo_del "$@" ;;
		*)                 die 2 "'${cmd}' is not a valid command." ;;
	esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "${@:-}"
fi
