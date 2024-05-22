#!/usr/bin/env bash

highlight() {
  local pattern=$1
  : "${pattern? "You must provide a pattern to match"}"
  grep --color -E "|$pattern"
}

highlight "$@"
