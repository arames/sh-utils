#!/bin/bash

# TODO: Unfortunately, this must be run from the root of the repo,
# due to shellcheck source annotations.

READLINK=readlink
# Use brew coreutils `greadlink` on macOS.
if [ "$(uname)" = "Darwin" ]; then READLINK=greadlink; fi

if [ -z ${DIR_SH_UTILS_TEST+x} ]; then
	if [ -n "$ZSH_VERSION" ]; then
		DIR_SH_UTILS_TEST=$(dirname "$0:A")
	elif [ -n "$BASH_VERSION" ]; then
		# shellcheck disable=SC2039
		DIR_SH_UTILS_TEST=$(dirname "$($READLINK -e "${BASH_SOURCE[0]}")")
	else
		DIR_SH_UTILS_TEST=$(dirname "$($READLINK -e "$0")")
	fi
fi

DIR_SH_UTILS="$DIR_SH_UTILS_TEST/.."
# shellcheck source=/dev/null
. "$DIR_SH_UTILS/utils.sh"

set -o nounset

# List of shellcheck warnings or errors that are allowed to be disabled.
ALLOWED_SHELLCHECK_DISABLED="!!!none!!!"

invalid_disabled_checks=$(\
	grep -RHIn -A1 "#[[:space:]]*shellcheck[[:space:]*]disable" "$DIR_SH_UTILS" \
	| grep -v "$ALLOWED_SHELLCHECK_DISABLED")
n_invalid_disabled_checks=$(echo "$invalid_disabled_checks" | wc -l)
if [ "$n_invalid_disabled_checks" -ne 0 ]; then
	warning "Invalid disabled checks:\\n$invalid_disabled_checks"
fi


# shellcheck disable=SC2039
find . -name "*.sh" -print0 |
	while IFS= read -r -d '' script; do
		safe shellcheck --shell=sh "$script"
	done
