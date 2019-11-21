#!/bin/bash
set -e

script_dir=$(dirname $0)


############
## Settings
############

container_runtime=podman

postgresql_pod_name=postgresql

spring_project=spring
spring_local_image_name=spring/todo
spring_pod_name=spring-boot
spring_pod_image=${spring_project}/todo

quarkus_jvm_project=quarkus-jvm
quarkus_jvm_local_image_name=quarkus-jvm/todo
quarkus_jvm_pod_name=quarkus-jvm
quarkus_jvm_pod_image=${quarkus_jvm_project}/todo

quarkus_native_project=quarkus-native
quarkus_native_local_image_name=quarkus-native/todo
quarkus_native_pod_name=quarkus-native
quarkus_native_pod_image=${quarkus_native_project}/todo


project_cpu_limit=8
project_mem_limit=2Gi
pod_cpu_limit=100m
spring_pod_memory_limit=256M
quarkus_jvm_pod_memory_limit=128M
quarkus_native_pod_memory_limit=50M

psql_db_name=todo-db
psql_db_host=localhost
psql_db_user=todo
psql_db_password=todo

if [ "$(uname)" == "Darwin" ]; then
  container_runtime=docker
fi

function verify_oc_cli {
  if ! which oc > /dev/null 2>&1; then
    echo "You need to have the oc cli on the path"
    exit 1
  fi
}

function check_authenticated {
  if ! oc whoami > /dev/null 2>&1; then
    echo "You need to be authenticated to a cluster"
    exit 2
  fi
}

function check_admin {
  local whoami=$(oc whoami)
  if ! [ "$whoami" = "opentlc-mgr" ] || [ "$whoami" = "kube:admin" ]; then
    echo "You need to be authenticated as an admin"
    exit 3
  fi
}


function delete_project {
  oc delete project $1 > /dev/null 2>&1 || true
}


verify_oc_cli
check_authenticated
check_admin

delete_project ${spring_project}
delete_project ${quarkus_jvm_project}
delete_project ${quarkus_native_project}



# Expose the registry 


#oc policy add-role-to-user registry-editor user0

#sleep 2

#



