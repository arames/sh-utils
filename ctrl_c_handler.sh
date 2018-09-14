#!/bin/bash

# Include this file after `utils.sh` to gracefully handle ctrl-c signals.

trap ctrl_c_handler INT

ctrl_c_handler() {
	status_and_exit
}
