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

# Config
$(eval $(call set_helptext,init,\
  Initializes this project's development environment,\
  This is a standard top-level target.$(LF)\
  Projects can change the behavior of this target through$(LF)\
  two methods:$(LF)\
  $(LF)\
  1: define new targets and append them as prereqs$(LF)\
  _    (see init.mak for details)$(LF)\
  2: leverage existing prereqs by overwriting their variables$(LF)\
  _    (see Related Targets below),\
$(EMPTY)\
))

# Definition
.PHONY: init
init:
	$(PRINT_TRACE)



#-------------------------------------------------------------------------------
# UPSTREAM: daniel-templates/template-project
#-------------------------------------------------------------------------------

# External prereqs
init: | git.gitconfig


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# TARGET: init.create.dirs
#   Creates directories
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init: | init.create.dirs

# Config
CREATE_DIRS ?=

$(eval $(call set_helptext,init.create.dirs,\
$(EMPTY),\
  Creates each directory listed in CREATE_DIRS.,\
  CREATE_DIRS\
))

# Definition
.PHONY: init.create.dirs
init.create.dirs: | $(CREATE_DIRS)

# Create a target for each path in CREATE_DIRS
$(CREATE_DIRS): | init.create.dirs.pre
	$(call mkdir,$@)

# Pre-target, runs once before any number of $(CREATE_DIRS) targets
.PHONY: init.create.dirs.header
init.create.dirs.pre:
	$(info )
	$(info ======= init.create.dirs  =======)


#-------------------------------------------------------------------------------
# CURRENT PROJECT
#-------------------------------------------------------------------------------


