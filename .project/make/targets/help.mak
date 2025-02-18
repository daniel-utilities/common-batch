#===============================================================================
# help.mak
#
# Prints information about the available Make commands for this project.
#
# Usage:
#   From project root directory, run "make help".
#
# Adding Help Text:
#   Add the following line:
#
#     $(eval $(call set_helptext,target,text))
#
#===============================================================================

# Top-level Target
.PHONY: help
help:
	$(info )


# Help text
$(eval $(call set_helptext,help, \
  Prints the top-level Make targets available in this project. \
))

#-------------------------------------------------------------------------------
# UPSTREAM: daniel-templates/template-project
#-------------------------------------------------------------------------------

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# TARGET: help_header
#   Header for the "make help" command
#   Add as a prerequisite for all "help_{target}" targets, so this prints first
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Definition
.PHONY: help_header
help_header:
	$(info )
	$(info Usage:)
	$(info $(INDENT)make [target] [variable=value])
	$(info )
	$(info Targets:)

