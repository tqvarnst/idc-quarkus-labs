UNAME := $(shell uname)

ifeq ($(UNAME), Linux)
	os=linux
endif
ifeq ($(UNAME), Darwin)
	os=mac
endif

all: build run

build:
	./build-$(os).sh

run:
	./run-$(os).sh

clean:
	./stop-$(os).sh

