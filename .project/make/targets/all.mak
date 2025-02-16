#===============================================================================
# all.mak
#
# Initializes this project's development environment.
#
# Usage:
#   From project root directory, run "make all"
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
.PHONY: all
all:
	$(PRINT_TRACE)

#-------------------------------------------------------------------------------
# UPSTREAM: daniel-templates/template_project
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# UPSTREAM: (this project)
#-------------------------------------------------------------------------------


