#!/usr/bin/env bats
# =========================================================================== #
# Description:	Unit tests for todo-cli's constant variables.
# Command:			bats test/vars.bats
# =========================================================================== #
load "test_helper"

TEST_TODO_VARS_FILE="${TEST_TODO_APP_ROOT}/lib/vars.sh"
TEST_TODO_CONFIG_VARS=(
	"TODO_VERBOSE"
	"TODO_DISPLAY_DATE"
	"TODO_DATE_FORMAT"
)

setup() {
	local var; for var in "${TEST_TODO_CONFIG_VARS[@]}"; do
		unset "$var"
	done
}

test_todo_assert_default_config_vars() {
	assert_equal "$TODO_VERBOSE"			"true"
	assert_equal "$TODO_DISPLAY_DATE"	"false"
	assert_equal "$TODO_DATE_FORMAT"	"YYYY-MM-DD"
}

@test "config variables default to fallbacks when unset" {
	source "$TEST_TODO_VARS_FILE"
	test_todo_assert_default_config_vars
}

@test "config variables default to fallbacks when empty" {
	local var; for var in "${TEST_TODO_CONFIG_VARS[@]}"; do
		declare -gx "$var"=""
	done

	source "$TEST_TODO_VARS_FILE"
	test_todo_assert_default_config_vars
}

@test "config variables accept valid overrides" {
	export TODO_VERBOSE="false"
	export TODO_DISPLAY_DATE="true"
	export TODO_DATE_FORMAT="DD/MM/YY"

	source "$TEST_TODO_VARS_FILE"
	assert_equal "$TODO_VERBOSE"			"false"
	assert_equal "$TODO_DISPLAY_DATE"	"true"
	assert_equal "$TODO_DATE_FORMAT"	"DD/MM/YY"
}
