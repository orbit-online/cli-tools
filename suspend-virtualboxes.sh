#!/usr/bin/env bash

suspend-virtualboxes() {
  local pkgroot; pkgroot=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

  DOC="Suspend all running VirtualBox VMs
Usage:
  suspend-virtualboxes"
# docopt parser below, refresh this parser with `docopt.sh suspend-virtualboxes.sh`
# shellcheck disable=2016,1090,1091,2034
docopt() { source "$pkgroot/.upkg/andsens/docopt.sh/docopt-lib.sh" '1.0.0' || {
ret=$?; printf -- "exit %d\n" "$ret"; exit "$ret"; }; set -e
trimmed_doc=${DOC:0:64}; usage=${DOC:35:29}; digest=de475; shorts=(); longs=()
argcounts=(); node_0(){ required ; }; node_1(){ required 0; }
cat <<<' docopt_exit() { [[ -n $1 ]] && printf "%s\n" "$1" >&2
printf "%s\n" "${DOC:35:29}" >&2; exit 1; }'; unset ; parse 1 "$@"; return 0
local prefix=${DOCOPT_PREFIX:-''}; unset ; local docopt_i=1
[[ $BASH_VERSION =~ ^4.3 ]] && docopt_i=2; for ((;docopt_i>0;docopt_i--)); do
declare -p ; done; }
# docopt parser above, complete command for generating this parser is `docopt.sh --library='"$pkgroot/.upkg/andsens/docopt.sh/docopt-lib.sh"' suspend-virtualboxes.sh`
  eval "$(docopt "$@")"
  # On OSX install with:
  #   sudo defaults write com.apple.loginwindow LogoutHook $HOME/.homesick/repos/dotfiles/tools/suspend_virtualboxes.sh
  owner=$(stat -f %u "$0")
  current_user=$(id -u)
  if [[ $current_user != "$owner" ]]; then
    sudo="sudo -u #$owner"
  fi
  for uuid in $($sudo VBoxManage list runningvms | awk '{print $NF}'); do
    $sudo VBoxManage controlvm "${uuid}" savestate
  done
}

suspend-virtualboxes "$@"
