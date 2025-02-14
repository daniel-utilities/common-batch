#===============================================================================
# makefile
#===============================================================================


#### DEBUGGING
ifneq "$(SHOWTARGETS)" "false"
    define PRINT_TRACE
        $(info )
        $(info ======= Target:  $@  =======)
    endef
else
    PRINT_TRACE = $(info )
endif

# If VERBOSE, show each command as its being run
ifneq ($(VERBOSE), true)
    V := @
endif


#### PROJECT PATHS
# Specify paths using '/', and subst $(FILESEP).
# Use delayed expansion '=' so FILESEP can be corrected later.
#   VAR = $(subst /,$(FILESEP),./path/to/a/file)
SOURCE_DIR  = src
MAKE_DIR = .project/make
MAKE_TARGETS_DIR = $(MAKE_DIR)/targets

#### IMPORTS
include $(MAKE_DIR)/system_map.mak
include $(MAKE_DIR)/config.mak

#### DEFAULT TARGET
.PHONY: all
all:
	$(PRINT_TRACE)

#### ADDITIONAL TARGETS
include $(wildcard $(MAKE_TARGETS_DIR)/*.mak)



