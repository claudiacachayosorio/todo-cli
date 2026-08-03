#!/usr/bin/env bash
# =========================================================================== #
# Description:	Shared constants for todo-cli.
# =========================================================================== #

export TODO_VERBOSE="${TODO_VERBOSE:-true}"
export TODO_DISPLAY_DATE="${TODO_DISPLAY_DATE:-false}"
export TODO_DATE_FORMAT="${TODO_DATE_FORMAT:-YYYY-MM-DD}"

readonly TODO_DATE_REGEX="[0-9]{4}-[0-9]{2}-[0-9]{2}"
readonly TODO_COL_SPACING=" "
