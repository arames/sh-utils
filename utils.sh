#!/bin/bash

case $- in
  *i*) SH_UTILS_INTERACTIVE="true";;
  *) SH_UTILS_INTERACTIVE="false";;
esac

COLOUR_GREEN=${COLOUR_GREEN:-"\\033[0;32m"}
COLOUR_BLUE=${COLOUR_BLUE:-"\\033[0;94m"}
COLOUR_ORANGE=${COLOUR_ORANGE:-"\\033[0;33m"}
COLOUR_RED=${COLOUR_RED:-"\\033[0;31m"}
COLOUR_NONE=${COLOUR_NONE:-"\\033[0;0m"}

ERRORS=${ERRORS:-0}
FAILED_TRIED_COMMANDS_COUNT=${FAILED_TRIED_COMMANDS_COUNT:-0}
FAILED_TRIED_COMMANDS_LIST=${FAILED_TRIED_COMMANDS_LIST:-""}
DRY_RUN=${DRY_RUN:-"false"}

print_note() {
	# shellcheck disable=SC2039
	echo -e "${COLOUR_BLUE}NOTE: ${*}${COLOUR_NONE}" >&2
}

note() {
	print_note "$@"
}

print_warning() {
	# shellcheck disable=SC2039
	echo -e "${COLOUR_ORANGE}WARNING: ${*}${COLOUR_NONE}" >&2
}

warning() {
	print_warning "$@"
}

print_error() {
	# shellcheck disable=SC2039
	echo -e "${COLOUR_RED}ERROR: ${*}${COLOUR_NONE}" >&2
}

error() {
	ERRORS=$((ERRORS+1))
	print_error "$@"
	if [ "$SH_UTILS_INTERACTIVE" = "true" ]; then
		return 1;
	else
		exit 1
	fi
}

cmd() {
	# shellcheck disable=SC2039
	echo -e "${COLOUR_GREEN}${*}${COLOUR_NONE}"
	if [ "$DRY_RUN" = "true" ]; then return 0; fi
	# Use `eval` to handle commands passed as strings. This is useful for example
	# for `safe "echo blah > /tmp/out"`.
	eval "$@"
}

safe() {
	if [ "$ERRORS" -ne 0 ]; then return 1; fi
	# Use `eval` to handle commands passed as strings. This is useful for example
	# for `safe "echo blah > /tmp/out"`.
	"$@"
	rc=$?
	if [ "$rc" -ne 0 ]; then
		error "Failed command:\\n$*";
	fi
	return "$rc"
}

try() {
	if [ "$ERRORS" -ne 0 ]; then return 1; fi
	# Use `eval` to handle commands passed as strings. This is useful for example
	# for `safe "echo blah > /tmp/out"`.
	eval "$@"
	rc=$?
	if [ "$rc" -ne 0 ] ; then
		FAILED_TRIED_COMMANDS_COUNT=$((FAILED_TRIED_COMMANDS_COUNT+1))
		FAILED_TRIED_COMMANDS_LIST="${FAILED_TRIED_COMMANDS_LIST}\\n${COLOUR_RED}${*}${COLOUR_NONE}"
		warning "$@"
	fi
}

status_and_exit() {
	if [ $ERRORS -eq 0 ]; then
	# shellcheck disable=SC2039
		echo -e "${COLOUR_GREEN}success${COLOUR_NONE}"
	else
		# shellcheck disable=SC2039
		echo -e "${COLOUR_RED}FAILURE${COLOUR_NONE}"
	fi

	if [ $FAILED_TRIED_COMMANDS_COUNT -ne 0 ]; then
		# shellcheck disable=SC2039
		echo -e "${COLOUR_RED}Tried commands failed:${COLOUR_NONE}"
		# shellcheck disable=SC2039
		echo -e "${FAILED_TRIED_COMMANDS_LIST}"
	fi

	if [ "$SH_UTILS_INTERACTIVE" = "true" ]; then
		return $ERRORS;
	else
		exit "$ERRORS"
	fi
}


check_nargs() {
	if [ "$#" -lt 2 ] || [ 3 -lt "$#" ]; then
		error "Unexpected number of arguments $#, not in [2, 3]"
	fi
	nargs="$1"
	min="$2"
	if [ "$#" -lt 3 ]; then
		max="$min"
	else
		max="$3"
	fi
	if [ "$nargs" -lt "$min" ] || [ "$max" -lt "$nargs" ]; then
		error "Unexpected number of arguments $nargs, not in [$min, $max]"
	fi
	return 0
}


NPROC=nproc
# Use brew coreutils `gnproc` on OSX.
if [ "$(uname)" = "Darwin" ]; then export NPROC=gnproc; fi
