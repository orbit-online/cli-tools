#!/usr/bin/env bash

download-git-path() {
  local pkgroot
  pkgroot=$(upkg root "${BASH_SOURCE[0]}")

  DOC="Download a subdirectory of a git repository
Usage:
  download-git-path <repo-url> <tree-ish> <pathspec>...
  download-git-path <github-url>..."
# docopt parser below, refresh this parser with `docopt.sh download-git-path.sh`
# shellcheck disable=2016,1090,1091,2034,2154
docopt() { source "$pkgroot/.upkg/andsens/docopt.sh/docopt-lib.sh" '1.0.0' || {
ret=$?; printf -- "exit %d\n" "$ret"; exit "$ret"; }; set -e
trimmed_doc=${DOC:0:142}; usage=${DOC:44:98}; digest=0c552; shorts=(); longs=()
argcounts=(); node_0(){ value _repo_url_ a; }; node_1(){ value _tree_ish_ a; }
node_2(){ value _pathspec_ a true; }; node_3(){ value _github_url_ a true; }
node_4(){ oneormore 2; }; node_5(){ required 0 1 4; }; node_6(){ oneormore 3; }
node_7(){ required 6; }; node_8(){ either 5 7; }; node_9(){ required 8; }
cat <<<' docopt_exit() { [[ -n $1 ]] && printf "%s\n" "$1" >&2
printf "%s\n" "${DOC:44:98}" >&2; exit 1; }'; unset var__repo_url_ \
var__tree_ish_ var__pathspec_ var__github_url_; parse 9 "$@"
local prefix=${DOCOPT_PREFIX:-''}; unset "${prefix}_repo_url_" \
"${prefix}_tree_ish_" "${prefix}_pathspec_" "${prefix}_github_url_"
eval "${prefix}"'_repo_url_=${var__repo_url_:-}'
eval "${prefix}"'_tree_ish_=${var__tree_ish_:-}'
if declare -p var__pathspec_ >/dev/null 2>&1; then
eval "${prefix}"'_pathspec_=("${var__pathspec_[@]}")'; else
eval "${prefix}"'_pathspec_=()'; fi
if declare -p var__github_url_ >/dev/null 2>&1; then
eval "${prefix}"'_github_url_=("${var__github_url_[@]}")'; else
eval "${prefix}"'_github_url_=()'; fi; local docopt_i=1
[[ $BASH_VERSION =~ ^4.3 ]] && docopt_i=2; for ((;docopt_i>0;docopt_i--)); do
declare -p "${prefix}_repo_url_" "${prefix}_tree_ish_" "${prefix}_pathspec_" \
"${prefix}_github_url_"; done; }
# docopt parser above, complete command for generating this parser is `docopt.sh --library='"$pkgroot/.upkg/andsens/docopt.sh/docopt-lib.sh"' download-git-path.sh`
  eval "$(docopt "$@")"
  if [[ -n $_github_url_ ]]; then
    if [[ ! $_github_url_ =~ https://github.com/.*/.*/tree/.* ]]; then
      printf "Not a github url\n" >&2
      return 1
    fi
    local gh_path=${_github_url_/#https:\/\/github.com\//}
    local gh_user=${gh_path/%\/*/}
    gh_path=${gh_path/#$gh_user\//}
    local gh_repo=${gh_path/%\/*/}
    gh_path=${gh_path/#$gh_repo\/tree\//}
    local gh_ref=${gh_path/%\/*/}
    gh_path=${gh_path/#$gh_ref\//}
    _repo_url_="git@github.com:$gh_user/$gh_repo"
    _tree_ish_=$gh_ref
    _pathspec_=$gh_path
  fi
  local tmpgit
  tmpgit=$(mktemp -d)
  # shellcheck disable=2064
  trap "rm -rf \"$tmpgit\"" EXIT
  git init "$tmpgit"
  (
    cd "$tmpgit" && \
    git config core.sparseCheckout true 2>/dev/null && \
    printf "%s\n" "${_pathspec_[@]}" >> .git/info/sparse-checkout && \
    git remote add -f origin "$_repo_url_" 2>/dev/null && \
    git checkout "$_tree_ish_" 2>/dev/null
  )
  local repodir
  repodir=$(basename "$_repo_url_")
  local dir
  for dir in "${_pathspec_[@]}"; do
    if [[ ! -d "$tmpgit/$dir" ]]; then
      printf "%s is not a directory" "$tmpgit/$dir" >&2
      continue
    fi
    mkdir -p "$repodir/$(dirname "$dir")"
    mv "$tmpgit/$dir" "$repodir/$(dirname "$dir")"
  done
}

download-git-path "$@"
