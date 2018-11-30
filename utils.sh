#!/bin/bash

case $- in
  *i*) SH_UTILS_INTERACTIVE="true";;
  *) SH_UTILS_INTERACTIVE="false";;
esac

SH_UTILS_COLOUR_RED="\\e[0;31m"
SH_UTILS_COLOUR_GREEN="\\e[0;32m"
SH_UTILS_COLOUR_YELLOW="\\e[0;33m"
SH_UTILS_COLOUR_BLUE="\\e[0;34m"
SH_UTILS_COLOUR_NONE="\\e[0;30m"

SH_UTILS_ERRORS=${SH_UTILS_ERRORS:-0}
SH_UTILS_FAILED_TRIED_COMMANDS_COUNT=${SH_UTILS_FAILED_TRIED_COMMANDS_COUNT:-0}
SH_UTILS_FAILED_TRIED_COMMANDS_LIST=${SH_UTILS_FAILED_TRIED_COMMANDS_LIST:-""}
SH_UTILS_DRY_RUN=${SH_UTILS_DRY_RUN:-"false"}

print_note() {
	printf "%bNOTE: %s%b\\n" "${SH_UTILS_COLOUR_BLUE}" "${*}" "${SH_UTILS_COLOUR_NONE}" >&2
}

note() {
	print_note "$@"
}

print_warning() {
	printf "%bWARNING: %s%b\\n" "${SH_UTILS_COLOUR_YELLOW}" "${*}" "${SH_UTILS_COLOUR_NONE}" >&2
}

warning() {
	print_warning "$@"
}

print_error() {
	printf "%bERROR: %s%b\\n" "${SH_UTILS_COLOUR_RED}" "${*}" "${SH_UTILS_COLOUR_NONE}" >&2
}

error() {
	SH_UTILS_ERRORS=$((SH_UTILS_ERRORS+1))
	print_error "$@"
	if [ "$SH_UTILS_INTERACTIVE" = "true" ]; then
		return 1;
	else
		exit 1
	fi
}

cmd() {
	printf "%s\\n" "${SH_UTILS_COLOUR_GREEN}${*}${SH_UTILS_COLOUR_NONE}"
	if [ "$SH_UTILS_DRY_RUN" = "true" ]; then return 0; fi
	# Use `eval` to handle commands passed as strings. This is useful for example
	# for `safe "echo blah > /tmp/out"`.
	eval "$@"
}

safe() {
	if [ "$SH_UTILS_ERRORS" -ne 0 ]; then return 1; fi
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
	if [ "$SH_UTILS_ERRORS" -ne 0 ]; then return 1; fi
	# Use `eval` to handle commands passed as strings. This is useful for example
	# for `safe "echo blah > /tmp/out"`.
	eval "$@"
	rc=$?
	if [ "$rc" -ne 0 ] ; then
		SH_UTILS_FAILED_TRIED_COMMANDS_COUNT=$((SH_UTILS_FAILED_TRIED_COMMANDS_COUNT+1))
		SH_UTILS_FAILED_TRIED_COMMANDS_LIST="${SH_UTILS_FAILED_TRIED_COMMANDS_LIST}\\n${SH_UTILS_COLOUR_RED}${*}${SH_UTILS_COLOUR_NONE}"
		warning "$@"
	fi
}

status_and_exit() {
	if [ $SH_UTILS_ERRORS -eq 0 ]; then
		printf "%s\\n" "${SH_UTILS_COLOUR_GREEN}success${SH_UTILS_COLOUR_NONE}"
	else
		printf "%s\\n" "${SH_UTILS_COLOUR_RED}FAILURE${SH_UTILS_COLOUR_NONE}"
	fi

	if [ $SH_UTILS_FAILED_TRIED_COMMANDS_COUNT -ne 0 ]; then
		printf "%s\\n" "${SH_UTILS_COLOUR_RED}Tried commands failed:${SH_UTILS_COLOUR_NONE}"
		printf "%s\\n" "${SH_UTILS_FAILED_TRIED_COMMANDS_LIST}"
	fi

	if [ "$SH_UTILS_INTERACTIVE" = "true" ]; then
		return $SH_UTILS_ERRORS;
	else
		exit "$SH_UTILS_ERRORS"
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
