#!/usr/bin/env bash

pod_by_ip() {
  kubectl get --all-namespaces -o json pods | jq -r '.items[] | select(.status.podIP=="'"$1"'") | (.metadata.namespace + "." + .metadata.name)'
}

pod_by_ip "$@"
