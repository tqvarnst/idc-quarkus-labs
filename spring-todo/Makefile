UNAME := $(shell uname)

ifeq ($(UNAME), Linux)
	os=linux
endif
ifeq ($(UNAME), Darwin)
	os=mac
endif

.PHONY: build build-mac build-linux clean

build: build-$(os)

build-mac: target/todo.jar 
	docker build -q -f src/main/docker/Dockerfile -t spring/todo .

build-linux: target/todo.jar
	podman build -q -f src/main/docker/Dockerfile -t spring/todo .

target/todo.jar: 
	./mvnw package


clean:
	./mvnw clean




