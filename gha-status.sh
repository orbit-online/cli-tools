#!/usr/bin/env bash

main() {
  set -eo pipefail; shopt -s inherit_errexit
  local pkgroot; pkgroot=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
  source "$pkgroot/.upkg/orbit-online/records.sh/records.sh"
  DOC="gha-status - Show the status of GitHub actions
Usage:
  gha-status [options] [GIT_REF] [REPO]

Options:
  -W --no-watch   Don't watch the status, print it once and exit
"
# docopt parser below, refresh this parser with `docopt.sh gha-status.sh`
# shellcheck disable=2016,1090,1091,2034
docopt() { source "$pkgroot/.upkg/andsens/docopt.sh/docopt-lib.sh" '1.0.0' || {
ret=$?; printf -- "exit %d\n" "$ret"; exit "$ret"; }; set -e
trimmed_doc=${DOC:0:168}; usage=${DOC:47:46}; digest=b43a5; shorts=(-W)
longs=(--no-watch); argcounts=(0); node_0(){ switch __no_watch 0; }; node_1(){
value GIT_REF a; }; node_2(){ value REPO a; }; node_3(){ optional 0; }
node_4(){ optional 3; }; node_5(){ optional 1; }; node_6(){ optional 2; }
node_7(){ required 4 5 6; }; node_8(){ required 7; }; cat <<<' docopt_exit() {
[[ -n $1 ]] && printf "%s\n" "$1" >&2; printf "%s\n" "${DOC:47:46}" >&2; exit 1
}'; unset var___no_watch var_GIT_REF var_REPO; parse 8 "$@"
local prefix=${DOCOPT_PREFIX:-''}; unset "${prefix}__no_watch" \
"${prefix}GIT_REF" "${prefix}REPO"
eval "${prefix}"'__no_watch=${var___no_watch:-false}'
eval "${prefix}"'GIT_REF=${var_GIT_REF:-}'; eval "${prefix}"'REPO=${var_REPO:-}'
local docopt_i=1; [[ $BASH_VERSION =~ ^4.3 ]] && docopt_i=2
for ((;docopt_i>0;docopt_i--)); do declare -p "${prefix}__no_watch" \
"${prefix}GIT_REF" "${prefix}REPO"; done; }
# docopt parser above, complete command for generating this parser is `docopt.sh --library='"$pkgroot/.upkg/andsens/docopt.sh/docopt-lib.sh"' gha-status.sh`
  eval "$(docopt "$@")"

  local org repo git_ref
  if [[ -z $REPO ]]; then
    local git_remote_url symbolic_ref branch remote_name
    symbolic_ref=$(git symbolic-ref HEAD 2>/dev/null)
    branch=${symbolic_ref#refs/heads/}
    remote_name=$(git config "branch.$branch.remote" 2>/dev/null)
    git_remote_url=$(git remote get-url "$remote_name")
    if [[ ! $git_remote_url =~ ^.+github\.com[:/]([^/]+)/([^/]+)(\.git)? ]]; then
      fatal "Unable to extract the organization and repo name from the origin URL '%s'" "$git_remote_url"
    fi
    org=${BASH_REMATCH[1]}
    repo=${BASH_REMATCH[2]}
  elif [[ $REPO =~ ^(.+github\.com[:/])?([^/]+)/([^/]+)(\.git)? ]]; then
    org=${BASH_REMATCH[2]}
    repo=${BASH_REMATCH[3]}
  else
      fatal "Unable to extract the organization and repo name from the origin URL '%s'" "$REPO"
  fi
  if [[ -z $GIT_REF ]]; then
    git_ref=$(git rev-parse HEAD)
  else
    git_ref=$GIT_REF
  fi
  # \033[<N>A
  local suites retries_left=20
  while [[ -z $suites ]]; do
    suites=$(get_suites "$org" "$repo" "$git_ref")
    sleep .5
    if ((--retries_left <= 0 )); then
      fatal "Unable to find any workflows matching %s/%s on the git ref %s" "$org" "$repo" "$git_ref"
    fi
  done

  local in_progress_icon=(◜ ◝ ◞ ◟) in_progress_iteration=0 lines_printed
  local suite_id job_name status conclusion all_completed

  while true; do
    all_completed=true
    lines_printed=0
    while IFS=' ' read -r -d$'\n' suite_id job_name; do
      [[ $lines_printed = 0 ]] || printf "\n"
      IFS=' ' read -r -d$'\n' status conclusion < <(get_run_status "$org" "$repo" "$suite_id") || true
      [[ $status = "completed" ]] || all_completed=false
      if [[ $status = 'queued' ]]; then
        printf $'\e[;34m⏸ '
      elif [[ $status = 'in_progress' ]]; then
        printf $'\e[;33m%s ' "${in_progress_icon[$in_progress_iteration]}"
      elif [[ $status = 'completed' ]]; then
        if [[ $conclusion = 'success' ]]; then
          printf $'\e[;32m✓ '
        elif [[ $conclusion = 'failure' ]]; then
          printf $'\e[;41m❌ '
        fi
      else
        printf "Unknown status: %s" "$status"
      fi
      printf $'%s\e[0m' "$job_name"
      : $((lines_printed++))
    done < <(get_suites "$org" "$repo" "$git_ref")
    # shellcheck disable=2154
    if $__no_watch || $all_completed; then
      break
    fi
    in_progress_iteration=$((++in_progress_iteration % 4))
    printf $'\r'
    ((lines_printed <= 1)) || printf $'\e[%dA' "$((lines_printed - 1))"
    sleep 1
  done
  printf "\n"
}

get_suites() {
  local org=$1 repo=$2 git_ref=$3
  gh api -H 'Accept: application/vnd.github.v3+json' \
    "/repos/$org/$repo/commits/$git_ref/check-runs" \
    --jq '.check_runs[] | "\(.check_suite.id) \(.name)"'
}

get_run_status() {
  local org=$1 repo=$2 suite_id=$3
  gh api -H 'Accept: application/vnd.github.v3+json' \
    "/repos/$org/$repo/check-suites/$suite_id/check-runs" \
    --jq '.check_runs[] | "\(.status) \(.conclusion)"'
}

main "$@"
