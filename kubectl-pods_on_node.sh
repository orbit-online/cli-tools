#!/usr/bin/env bash

pods_on_node() {
  kubectl get --all-namespaces pod -o json | \
	  jq -r '.items[] | select(.status.hostIP | match("'$1'")) | (.status.hostIP + ":" + .metadata.namespace + "." + .metadata.name)'
}

pods_on_node "$@"
