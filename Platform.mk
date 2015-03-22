
ifeq ($(OS),Windows_NT)
  HOST:=windows
else
  UNAME_S := $(shell uname -s)
  ifeq ($(UNAME_S),Linux)
    HOST:=linux
  endif
  ifeq ($(UNAME_S),Darwin)
    HOST:=osx
  endif
endif


ifdef ComSpec
  # Windows
  c-wpath = $(subst /,\,$1)
  c-wifexist = if exist $2 $1 $2
  c-wifnexist = if not exist $2 $1 $2
  c-copy-struct = xcopy /T $(call c-wpath,$1) $(call c-wpath,$2)

else
  # Unix
  c-copy-struct = cd $1 && find . -type d -exec mkdir -p -- $2/{} \;

endif

ifneq (sh,$(findstring sh,$(shell echo $$BASH)))
  # No shell (windows only)
  c-mkdir = $(foreach dir,$1,$(call c-wifnexist,mkdir,$(call c-wpath,$(dir))) &&)
  c-rm = $(foreach file,$1,$(call c-wifexist,erase /Q,$(call c-wpath,$(file))) &&)
  c-rmr = $(foreach file,$1,$(call c-wifexist,erase /S/Q,$(call c-wpath,$(file))) &&)
  c-cp = copy /B $(foreach item,$1,$(call c-wpath,$(item))) $(call c-wpath,$2)

else
  # Shell
  c-mkdir = mkdir -p -- $1
  c-rm = rm -f -- $1
  c-rmr = rm -rf -- $1
  c-cp = cp -- $1 $2

endif
