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

# Top-level Target
.PHONY: clean
clean:
	$(PRINT_TRACE)

# Help text
$(eval $(call set_helptext,clean, \
  Resets this project's development environment \
))

#-------------------------------------------------------------------------------
# UPSTREAM: daniel-templates/template-project
#-------------------------------------------------------------------------------

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# TARGET: clean.git.rm-cached
#   Untrack all files in the repo's .gitignore
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clean: | clean.git.rm-cached

# Config

# Definition
.PHONY: clean.git.rm-cached
clean.git.rm-cached:
	$(PRINT_TRACE)
	git rm -rf --cached --quiet .
	git add --all

# Help text
$(eval $(call set_helptext,clean.git.rm-cached, \
  Untrack all files in the repo's .gitignore \
))


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# TARGET: clean.remove.dirs
#   Deletes one or more directories
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clean: | clean.remove.dirs

# Config
REMOVE_DIRS ?=

# Definition
.PHONY: clean.remove.dirs
.ONESHELL: clean.remove.dirs
clean.remove.dirs:
	$(PRINT_TRACE)
	$(foreach dir,$(REMOVE_DIRS),$(call rmdir,$(dir)) $(LF))

# Help text
$(eval $(call set_helptext,clean.remove.dirs, \
  Deletes one or more directories \
))


#-------------------------------------------------------------------------------
# UPSTREAM: (this project)
#-------------------------------------------------------------------------------


