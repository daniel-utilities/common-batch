#===============================================================================
# Makefile
#===============================================================================

#### DEBUGGING
ifneq "$(SHOWTARGETS)" "false"
    PRINT_TRACE = @ $(LINE) $(CMDSEP) $(ECHO) '======== Target:  $@  ========' $(CMDSEP) $(LINE)
else
    PRINT_TRACE = @ $(LINE)
endif
ifneq ($(VERBOSE), true)
    V := @
endif


#### PROJECT PATHS
# Specify paths using '/', and subst $(FILESEP).
# Use delayed expansion '=' so FILESEP can be corrected later.
#   VAR = $(subst /,$(FILESEP),./path/to/a/file)
SOURCE_DIR  = $(subst /,$(FILESEP),./src)
IMPORTS_DIR = $(subst /,$(FILESEP),./.project/make)
INIT_SCRIPT = $(subst /,$(FILESEP),./.project/git/init$(SCRIPT_EXT))


#### IMPORTS
FILESEP := /
include $(IMPORTS_DIR)/system_map.mak


#### TARGETS

.PHONY: all
all: init
	$(PRINT_TRACE)


.PHONY: init
init:
ifneq "$(shell git config --local --get include.path)" "../.project/git/.gitconfig"
	$(PRINT_TRACE)
	$(V) $(INIT_SCRIPT)
endif
