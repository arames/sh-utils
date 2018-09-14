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
# shellcheck disable=SC1090
. "$DIR_SH_UTILS/utils.sh"

set -o nounset

# shellcheck disable=SC2039
find . -name "*.sh" -print0 |
	while IFS= read -r -d '' script; do
		safe shellcheck --shell=sh "$script"
	done
