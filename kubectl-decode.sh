#!/usr/bin/env bash

kubectl-decode() {
  local pkgroot; pkgroot=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

  if [[ $1 != 'decode' ]]; then
    set -- "decode" "$@"
  fi
  DOC="Decode a kubernetes secret
Usage:
  kubectl decode SECRET FILENAME"
# docopt parser below, refresh this parser with `docopt.sh kubectl-decode.sh`
# shellcheck disable=2016,1090,1091,2034
docopt() { source "$pkgroot/.upkg/andsens/docopt.sh/docopt-lib.sh" '1.0.0' || {
ret=$?; printf -- "exit %d\n" "$ret"; exit "$ret"; }; set -e
trimmed_doc=${DOC:0:66}; usage=${DOC:27:39}; digest=0d101; shorts=(); longs=()
argcounts=(); node_0(){ value SECRET a; }; node_1(){ value FILENAME a; }
node_2(){ _command decode; }; node_3(){ required 2 0 1; }; node_4(){ required 3
}; cat <<<' docopt_exit() { [[ -n $1 ]] && printf "%s\n" "$1" >&2
printf "%s\n" "${DOC:27:39}" >&2; exit 1; }'; unset var_SECRET var_FILENAME \
var_decode; parse 4 "$@"; local prefix=${DOCOPT_PREFIX:-''}
unset "${prefix}SECRET" "${prefix}FILENAME" "${prefix}decode"
eval "${prefix}"'SECRET=${var_SECRET:-}'
eval "${prefix}"'FILENAME=${var_FILENAME:-}'
eval "${prefix}"'decode=${var_decode:-false}'; local docopt_i=1
[[ $BASH_VERSION =~ ^4.3 ]] && docopt_i=2; for ((;docopt_i>0;docopt_i--)); do
declare -p "${prefix}SECRET" "${prefix}FILENAME" "${prefix}decode"; done; }
# docopt parser above, complete command for generating this parser is `docopt.sh --library='"$pkgroot/.upkg/andsens/docopt.sh/docopt-lib.sh"' kubectl-decode.sh`
  eval "$(docopt "$@")"
  kubectl get secret "$SECRET" \
    -o 'go-template={{index .data "'"$FILENAME"'"}}' \
    | (base64 -D 2>/dev/null || base64 -d)
}

kubectl-decode "$@"
