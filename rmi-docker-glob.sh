#!/usr/bin/env bash

main() {
  IFS=$'\n'
  local image
  for image in $(docker images --format '{{.Repository}}:{{.Tag}}'); do
    # shellcheck disable=2053
    # glob matching is exactly what we want
    if [[ $image == $1 ]]; then
      docker rmi "$image"
    fi
  done
}

main "$@"
