
#!/bin/bash
set -e
############
## Settings
############
docker_network_name=demo-network
container_db_name=postgresql


container_spring_name=spring-boot
container_spring_port=8080
container_spring_image=spring/todo

container_quarkus_jvm_name=quarkus-jvm
container_quarkus_jvm_port=8081
container_quarkus_jvm_image=quarkus-jvm/todo

container_quarkus_native_name=quarkus-native
container_quarkus_native_port=8082
container_quarkus_native_image=quarkus-native/todo

container_cpu_limit=1
container_memory_limit=500M

psql_db_name=todo-db
psql_db_host=${container_db_name}
psql_db_user=todo
psql_db_password=todo

############
## Functions
############
function create_database_container {
  printf "Starting PostgreSQL with name ${container_db_name} "
  docker run --ulimit memlock=-1:-1 -d --rm=true --network=${docker_network_name} --memory-swappiness=0 --name ${container_db_name} -e POSTGRES_USER=${psql_db_user} -e POSTGRES_PASSWORD=${psql_db_password} -e POSTGRES_DB=${psql_db_name} postgres:10.5 > /dev/null
  # Waiting for the database to start
  while ! (docker exec -it ${container_db_name} psql -U ${psql_db_user} ${psql_db_name} -c "select 1" > /dev/null 2>&1)
  do
    sleep .2
    printf "."
  done
  echo "[DONE]"

  
}

function prepopulate_database {
  printf "Creating database tables and content "
  docker exec -it ${container_db_name} psql -U ${psql_db_user} ${psql_db_name} -c "create table Todo (
        id int8 not null,
          completed boolean not null,
          ordering int4,
          title varchar(255),
          url varchar(255),
          primary key (id)
      )" > /dev/null
  printf "."

  docker exec -it ${container_db_name} psql -U ${psql_db_user} ${psql_db_name} -c "create sequence hibernate_sequence start with 1 increment by 1" > /dev/null
  printf "."
  docker exec -it ${container_db_name} psql -U ${psql_db_user} ${psql_db_name} -c "alter table if exists Todo drop constraint if exists unique_title_constraint" > /dev/null
  printf "."
  docker exec -it ${container_db_name} psql -U ${psql_db_user} ${psql_db_name} -c "alter table if exists Todo add constraint unique_title_constraint unique (title)" > /dev/null
  printf "."
  docker exec -it ${container_db_name} psql -U ${psql_db_user} ${psql_db_name} -c "INSERT INTO todo(id, title, completed, ordering, url) VALUES (nextval('hibernate_sequence'), 'Introduction to Quarkus', true, 0, null)" > /dev/null
  printf "."
  docker exec -it ${container_db_name} psql -U ${psql_db_user} ${psql_db_name} -c "INSERT INTO todo(id, title, completed, ordering, url) VALUES (nextval('hibernate_sequence'), 'Hibernate with Panache', false, 1, null)" > /dev/null
  printf "."
  docker exec -it ${container_db_name} psql -U ${psql_db_user} ${psql_db_name} -c "INSERT INTO todo(id, title, completed, ordering, url) VALUES (nextval('hibernate_sequence'), 'Visit Quarkus web site', false, 2, 'https://quarkus.io')" > /dev/null
  printf "."
  docker exec -it ${container_db_name} psql -U ${psql_db_user} ${psql_db_name} -c "INSERT INTO todo(id, title, completed, ordering, url) VALUES (nextval('hibernate_sequence'), 'Star Quarkus project', false, 3, 'https://github.com/quarkusio/quarkus/')" > /dev/null
  echo "[DONE]"
}


function create_container {
  local name=$1
  local image=$2
  local port=$3
  shift 3
  local env="$*"
 
  printf "Starting ${image} container in pod ${name}-pod using port ${port} "
  docker run -d --rm --cpus=${container_cpu_limit} --memory=${container_memory_limit} -p ${port}:${port} --network=${docker_network_name} --name=${name} ${env} ${image} > /dev/null
  while ! (curl -sf http://localhost:${port} > /dev/null)
  do
    sleep .2
    printf "."
  done
  echo "[DONE]"
}

#############
## Script
############

printf "Creating network for containers "
docker network create demo-network > /dev/null 2>&1 || true
echo "[DONE]"

create_database_container   ${container_db_name}
prepopulate_database        ${container_db_name}

# Starting the cloud native runtime and wait for first response
create_container ${container_spring_name} ${container_spring_image} ${container_spring_port} -e SPRING_HTTP_PORT=${container_spring_port} -e SPRING_DATASOURCE_URL=jdbc:postgresql://${psql_db_host}/${psql_db_name}
create_container ${container_quarkus_jvm_name} ${container_quarkus_jvm_image} ${container_quarkus_jvm_port} -e QUARKUS_HTTP_PORT=${container_quarkus_jvm_port} -e QUARKUS_DATASOURCE_URL=jdbc:postgresql://${psql_db_host}/${psql_db_name}
create_container ${container_quarkus_native_name} ${container_quarkus_native_image} ${container_quarkus_native_port} -e QUARKUS_HTTP_PORT=${container_quarkus_native_port} -e QUARKUS_DATASOURCE_URL=jdbc:postgresql://${psql_db_host}/${psql_db_name}

echo "Displaying stats for containers: "
docker stats --no-stream ${container_spring_name} ${container_quarkus_jvm_name} ${container_quarkus_native_name}
