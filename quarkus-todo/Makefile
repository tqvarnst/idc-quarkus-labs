UNAME := $(shell uname)

ifeq ($(UNAME), Linux)
	os=linux
endif
ifeq ($(UNAME), Darwin)
	os=mac
endif

.PHONY: build build-jvm build-jvm-mac build-jvm-linux build-native build-native-mac build-native-linux clean

build: build-jvm build-native

### Quarkus JVM
build-jvm: build-jvm-$(os)

build-jvm-mac: target/todo-runner.jar
	docker build -q -f src/main/docker/Dockerfile.jvm -t quarkus-jvm/todo .

build-jvm-linux: target/todo-runner.jar
	podman build -q -f src/main/docker/Dockerfile.jvm -t quarkus-jvm/todo .

target/todo-runner.jar: 
	./mvnw package


### Quarkus Native
build-native: build-native-$(os)

build-native-mac: target/todo-runner
	docker build -q -f src/main/docker/Dockerfile.native -t quarkus-native/todo .

build-native-linux: target/todo-runner
	podman build -q -f src/main/docker/Dockerfile.native -t quarkus-native/todo .

target/todo-runner:
ifeq ($(os),linux)
	./mvnw package -Pnative -Dquarkus.profile=native -Dquarkus.native.container-runtime=podman
else
	./mvnw package -Pnative -Dquarkus.native.container-build=true -Dquarkus.profile=native
endif

clean:
	./mvnw clean




