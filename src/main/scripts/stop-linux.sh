#!/bin/bash
set -e


# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

function stop_pod {
  printf "Stopping and removing pod $1 \t" 
  podman pod stop $1-pod > /dev/null 2>&1 || true
  podman pod rm -f $1-pod > /dev/null 2>&1 || true 
  echo "[DONE]"
}

stop_pod    spring-boot
stop_pod    quarkus-jvm
stop_pod    quarkus-native

trap - EXIT
