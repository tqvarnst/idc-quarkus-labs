#!/bin/bash
set -e


# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

cd "$(dirname "$0")"

if docker --help > /dev/null 2>&1; then
  container_runtime=$(which docker)
fi

if podman --help > /dev/null 2>&1; then
  container_runtime=$(which ${container_runtime})
fi

printf "Stopping any running instances"
${container_runtime} stop spring-boot > /dev/null 2>&1 || true
printf "."
${container_runtime} stop quarkus-jvm > /dev/null 2>&1 || true
printf "."
${container_runtime} stop quarkus-native > /dev/null 2>&1 || true
printf "."
${container_runtime} stop postgresql > /dev/null 2>&1 || true
echo "[DONE]"

printf "Deleting network for containers "
${container_runtime} network rm idc-lab-network > /dev/null 2>&1 || true
echo "[DONE]"

trap - EXIT
