UNAME := $(shell uname)

ifeq ($(UNAME), Linux)
	os=linux
endif
ifeq ($(UNAME), Darwin)
	os=mac
endif

.PHONY: all spring quarkus-jvm quarkus-native build run clean stop

all: build run

build: spring quarkus-jvm quarkus-native

spring:
	@$(MAKE) -C spring-todo build

quarkus-jvm:
	@$(MAKE) -C quarkus-todo build-jvm

quarkus-native:
	@$(MAKE) -C quarkus-todo build-native

run: stop
	./src/main/scripts/run-$(os).sh

clean: 
	@$(MAKE) -C quarkus-todo clean
	@$(MAKE) -C spring-todo clean

stop: 
	src/main/scripts/stop-$(os).sh





