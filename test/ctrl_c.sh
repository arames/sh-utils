#!/bin/bash

# To test, run the script and press Ctrl-C while it sleeps.

# shellcheck source=/dev/null
. "../utils.sh"

try ls blargh

for i in $(seq 1 5); do
    sleep 1
    echo "$i"
done

status_and_exit
