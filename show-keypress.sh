#!/bin/bash

show-keypress() {
  local pkgroot; pkgroot=$(upkg root "${BASH_SOURCE[0]}")

  DOC="Show the actual escape sequence a terminal sends to the tty
Usage:
  show-keypress"
# docopt parser below, refresh this parser with `docopt.sh show-keypress.sh`
# shellcheck disable=2016,1090,1091,2034
docopt() { source "$pkgroot/.upkg/andsens/docopt.sh/docopt-lib.sh" '1.0.0' || {
ret=$?; printf -- "exit %d\n" "$ret"; exit "$ret"; }; set -e
trimmed_doc=${DOC:0:82}; usage=${DOC:60:22}; digest=848df; shorts=(); longs=()
argcounts=(); node_0(){ required ; }; node_1(){ required 0; }
cat <<<' docopt_exit() { [[ -n $1 ]] && printf "%s\n" "$1" >&2
printf "%s\n" "${DOC:60:22}" >&2; exit 1; }'; unset ; parse 1 "$@"; return 0
local prefix=${DOCOPT_PREFIX:-''}; unset ; local docopt_i=1
[[ $BASH_VERSION =~ ^4.3 ]] && docopt_i=2; for ((;docopt_i>0;docopt_i--)); do
declare -p ; done; }
# docopt parser above, complete command for generating this parser is `docopt.sh --library='"$pkgroot/.upkg/andsens/docopt.sh/docopt-lib.sh"' show-keypress.sh`
  eval "$(docopt "$@")"
  stty raw min 1 time 20 -echo
  dd count=1 2> /dev/null | od -vAn -tx1
  stty sane
}

show-keypress "$@"
