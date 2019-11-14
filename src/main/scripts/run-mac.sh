#!/bin/bash

set -e


# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

if docker --help > /dev/null 2>&1; then
  container_runtime=$(which docker)
fi

if podman --help > /dev/null 2>&1; then
  container_runtime=$(which podman)
fi

# printf "Stopping any running instances "
# docker stop spring-boot > /dev/null 2>&1 || true
# printf "."
# docker stop quarkus-jvm > /dev/null 2>&1 || true
# printf "."
# docker stop quarkus-native > /dev/null 2>&1 || true
# printf "."
# docker stop postgresql > /dev/null 2>&1 || true
# echo "[DONE]"

printf "Creating network for containers "
docker network create demo-network > /dev/null 2>&1 || true
echo "[DONE]"

printf "Starting PostgreSQL "
docker run --ulimit memlock=-1:-1 -d --rm=true --network=demo-network --memory-swappiness=0 --name postgresql -e POSTGRES_USER=todo -e POSTGRES_PASSWORD=todo -e POSTGRES_DB=todo-db -p 5432:5432 postgres:10.5 > /dev/null
# Waiting for the database to start
while ! (docker exec -it postgresql psql -U todo todo-db -c "select 1" > /dev/null 2>&1)
do
  sleep .2
  printf "."
done
echo "[DONE]"

printf "Creating database tables and content "
docker exec -it postgresql psql -U todo todo-db -c "create table Todo (
       id int8 not null,
        completed boolean not null,
        ordering int4,
        title varchar(255),
        url varchar(255),
        primary key (id)
    )" > /dev/null
printf "."

docker exec -it postgresql psql -U todo todo-db -c "create sequence hibernate_sequence start with 1 increment by 1" > /dev/null
printf "."
docker exec -it postgresql psql -U todo todo-db -c "alter table if exists Todo drop constraint if exists unique_title_constraint" > /dev/null
printf "."
docker exec -it postgresql psql -U todo todo-db -c "alter table if exists Todo add constraint unique_title_constraint unique (title)" > /dev/null
printf "."
docker exec -it postgresql psql -U todo todo-db -c "INSERT INTO todo(id, title, completed, ordering, url) VALUES (nextval('hibernate_sequence'), 'Introduction to Quarkus', true, 0, null)" > /dev/null
printf "."
docker exec -it postgresql psql -U todo todo-db -c "INSERT INTO todo(id, title, completed, ordering, url) VALUES (nextval('hibernate_sequence'), 'Hibernate with Panache', false, 1, null)" > /dev/null
printf "."
docker exec -it postgresql psql -U todo todo-db -c "INSERT INTO todo(id, title, completed, ordering, url) VALUES (nextval('hibernate_sequence'), 'Visit Quarkus web site', false, 2, 'https://quarkus.io')" > /dev/null
printf "."
docker exec -it postgresql psql -U todo todo-db -c "INSERT INTO todo(id, title, completed, ordering, url) VALUES (nextval('hibernate_sequence'), 'Star Quarkus project', false, 3, 'https://github.com/quarkusio/quarkus/')" > /dev/null
echo "[DONE]"


printf "Starting Quarkus native container on port 8082 "
docker run -d --rm -p 8082:8081 --cpus=1 --memory=1G --network=demo-network --name=quarkus-native -e QUARKUS_DATASOURCE_URL=jdbc:postgresql://postgresql/todo-db quarkus-native/todo > /dev/null
while ! (curl -sf http://localhost:8082 > /dev/null)
do
  sleep .2
  printf "."
done
echo "[DONE]"


printf "Starting Quarkus JVM container on port 8081 "
docker run -d --rm -p 8081:8081 --cpus=1 --memory=1G --network=demo-network --name=quarkus-jvm -e QUARKUS_DATASOURCE_URL=jdbc:postgresql://postgresql/todo-db quarkus-jvm/todo > /dev/null
while ! (curl -sf http://localhost:8081 > /dev/null)
do
  sleep .2
  printf "."
done
echo "[DONE]"

printf "Starting Spring Boot container on port 8080 "
docker run -d --rm -p 8080:8080 --cpus=1 --memory=1G --network=demo-network --name=spring-boot -e SPRING_DATASOURCE_URL=jdbc:postgresql://postgresql/todo-db spring/todo > /dev/null
while ! (curl -sf http://localhost:8080 > /dev/null)
do
  sleep .2
  printf "."
done
echo "[DONE]"





echo "Displaying stats for containers: "
docker stats --no-stream spring-boot quarkus-jvm quarkus-native

trap - EXIT
