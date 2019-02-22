#!/bin/bash

# shellcheck source=/dev/null
. ../utils.sh

some_function() {
  echo "some_function"
  . ../init_context.sh
  . dump_context.sh
  # shellcheck disable=SC2039
  local OPTIND
  OPTIND=0
  while getopts ":hn" opt; do
    case $opt in
      h) echo "some_function: usage" ; return 0 ;;
      n) echo "some_function: dry"; SH_UTILS_DRY_RUN="true" ;;
      \?) echo "some_function: Invalid option: -$OPTARG" >&2 ; return 1 ;;
    esac
  done
  shift $((OPTIND-1))
  . dump_context.sh

  echo "some_function:" "$@"
  cmd ls bim
}

# shellcheck disable=SC2237
# shellcheck disable=SC2039
if ! [ -z "${BASH_VERSION+x}" ] && [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  main() {
    echo "main"
    while getopts ":hn" opt; do
      case $opt in
        h)
          echo "main: usage"
          return 0
          ;;
        n)
          echo "main: dry"
          # shellcheck disable=SC2034
          SH_UTILS_DRY_RUN="true"
          ;;
        \?) echo "main: Invalid option: -$OPTARG" >&2 ; return 1 ;;
      esac
    done
    shift $((OPTIND-1))

    echo "main:" "$@"

    . dump_context.sh
    safe some_function "$@"
    cmd ls bam

    return "$SH_UTILS_ERRORS"
  }

  main "$@"
fi
