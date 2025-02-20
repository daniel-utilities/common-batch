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

# Help text
$(eval $(call set_helptext,init, \
  Initializes this project's development environment \
))

#-------------------------------------------------------------------------------
# UPSTREAM: daniel-templates/template-project
#-------------------------------------------------------------------------------

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# TARGET: init.git.gitconfig
#   Configures Git include.path and makes all Git hooks executable
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init: | init.git.gitconfig

# Config
GIT_CONFIG_FILE ?= .project/git/.gitconfig
GIT_HOOKS_DIR ?= .project/git/hooks

# Definition
.PHONY: init.git.gitconfig
init.git.gitconfig:
ifneq "$(shell git config --local --get include.path)" "../$(GIT_CONFIG_FILE)"
	$(PRINT_TRACE)
	git config --local include.path ../$(GIT_CONFIG_FILE)
	$(call chmod,--verbose u+x,$(GIT_HOOKS_DIR)/*)
endif


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# TARGET: init.create.dirs
#   Ensures various temporary directories exist
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init.create.dirs: | $(CREATE_DIRS)

# Config
CREATE_DIRS ?=

# Definition
.PHONY: init.create.dirs
init.create.dirs:
	$(PRINT_TRACE)

# Dynamically create a target for each path in CREATE_DIRS
# Set init.create.dirs as a prereq so PRINT_TRACE is run once before this group
$(CREATE_DIRS): | init.create.dirs
	$(call mkdir,$@)



#-------------------------------------------------------------------------------
# UPSTREAM: (this project)
#-------------------------------------------------------------------------------


