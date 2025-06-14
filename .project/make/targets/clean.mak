#===============================================================================
# clean.mak
#
# Resets this project's development environment
#
# Usage:
#   From project root directory, run "make clean"
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
$(eval $(call set_helptext,clean,\
  Resets this project's development environment,\
  This is a standard top-level target.$(LF)\
  Projects can change the behavior of this target through$(LF)\
  two methods:$(LF)\
  $(LF)\
  1: define new targets and append them as prereqs$(LF)\
  _    (see clean.mak for details)$(LF)\
  2: leverage existing prereqs by overwriting their variables$(LF)\
  _    (see Related Targets below),\
$(EMPTY)\
))

# Definition
.PHONY: clean
clean:
	$(PRINT_TRACE)


#-------------------------------------------------------------------------------
# UPSTREAM: daniel-templates/template-project
#-------------------------------------------------------------------------------




#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# TARGET: clean.remove.dirs
#   Deletes directories
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clean: | clean.remove.dirs

# Config
REMOVE_DIRS ?=

$(eval $(call set_helptext,clean.remove.dirs,\
$(EMPTY),\
  Removes each directory listed in REMOVE_DIRS,\
  REMOVE_DIRS\
))

# Definition
.PHONY: clean.remove.dirs
clean.remove.dirs:
	$(PRINT_TRACE)
	$(foreach dir,$(REMOVE_DIRS),$(call rmdir,$(dir)) $(LF))


#-------------------------------------------------------------------------------
# CURRENT PROJECT
#-------------------------------------------------------------------------------


