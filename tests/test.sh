#!/bin/bash

# ===================================================================================== #
# Description:	Makes basic tests as needed.
# Synopsis:		bash todo.sh test
# ===================================================================================== #


ALT_DATE_FORMAT="DD/MM/YY"

ONELINE_SPACED_STR="   31 2014-03-20    bake brownies @baking   "
MULTILINE_SPACED_STR="   33 2020-12-30 pick up dry cleaner
		34    2021-01-02    find playlists +wedding

35  2021-01-02  buy sunscreen @shopping    "

ONELINE_CLEAN_STR="43 2023-03-05 find new coat @shopping"
MULTILINE_CLEAN_STR="44 2023-03-05 pack lunch
45 2023-03-06 research hosting service +todoapp
46 2023-03-08 find lemon bars recipe @baking"


test_clean_spaces() {
	local oneline="$1"
	local multiline="$2"
	echo -e "\nclean_spaces"
	clean_spaces "$oneline"
	clean_spaces "$multiline"
}

test_format_date() {
	local format="$1"
	local oneline="$2"
	local multiline="$3"
	echo -e "\nformat_date: ${format}"
	format_date "$oneline" "$DEFAULT_DATE_REGEX" "$format"
	format_date "$multiline" "$DEFAULT_DATE_REGEX" "$format"
}


# EXECUTION FLOW ====================================================================== #

test_clean_spaces "$ONELINE_SPACED_STR" "$MULTILINE_SPACED_STR"
test_format_date "$ALT_DATE_FORMAT_DDMMYY" "$ONELINE_CLEAN_STR" "$MULTILINE_CLEAN_STR"
