#!/bin/bash

BASH_UTILS_INTERACTIVE="false"
if [[ $- == *i* ]]; then
	BASH_UTILS_INTERACTIVE="true"
fi
BASH_UTILS_SAFE_COMMAND_FAILED="false"

COLOUR_RED=${COLOUR_RED:-"\033[0;31m"}
COLOUR_GREEN=${COLOUR_GREEN:-"\033[0;32m"}
COLOUR_NONE=${COLOUR_NONE:-"\033[0;0m"}

ERRORS=${ERRORS:-0}
FAILED_TRIED_COMMANDS=${FAILED_TRIED_COMMANDS:-""}
DRY_RUN=${DRY_RUN:-"false"}

print_error() {
	echo -e "${COLOUR_RED}ERROR: ${*}${COLOUR_NONE}" >&2
}

error() {
	print_error "$@"
	if [[ "$BASH_UTILS_INTERACTIVE" == "true" ]]; then return; fi
	exit 1
}

safe() {
	if [[ "$BASH_UTILS_INTERACTIVE" == "true" ]] && [[ "$BASH_UTILS_SAFE_COMMAND_FAILED" == "true" ]]; then return; fi
	echo -e "${COLOUR_GREEN}${*}${COLOUR_NONE}"
	if [[ "$DRY_RUN" == "true" ]]; then return; fi
	# Use `eval` to handle commands passed as strings. This is useful for example
	# for `safe "echo blah > /tmp/out"`.
	if eval "$@" ; then
		:
	else
		BASH_UTILS_SAFE_COMMAND_FAILED="true"
		ERRORS=$((ERRORS+1))
		FAILED_TRIED_COMMANDS="${FAILED_TRIED_COMMANDS}\n${COLOUR_RED}${*}${COLOUR_NONE}"
		error "Failed command:\n$*";
	fi
}

try() {
	if [[ "$BASH_UTILS_INTERACTIVE" == "true" ]] && [[ "$BASH_UTILS_SAFE_COMMAND_FAILED" == "true" ]]; then return; fi
	echo -e "${COLOUR_GREEN}${*}${COLOUR_NONE}"
	if [[ "$DRY_RUN" == "true" ]]; then return; fi
	# Use `eval` to handle commands passed as strings. This is useful for example
	# for `safe "echo blah > /tmp/out"`.
	if eval "$@" ; then
		:
	else
		ERRORS=$((ERRORS+1))
		FAILED_TRIED_COMMANDS="${FAILED_TRIED_COMMANDS}\n${COLOUR_RED}${*}${COLOUR_NONE}"
		print_error "$@"
	fi
}

status_and_exit() {
	if [[ $ERRORS -eq 0 ]]; then
		echo -e "${COLOUR_GREEN}success${COLOUR_NONE}"
	else
		echo -e "${COLOUR_RED}FAILURE${COLOUR_NONE}"
		echo -e "${COLOUR_RED}Commands failed:${COLOUR_NONE}"
		echo -e "${FAILED_TRIED_COMMANDS}"
	fi
	if [[ "$BASH_UTILS_INTERACTIVE" == "true" ]]; then return $ERRORS; fi
	exit "$ERRORS"
}


NPROC=nproc
# Use brew coreutils `gnproc` on OSX.
if [[ $(uname) == 'Darwin' ]]; then export NPROC=gnproc; fi
