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
	$(info Usage:)
	$(info $(HELP_INDENT)make [target] [variable=value])
	$(info )
	$(info Targets:)
	$(foreach tgt,$(sort $(help_targets)),$(info $(HELP_INDENT)$(call rpad,$(patsubst help.%,%,$(tgt)),$(HELP_TARGET_COL_WIDTH)) $($(tgt).shortdesc)))
	$(info )

# Help text
$(eval $(call set_helptext,help, \
  Prints the top-level Make targets available in this project \
))

# Config
HELP_INDENT := $(SPACE)$(SPACE)
HELP_TARGET_COL_WIDTH := ........................


#-------------------------------------------------------------------------------
# UPSTREAM: daniel-templates/template-project
#-------------------------------------------------------------------------------

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# TARGET: help.header
#   Header for the "make help" command
#   Automatic prerequisite of all "help.{target}" targets, so it prints first
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Definition
.PHONY: help.header
help.header:
	$(info )
	$(info Usage:)
	$(info $(HELP_INDENT)make [target] [variable=value])
	$(info )
	$(info Targets:)

