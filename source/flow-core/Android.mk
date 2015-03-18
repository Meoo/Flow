
ifndef SDL2_HOME
$(error SDL2_HOME is missing. Set it and try again)
endif

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := Flow

LOCAL_SRC_FILES := \
	$(SDL2_HOME)/src/main/android/SDL_android_main.c \
	main/AndroidMain.cpp

LOCAL_SHARED_LIBRARIES := SDL2

LOCAL_C_INCLUDES := $(SDL2_HOME)/include
LOCAL_LDLIBS := -lGLESv1_CM -lGLESv2 -llog

include $(BUILD_SHARED_LIBRARY)

# External lib : SDL2

include $(SDL2_HOME)/Android.mk
