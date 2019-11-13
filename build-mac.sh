#!/bin/bash
set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

cd "$(dirname "$0")"

if [ -z "${GRAALVM_HOME}" ]; then
  echo "[ERROR]:GRAALVM_HOME environment varible needs to be set and pointing to a valid version of GraalVM (e.g. CE 19.2.1)" >&2
  exit 1
fi

if [ ! -f "${GRAALVM_HOME}/bin/native-image" ]; then
  echo "[ERROR]: You need to install GraalVM native compiler by running the following command \"${GRAALVM_HOME}/bin/gu install native-image\"" >&2
  exit 2
fi

if [ -z "$(which docker)" ]; then
  echo "[ERROR]: You need to have either docker or podman installed to run this build script" >&2
  exit 3
fi

printf "Building java source code using maven " 
./mvnw clean package > /dev/null
echo "[DONE]"

printf "Building Spring container image "
pushd spring-lab1.1 > /dev/null
docker build -q -f src/main/docker/Dockerfile -t spring/hello . > /dev/null
popd > /dev/null
echo "[DONE]"


printf "Building Quarkus JVM container image "
pushd quarkus-lab1.1 > /dev/null
docker build -q -f src/main/docker/Dockerfile.jvm -t quarkus/hello-jvm . > /dev/null
popd > /dev/null
echo "[DONE]"

pushd quarkus-lab1.1 > /dev/null

printf "Building Quarkus native "

if [ "$(uname)" == "Darwin" ]; then
  ./mvnw package -Pnative -Dquarkus.native.container-build=true -Dquarkus.profile=native > /dev/null
else
  ./mvnw package -Pnative -Dquarkus.profile=native > /dev/null
fi
echo "[DONE]"

printf "Building Quarkus native docker image"
docker build -q -f src/main/docker/Dockerfile.native -t quarkus/hello-native . > /dev/null
echo "[DONE]"

popd > /dev/null

trap - EXIT




