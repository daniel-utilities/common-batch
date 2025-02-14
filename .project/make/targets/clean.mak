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
# TARGET: clean_remove_tmp_directories
#   Deletes temporary directories and their contents
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clean: | clean_remove_tmp_directories

# Config
TMP_DIRS ?=

# Definition
.PHONY: clean_remove_tmp_directories
clean_remove_tmp_directories:
	$(PRINT_TRACE)
	$(foreach dir,$(TMP_DIRS),$(value RMDIR) "$(subst /,$(FILESEP),$(dir))" $(CMDSEP)) $(value NOP)

#-------------------------------------------------------------------------------
# UPSTREAM: (this project)
#-------------------------------------------------------------------------------


