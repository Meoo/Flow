
include ../Platform.mk

CXXFLAGS := -Wall
LDFLAGS :=

ifeq ($(CONFIG),release)
  CXXFLAGS += -O2
  LDFLAGS += -O2
endif

CFLAGS := $(CXXFLAGS)


my-dir = $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))
my-bin-dir = $(BIN-DIR)/$(call my-dir)

FLOW-BUILD-DEPS :=
FLOW-DEPLOY-DEPS :=
FLOW-CLEAN-DEPS :=


SUBPROJECTS-MAKE := $(wildcard */Emscripten.mk)
include $(SUBPROJECTS-MAKE)


.PHONY: build deploy clean
build: $(FLOW-BUILD-DEPS)
deploy: $(FLOW-DEPLOY-DEPS)
clean: $(FLOW-CLEAN-DEPS)
