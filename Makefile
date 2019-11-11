UNAME := $(shell uname)

ifeq ($(UNAME), Linux)
	os=linux
endif
ifeq ($(UNAME), Darwin)
	os=mac
endif


build:
	./build.sh

run:
	./run-all-$(os).sh

stop:
	./stop-all.sh

