#!/usr/bin/env bash

# =========================================================================== #
# Description:	Shared constants for todo-cli.
# =========================================================================== #

export PRINT_CONFIRMATION_MESSAGE="${PRINT_CONFIRMATION_MESSAGE:-true}"
export DISPLAY_DATE="${DISPLAY_DATE:-false}"
export DISPLAY_DATE_FORMAT="${DISPLAY_DATE_FORMAT:-YYYY-MM-DD}"

readonly TODO_DATE_FORMAT="YYYY-MM-DD"
readonly TODO_DATE_REGEX="[0-9]{4}-[0-9]{2}-[0-9]{2}"
readonly TODO_COL_SPACING=" "
