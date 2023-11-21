#!/bin/bash

randpass() {
  local pkgroot; pkgroot=$(upkg root "${BASH_SOURCE[0]}")

  DOC="Generate a random password
Usage:
  randpass [options]

Options:
  -l --length=N  Length of the password [default: 6]"
# docopt parser below, refresh this parser with `docopt.sh randpass.sh`
# shellcheck disable=2016,1090,1091,2034
docopt() { source "$pkgroot/.upkg/andsens/docopt.sh/docopt-lib.sh" '1.0.0' || {
ret=$?; printf -- "exit %d\n" "$ret"; exit "$ret"; }; set -e
trimmed_doc=${DOC:0:117}; usage=${DOC:27:27}; digest=f28ee; shorts=(-l)
longs=(--length); argcounts=(1); node_0(){ value __length 0; }; node_1(){
optional 0; }; node_2(){ optional 1; }; node_3(){ required 2; }; node_4(){
required 3; }; cat <<<' docopt_exit() { [[ -n $1 ]] && printf "%s\n" "$1" >&2
printf "%s\n" "${DOC:27:27}" >&2; exit 1; }'; unset var___length; parse 4 "$@"
local prefix=${DOCOPT_PREFIX:-''}; unset "${prefix}__length"
eval "${prefix}"'__length=${var___length:-6}'; local docopt_i=1
[[ $BASH_VERSION =~ ^4.3 ]] && docopt_i=2; for ((;docopt_i>0;docopt_i--)); do
declare -p "${prefix}__length"; done; }
# docopt parser above, complete command for generating this parser is `docopt.sh --library='"$pkgroot/.upkg/andsens/docopt.sh/docopt-lib.sh"' randpass.sh`
  eval "$(docopt "$@")"
  printf "%s\n" "$(LC_ALL=C tr -dc A-Za-z0-9 < /dev/urandom | head -c$__length)"
}

randpass "$@"
