#!/bin/bash
set -e

container_runtime=podman
container_db_name=postgresql
container_spring_name=spring-boot
container_quarkus_jvm_name=quarkus-jvm
container_quarkus_native_name=quarkus-native

if [ "$(uname)" == "Darwin" ]; then
  container_runtime=docker
  container_network_name=idc_demo_network
fi

printf "Stopping any running instances"
${container_runtime} stop ${container_spring_name} > /dev/null 2>&1 || true
printf "."
${container_runtime} stop ${container_quarkus_jvm_name} > /dev/null 2>&1 || true
printf "."
${container_runtime} stop ${container_quarkus_native_name} > /dev/null 2>&1 || true
printf "."
${container_runtime} stop ${container_db_name} > /dev/null 2>&1 || true
echo "[DONE]"

if [ "$(uname)" == "Darwin" ]; then
  printf "Deleting network for containers "
  ${container_runtime} network rm idc-lab-network > /dev/null 2>&1 || true
  echo "[DONE]"
fi
