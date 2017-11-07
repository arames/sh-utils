#!/bin/bash
source "../utils.sh"

try ls blargh

for i in `seq 1 2`; do
    sleep 1
    echo $i
done

status_and_exit
