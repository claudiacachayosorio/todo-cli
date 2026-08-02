#!/bin/bash

setup() {
	load "test_helper/bats-support/load"
	load "test_helper/bats-assert/load"

	local test_dir
	test_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
	local app_root
	app_root="$(dirname "$test_dir")"

	TEST_SANDBOX="$(mktemp -d "${TMPDIR:-/tmp}/todo_test.XXXXXX")"
	export TODO_FILE="${TEST_SANDBOX}/todo.txt"
	touch "$TODO_FILE"

	source "${app_root}/todo.sh"
}

teardown() {
	rm -rf "$TEST_SANDBOX"
}
