
CXXFLAGS := -Wall -g
LDFLAGS :=

ifeq ($(CONFIG),release)
  CXXFLAGS += -O3
  LDFLAGS += -flto -O3
endif

CFLAGS := $(CXXFLAGS)


my-dir = $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))
my-bin-dir = $(BIN-DIR)/$(call my-dir)

FLOW-BUILD-DEPS :=
FLOW-DEPLOY-DEPS :=
FLOW-CLEAN-DEPS :=


SUBPROJECTS-MAKE := $(wildcard */Vanilla.mk)
include $(SUBPROJECTS-MAKE)


.PHONY: build deploy clean
build: $(FLOW-BUILD-DEPS)
deploy: $(FLOW-DEPLOY-DEPS)
clean: $(FLOW-CLEAN-DEPS)
