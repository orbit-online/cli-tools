#!/bin/bash

epoch() {
  local pkgroot; pkgroot=$(upkg root "${BASH_SOURCE[0]}")

  DOC="Convert/display unix epoch timestamp
Usage:
  epoch [UNIX_TIMESTAMP]

Will display current timestamp if no timestamp is given"
# docopt parser below, refresh this parser with `docopt.sh epoch.sh`
# shellcheck disable=2016,1090,1091,2034
docopt() { source "$pkgroot/.upkg/andsens/docopt.sh/docopt-lib.sh" '1.0.0' || {
ret=$?; printf -- "exit %d\n" "$ret"; exit "$ret"; }; set -e
trimmed_doc=${DOC:0:125}; usage=${DOC:37:31}; digest=2ac23; shorts=(); longs=()
argcounts=(); node_0(){ value UNIX_TIMESTAMP a; }; node_1(){ optional 0; }
node_2(){ required 1; }; node_3(){ required 2; }; cat <<<' docopt_exit() {
[[ -n $1 ]] && printf "%s\n" "$1" >&2; printf "%s\n" "${DOC:37:31}" >&2; exit 1
}'; unset var_UNIX_TIMESTAMP; parse 3 "$@"; local prefix=${DOCOPT_PREFIX:-''}
unset "${prefix}UNIX_TIMESTAMP"
eval "${prefix}"'UNIX_TIMESTAMP=${var_UNIX_TIMESTAMP:-}'; local docopt_i=1
[[ $BASH_VERSION =~ ^4.3 ]] && docopt_i=2; for ((;docopt_i>0;docopt_i--)); do
declare -p "${prefix}UNIX_TIMESTAMP"; done; }
# docopt parser above, complete command for generating this parser is `docopt.sh --library='"$pkgroot/.upkg/andsens/docopt.sh/docopt-lib.sh"' epoch.sh`
  eval "$(docopt "$@")"
  if [[ -z $UNIX_TIMESTAMP ]]; then
    date +%s
  else
    date -d "@$UNIX_TIMESTAMP" 2>/dev/null || date -r "$UNIX_TIMESTAMP"
  fi
}

epoch "$@"
