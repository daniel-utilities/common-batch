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

#-------------------------------------------------------------------------------
# UPSTREAM: daniel-templates/template_project
#-------------------------------------------------------------------------------

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# TARGET: clean_git_rm_cached
#   Remove from the repository all files in the repo's .gitignore
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clean: | clean_git_rm_cached

# Config

# Definition
.PHONY: clean_git_rm_cached
clean_git_rm_cached:
	$(PRINT_TRACE)
	git rm -rf --cached . $(SILENT)
	git add *


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# TARGET: clean_remove_directories
#   Deletes one or more directories and their contents
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clean: | clean_remove_directories

# Config
REMOVE_DIRS ?=

# Definition
.PHONY: clean_remove_directories
.ONESHELL: clean_remove_directories
clean_remove_directories:
	$(PRINT_TRACE)
	$(foreach dir,$(REMOVE_DIRS),$(call RMDIR,$(subst /,$(FILESEP),$(dir))) $(LF))


#-------------------------------------------------------------------------------
# UPSTREAM: (this project)
#-------------------------------------------------------------------------------


