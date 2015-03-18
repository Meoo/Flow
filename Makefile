
ifdef ComSpec
  # Windows
  export c-wpath = $(subst /,\,$1)
  export c-wifexist = if exist $2 $1 $2
  export c-wifnexist = if not exist $2 $1 $2
  export c-copy-struct = xcopy /T $(call c-wpath,$1) $(call c-wpath,$2)

else
  # Unix
  export c-copy-struct = cd $1 && find . -type d -exec mkdir -p -- $2/{} \;

endif

ifneq (sh,$(findstring sh,$(shell echo $$BASH)))
  # No shell (windows only)
  export c-mkdir = $(call c-wifnexist,mkdir,$(call c-wpath,$1))
  export c-rm = $(call c-wifexist,del /Q,$(call c-wpath,$1))
  export c-rmr = $(call c-wifexist,del /S/Q,$(call c-wpath,$1))
  export c-cp = copy /B $(call c-wpath,$1) $(call c-wpath,$2)

else
  # Shell
  export c-mkdir = mkdir -p -- $1
  export c-rm = rm -f -- $1
  export c-rmr = rm -rf -- $1
  export c-cp = cp -- $1 $2

endif


BIN-DIR := $(CURDIR)/bin
DEPLOY-DIR := $(CURDIR)/deploy


config ?= release
export CONFIG := $(config)

ifeq (,$(filter $(config), release debug))
  $(error "config" is not set to a valid value)
endif


help:
	@echo.
	@echo Configuration :
	@echo  - config=[debug, *release]
	@echo.
	@echo Vanilla build :
	@echo  - build
	@echo  - deploy
	@echo  - clean
	@echo Emscripten build :
	@echo  - em-build
	@echo  - em-deploy
	@echo  - em-clean
	@echo Android build :
	@echo  - android-build
	@echo  - android-deploy
	@echo  - android-install
	@echo  - android-run
	@echo  - android-clean
	@echo.
	@echo  - purge
	@echo.


ifeq ($(OS),Windows_NT)
  export HOST:=windows
else
  UNAME_S := $(shell uname -s)
  ifeq ($(UNAME_S),Linux)
    export HOST:=linx
  endif
  ifeq ($(UNAME_S),Darwin)
    export HOST:=osx
  endif
endif


# Vanilla GCC build
.PHONY: build deploy clean
VAN-BIN-DIR := $(BIN-DIR)/vanilla_$(CONFIG)
VAN-MAKEFLAGS := -f Vanilla.mk BIN-DIR=$(VAN-BIN-DIR)

build:
	@echo.
	@echo ===== Vanilla Build =====
	@echo.
	$(call c-mkdir,$(VAN-BIN-DIR))
	$(call c-copy-struct,source,$(VAN-BIN-DIR))
	$(MAKE) -C source $(VAN-MAKEFLAGS) build

deploy: build
	@echo.
	@echo ===== Vanilla Deploy =====
	@echo.
	$(call c-rmr,$(DEPLOY-DIR))
	$(call c-mkdir,$(DEPLOY-DIR))
	$(MAKE) -C source $(VAN-MAKEFLAGS) DEPLOY-DIR=$(DEPLOY-DIR) deploy
	
clean:
	$(MAKE) -C source $(VAN-MAKEFLAGS) clean


# Emscripten build
.PHONY: em-check em-build em-deploy em-clean
EM-BIN-DIR := $(BIN-DIR)/emscripten_$(CONFIG)
EM-MAKEFLAGS := -f Emscripten.mk BIN-DIR=$(EM-BIN-DIR)

em-check:
ifndef EMSCRIPTEN
	$(error EMSCRIPTEN is missing. Activate an emscripten SDK and try again)
endif

em-build: em-check
	@echo.
	@echo ===== Emscripten Build =====
	@echo.
	$(call c-mkdir,$(EM-BIN-DIR))
	$(call c-copy-struct,source,$(EM-BIN-DIR))
	emmake $(MAKE) -C source $(EM-MAKEFLAGS) build

em-deploy: em-build
	@echo.
	@echo ===== Emscripten Deploy =====
	@echo.
	$(call c-rmr,$(DEPLOY-DIR))
	$(call c-mkdir,$(DEPLOY-DIR))
	$(MAKE) -C source $(EM-MAKEFLAGS) DEPLOY-DIR=$(DEPLOY-DIR) deploy
	
em-clean: em-check
	emmake $(MAKE) -C source $(EM-MAKEFLAGS) clean


# Android JNI build
.PHONY: android-check android-build android-deploy android-install android-run android-clean
ANDROID-BIN-DIR := $(BIN-DIR)/android_$(CONFIG)
ANDROID-MAKEFLAGS := BIN-DIR=$(ANDROID-BIN-DIR) NDK_PROJECT_PATH=$(CURDIR)/android

android-check:
ifndef JAVA_HOME
	$(error JAVA_HOME is missing. Set it to a valid JDK and try again)
endif
ifndef ANDROID_SDK_HOME
	$(error ANDROID_SDK_HOME is missing. Set it and try again)
endif
ifndef ANDROID_NDK_HOME
	$(error ANDROID_NDK_HOME is missing. Set it and try again)
endif
ifndef ANT_HOME
	$(error ANT_HOME is missing. Set it and try again)
endif

android-build: android-check
	@echo.
	@echo ===== Android Build =====
	@echo.
	$(call c-mkdir,$(ANDROID-BIN-DIR))
	$(ANDROID_NDK_HOME)/ndk-build -C android $(ANDROID-MAKEFLAGS)

android-deploy: android-build
	@echo.
	@echo ===== Android Deploy =====
	@echo.
	$(call c-rmr,$(DEPLOY-DIR))
	$(call c-mkdir,$(DEPLOY-DIR))
	$(ANDROID_SDK_HOME)/tools/android update project -p android -t 1
	$(ANT_HOME)/bin/ant $(config) -s android
	$(call c-cp,android/bin/Flow-$(config).apk,deploy)

android-install: android-deploy
	@echo.
	@echo ===== Android Install =====
	@echo.
	$(ANDROID_SDK_HOME)/platform-tools/adb install -r deploy/Flow-$(config).apk


android-run: android-install
	@echo.
	@echo ===== Android Run =====
	@echo.
	adb shell am start -n com.karrotwaltz.flow/.FlowActivity
	
android-clean: android-check
	$(ANDROID_NDK_HOME)/ndk-build -C android $(ANDROID-MAKEFLAGS) clean

.PHONY: purge
purge: clean em-clean android-clean
