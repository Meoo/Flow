
include Platform.mk


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
purge:
	$(call c-rmr,$(BIN-DIR) $(DEPLOY-DIR))
