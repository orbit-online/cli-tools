#!/usr/bin/env bash

pods_by_node() {
  kubectl get --all-namespaces pod -o json | \
	  jq -r '.items[] | select(.metadata.name | match("'$1'")) | (.status.hostIP + ":" + .metadata.namespace + "." + .metadata.name)'
}

pods_by_node "$@"
