#!/usr/bin/env bash

main() {
  local pkgroot; pkgroot=$(upkg root "${BASH_SOURCE[0]}")

  DOC="Watch dependencies of a systemd target and optionally issue a command
Usage:
  target-watch TARGET
  target-watch COMMAND TARGET"
# docopt parser below, refresh this parser with `docopt.sh target-watch.sh`
# shellcheck disable=2016,1090,1091,2034
docopt() { source "$pkgroot/.upkg/andsens/docopt.sh/docopt-lib.sh" '1.0.0' || {
ret=$?; printf -- "exit %d\n" "$ret"; exit "$ret"; }; set -e
trimmed_doc=${DOC:0:128}; usage=${DOC:70:58}; digest=9decb; shorts=(); longs=()
argcounts=(); node_0(){ value TARGET a; }; node_1(){ value COMMAND a; }
node_2(){ required 0; }; node_3(){ required 1 0; }; node_4(){ either 2 3; }
node_5(){ required 4; }; cat <<<' docopt_exit() {
[[ -n $1 ]] && printf "%s\n" "$1" >&2; printf "%s\n" "${DOC:70:58}" >&2; exit 1
}'; unset var_TARGET var_COMMAND; parse 5 "$@"
local prefix=${DOCOPT_PREFIX:-''}; unset "${prefix}TARGET" "${prefix}COMMAND"
eval "${prefix}"'TARGET=${var_TARGET:-}'
eval "${prefix}"'COMMAND=${var_COMMAND:-}'; local docopt_i=1
[[ $BASH_VERSION =~ ^4.3 ]] && docopt_i=2; for ((;docopt_i>0;docopt_i--)); do
declare -p "${prefix}TARGET" "${prefix}COMMAND"; done; }
# docopt parser above, complete command for generating this parser is `docopt.sh --library='"$pkgroot/.upkg/andsens/docopt.sh/docopt-lib.sh"' target-watch.sh`
  eval "$(docopt "$@")"
  TARGET=${TARGET%'.target'}
  TARGET=${TARGET}.target

  if [[ -n $COMMAND ]] && ! sudo -n true 2>/dev/null; then
    sudo true
  fi

  local watch_pid
  watch -n.5 -c \
    SYSTEMD_COLORS=1 systemctl status "$TARGET" \| head -n1 \; \
    SYSTEMD_COLORS=1 systemctl list-dependencies "$TARGET" \| tail -n+2 \| uniq &
  watch_pid=$!
  # shellcheck disable=2064
  trap "kill $watch_pid >/dev/null 2>&1 || true" EXIT
  if [[ -n $COMMAND ]]; then
    sudo systemctl "$COMMAND" "$TARGET"
  fi
  wait $watch_pid
}

main "$@"
