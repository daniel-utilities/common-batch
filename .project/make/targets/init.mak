#===============================================================================
# init.mak
#
# Initializes this project's development environment.
#
# Usage:
#   From project root directory, run "make init"
#
# Adding Prerequisites:
#   Define prereq targets at the end of this file.
#   For each prereq, redefine the parent target to add the prereq targets:
#
#     parent: prereq | prereq_orderonly
#
#   The top-level target runs if any of its "normal" prereqs are newer.
#   The top-level target ignores the timestamps of its "orderonly" prereqs;
#     they run if they need to, but won't force the top-level to update as well.
#   Targets should be .PHONY if they do not produce an actual file on the system.
#===============================================================================

# Top-level Target
.PHONY: init
init:
	$(PRINT_TRACE)

#-------------------------------------------------------------------------------
# UPSTREAM: daniel-templates/template_project
#-------------------------------------------------------------------------------

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# TARGET: init_gitconfig
#   Configures Git include.path and makes all Git hooks executable
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init: | init_gitconfig

# Config
GIT_CONFIG_FILE ?= .project/git/.gitconfig
GIT_HOOKS_DIR ?= .project/git/hooks

# Definition
.PHONY: init_gitconfig
init_gitconfig:
ifneq "$(shell git config --local --get include.path)" "../$(GIT_CONFIG_FILE)"
	$(PRINT_TRACE)
	git config --local include.path ../$(GIT_CONFIG_FILE)
	@ $(CHMOD) --verbose u+x,g+x "$(subst /,$(FILESEP),$(GIT_HOOKS_DIR)/*)"
endif


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# TARGET: init_create_tmp_directories
#   Ensures various temporary directories exist
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init: | init_create_tmp_directories

# Config
TMP_DIRS ?=

# Definition
.PHONY: init_create_tmp_directories
init_create_tmp_directories: $(TMP_DIRS)

# Dynamically create a target for each path in TMP_DIRS
$(TMP_DIRS):
	$(eval $(subst $$@,init_create_tmp_directories:$$@,$(value PRINT_TRACE)))
	$(MKDIR) "$(subst /,$(FILESEP),$@)"


#-------------------------------------------------------------------------------
# UPSTREAM: (this project)
#-------------------------------------------------------------------------------


