#!/usr/bin/env bash

main() {
  local socketpath=$1 pids
  if [[ $(id -u) -ne $(stat -c%u "$socketpath") ]]; then
    # shellcheck disable=2207
    pids=($(sudo lsof +E -taU -- "$socketpath"))
    for pid in "${pids[@]}"; do printf -- "%5d %s\n" "$pid" "$(sudo cat "/proc/$pid/cmdline" | tr -d '\0')"; done
  else
    # shellcheck disable=2207
    pid=($(lsof +E -taU -- "$socketpath"))
    # shellcheck disable=2002
    for pid in "${pids[@]}"; do printf -- "%5d %s\n" "$pid" "$(cat "/proc/$pid/cmdline" | tr -d '\0')"; done
  fi
}

main "$@"
