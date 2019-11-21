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
	./src/main/scripts/run.sh

clean: clean-quarkus clean-spring

clean-quarkus: 
	@$(MAKE) -C quarkus-todo clean

clean-spring:
	@$(MAKE) -C spring-todo clean

stop: 
	src/main/scripts/stop.sh

oc-setup: 
	src/main/scripts/oc-setup.sh

oc-clean: 
	src/main/scripts/oc-clean.sh

rsync:
	git ls-files --exclude-standard -oi --directory > .rsync_ignore
	rsync -a --exclude=".git" --exclude-from=".rsync_ignore" --delete . root@hpc-dl360a-02.mw.lab.eng.bos.redhat.com:demo/idc-quarkus-labs
	rm -f .rsync_ignore





