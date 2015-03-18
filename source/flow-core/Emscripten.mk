
FLOW-CORE-DIR := $(call my-dir)
FLOW-CORE-BIN := $(call my-bin-dir)

FLOW-CORE-HTML := $(FLOW-CORE-BIN)/flow.html
FLOW-CORE-OBJS := $(FLOW-CORE-BIN)/main/EmscriptenMain.o

$(FLOW-CORE-BIN)/%.o: $(FLOW-CORE-DIR)/%.cpp
	@echo CXX $<
	$(CXX) $(CXXFLAGS) -s USE_SDL=2 -c -o $@ $<

$(FLOW-CORE-HTML): $(FLOW-CORE-OBJS)
	@echo LD $(notdir $@)
	$(CXX) $(CXXFLAGS) -s USE_SDL=2 -o $@ $^

clean-flow-core:
	$(call c-rm,$(FLOW-CORE-OBJS))

FLOW-BUILD-DEPS += $(FLOW-CORE-HTML)
FLOW-CLEAN-DEPS += clean-flow-core
