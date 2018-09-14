#!/bin/bash

# Use brew coreutils `greadlink` on OSX.
READLINK=readlink
if [ "$(uname)" = "Darwin" ]; then READLINK=greadlink; fi
DIR_SCRIPT=$(dirname "$($READLINK -e "$0")")

# shellcheck disable=SC1090
. "$DIR_SCRIPT/../../utils.sh"
try failing_command
[ "$ERRORS" -eq 1 ] || error "Unexpected number of errors reported."
# shellcheck disable=SC1090
. "$DIR_SCRIPT/../../utils.sh"
[ "$ERRORS" -eq 1 ] || error "Unexpected number of errors reported."
