#!/bin/bash

ls-deleted() {
  local pkgroot; pkgroot=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

  DOC="Show deleted files that are still on disk because of open file handles
Usage:
  ls-deleted"
# docopt parser below, refresh this parser with `docopt.sh ls-deleted.sh`
# shellcheck disable=2016,1090,1091,2034
docopt() { source "$pkgroot/.upkg/andsens/docopt.sh/docopt-lib.sh" '1.0.0' || {
ret=$?; printf -- "exit %d\n" "$ret"; exit "$ret"; }; set -e
trimmed_doc=${DOC:0:90}; usage=${DOC:71:19}; digest=c5f8b; shorts=(); longs=()
argcounts=(); node_0(){ required ; }; node_1(){ required 0; }
cat <<<' docopt_exit() { [[ -n $1 ]] && printf "%s\n" "$1" >&2
printf "%s\n" "${DOC:71:19}" >&2; exit 1; }'; unset ; parse 1 "$@"; return 0
local prefix=${DOCOPT_PREFIX:-''}; unset ; local docopt_i=1
[[ $BASH_VERSION =~ ^4.3 ]] && docopt_i=2; for ((;docopt_i>0;docopt_i--)); do
declare -p ; done; }
# docopt parser above, complete command for generating this parser is `docopt.sh --library='"$pkgroot/.upkg/andsens/docopt.sh/docopt-lib.sh"' ls-deleted.sh`
  eval "$(docopt "$@")"
  lsof -nP +L1
}

ls-deleted "$@"
