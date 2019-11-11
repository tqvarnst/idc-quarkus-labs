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
  container_runtime=$(which podman)
fi

create_network_or_pod() {
  let container_runtime=$1
  let network_or_pod_name=$2
  let pod_port=$3

  if [ "${container_runtime}" == "docker"]; then
    ${container_runtime} network create ${network_or_pod_name}
  else
    ${container_runtime} pod create --name=${network_or_pod_name} -p ${pod_port} 
  fi
}

delete_network_or_pod() {
  let container_runtime=$1
  let network_or_pod_name=$2
  let pod_port=$3

  if [ "${container_runtime}" == "docker"]; then
    ${container_runtime} network create ${network_or_pod_name}
  else
    ${container_runtime} pod create --name=${network_or_pod_name} -p ${pod_port} 
  fi
}

create_database_container() {
  let container_runtime=$1
  let network_or_pod_name=$2

  printf "Starting PostgreSQL for $(test "${container_runtime}" = "podman" && echo "pod" || echo "network") ${network_or_pod_name}"
  ${container_runtime} run --ulimit memlock=-1:-1 -d --rm=true --$(test "${container_runtime}" = "podman" && echo "pod" || echo "network")=${network_or_pod_name} --memory-swappiness=0 --name postgresql -e POSTGRES_USER=todo -e POSTGRES_PASSWORD=todo -e POSTGRES_DB=todo-db postgres:10.5 > /dev/null
  # Waiting for the database to start
  while ! (${container_runtime} exec -it postgresql psql -U todo todo-db -c "select 1" > /dev/null 2>&1)
  do
    sleep .2
    printf "."
  done
  echo "[DONE]"
}



printf "Stopping any running instances "
${container_runtime} stop spring-boot > /dev/null 2>&1 || true
printf "."
${container_runtime} stop quarkus-jvm > /dev/null 2>&1 || true
printf "."
${container_runtime} stop quarkus-native > /dev/null 2>&1 || true
printf "."
${container_runtime} stop postgresql > /dev/null 2>&1 || true
echo "[DONE]"

printf "Creating network for containers "
${container_runtime} network create idc-lab-network > /dev/null 2>&1 || true
echo "[DONE]"

printf "Starting PostgreSQL "
${container_runtime} run --ulimit memlock=-1:-1 -d --rm=true --network=idc-lab-network --memory-swappiness=0 --name postgresql -e POSTGRES_USER=todo -e POSTGRES_PASSWORD=todo -e POSTGRES_DB=todo-db -p 5432:5432 postgres:10.5 > /dev/null
# Waiting for the database to start
while ! (${container_runtime} exec -it postgresql psql -U todo todo-db -c "select 1" > /dev/null 2>&1)
do
  sleep .2
  printf "."
done
echo "[DONE]"

printf "Creating database tables and content "
${container_runtime} exec -it postgresql psql -U todo todo-db -c "create table Todo (
       id int8 not null,
        completed boolean not null,
        ordering int4,
        title varchar(255),
        url varchar(255),
        primary key (id)
    )" > /dev/null
printf "."

${container_runtime} exec -it postgresql psql -U todo todo-db -c "create sequence hibernate_sequence start with 1 increment by 1" > /dev/null
printf "."
${container_runtime} exec -it postgresql psql -U todo todo-db -c "alter table if exists Todo drop constraint if exists unique_title_constraint" > /dev/null
printf "."
${container_runtime} exec -it postgresql psql -U todo todo-db -c "alter table if exists Todo add constraint unique_title_constraint unique (title)" > /dev/null
printf "."
${container_runtime} exec -it postgresql psql -U todo todo-db -c "INSERT INTO todo(id, title, completed, ordering, url) VALUES (nextval('hibernate_sequence'), 'Introduction to Quarkus', true, 0, null)" > /dev/null
printf "."
${container_runtime} exec -it postgresql psql -U todo todo-db -c "INSERT INTO todo(id, title, completed, ordering, url) VALUES (nextval('hibernate_sequence'), 'Hibernate with Panache', false, 1, null)" > /dev/null
printf "."
${container_runtime} exec -it postgresql psql -U todo todo-db -c "INSERT INTO todo(id, title, completed, ordering, url) VALUES (nextval('hibernate_sequence'), 'Visit Quarkus web site', false, 2, 'https://quarkus.io')" > /dev/null
printf "."
${container_runtime} exec -it postgresql psql -U todo todo-db -c "INSERT INTO todo(id, title, completed, ordering, url) VALUES (nextval('hibernate_sequence'), 'Star Quarkus project', false, 3, 'https://github.com/quarkusio/quarkus/')" > /dev/null
echo "[DONE]"


printf "Starting Spring Boot container on port 8080 "
${container_runtime} run -d --rm -p 8080:8080 --cpus=1 --memory=1G --network=idc-lab-network --name=spring-boot spring/hello > /dev/null
while ! (curl -sf http://localhost:8080 > /dev/null)
do
  sleep .2
  printf "."
done
echo "[DONE]"

printf "Starting Quarkus JVM container on port 8081 "
${container_runtime} run -d --rm -p 8081:8080 --cpus=1 --memory=1G --network=idc-lab-network --name=quarkus-jvm quarkus/hello-jvm > /dev/null
while ! (curl -sf http://localhost:8081 > /dev/null)
do
  sleep .2
  printf "."
done
echo "[DONE]"


printf "Starting Quarkus native container on port 8082 "
${container_runtime} run -d --rm -p 8082:8080 --cpus=1 --memory=1G --network=idc-lab-network --name=quarkus-native quarkus/hello-native > /dev/null
while ! (curl -sf http://localhost:8082 > /dev/null)
do
  sleep .2
  printf "."
done
echo "[DONE]"

echo "Displaying stats for containers: "
${container_runtime} stats --no-stream $(test "${container_runtime}" = "podman" && echo "--no-reset") spring-boot quarkus-jvm quarkus-native

trap - EXIT
