#!/bin/bash

# shellcheck disable=SC1091
. "../utils.sh"

safe cmd rm -rf /tmp/test-sh-utils/interactive
safe cmd mkdir -p /tmp/test-sh-utils/interactive/existing_dir
safe cmd ls /tmp/test-sh-utils/interactive/existing_dir
safe cmd ls /tmp/test-sh-utils/interactive/missing_dir/seeing_an_error_here_is_fine
safe cmd ls /tmp/test-sh-utils/interactive/other_missing_dir/seeing_an_error_here_is_NOT_fine
echo $?

status_and_exit
