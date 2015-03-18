
FLOW-CORE-DIR := $(call my-dir)
FLOW-CORE-BIN := $(call my-bin-dir)

FLOW-CORE-EXE := $(FLOW-CORE-BIN)/flow.exe
FLOW-CORE-OBJS := $(FLOW-CORE-BIN)/main/VanillaMain.o

FLOW-CORE-CFLAGS := $(CXXFLAGS) -MMD $(SDL2-INC)
FLOW-CORE-LDFLAGS := $(LDFLAGS)

ifdef SDL2_HOME
  FLOW-CORE-CFLAGS += -I$(SDL2_HOME)/include
  FLOW-CORE-LDFLAGS += -L$(SDL2_HOME)/bin
endif

ifneq (,$(findstring mingw, $(shell gcc -dumpmachine)))
  FLOW-CORE-LDFLAGS += -lmingw32
endif

FLOW-CORE-LDFLAGS += -lopengl32 -lSDL2main -lSDL2

ifeq ($(HOST),windows)
  ifeq ($(CONFIG),release)
    FLOW-CORE-LDFLAGS += -mwindows
  endif
endif

# Many flags are required if SDL2 is static : -limm32 -lole32 -loleaut32 -luser32 -lgdi32 -lwinmm -lversion -luuid

$(FLOW-CORE-BIN)/%.o: $(FLOW-CORE-DIR)/%.cpp
	@echo CXX $< $(FLOW-CORE-DIR)
	$(CXX) -c -o $@ $< $(FLOW-CORE-CFLAGS)

$(FLOW-CORE-EXE): $(FLOW-CORE-OBJS)
	@echo LD $(notdir $@)
	$(CXX) -o $@ $^ $(FLOW-CORE-LDFLAGS)

clean-flow-core:
	$(call c-rm,$(FLOW-CORE-OBJS))
	$(call c-rm,$(FLOW-CORE-EXE))

FLOW-BUILD-DEPS += $(FLOW-CORE-EXE)
FLOW-CLEAN-DEPS += clean-flow-core

-include $($(FLOW-CORE-OBJS):.o=.d)
