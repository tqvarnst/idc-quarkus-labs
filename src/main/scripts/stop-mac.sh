#!/bin/bash
set -e


# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

printf "Stopping any running instances"
docker stop spring-boot > /dev/null 2>&1 || true
printf "."
docker stop quarkus-jvm > /dev/null 2>&1 || true
printf "."
docker stop quarkus-native > /dev/null 2>&1 || true
printf "."
docker stop postgresql > /dev/null 2>&1 || true
echo "[DONE]"

printf "Deleting network for containers "
docker network rm idc-lab-network > /dev/null 2>&1 || true
echo "[DONE]"

trap - EXIT
