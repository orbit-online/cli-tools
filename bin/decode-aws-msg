#!/usr/bin/env bash

aws_decode_msg() {
  local msg
  if [[ -n $1 ]]; then
    msg=$1
  else
    msg=$(cat)
  fi
  aws sts decode-authorization-message --encoded-message "$msg" | jq .DecodedMessage
}

aws_decode_msg "$@"
