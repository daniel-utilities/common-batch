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

# Config
HELP_INDENT := $(SPACE)$(SPACE)
HELP_TARGET_COL_WIDTH := ........................
HELP_VARN_COL_WIDTH := ........................

$(eval $(call set_helptext,help,\
  Prints the top-level Make targets available in this project,\
  Targets can define help text using the "set_helptext" macro.$(LF)\
  See "functions.mak" for more information.,\
  HELP_INDENT\
  HELP_TARGET_COL_WIDTH\
  HELP_VARN_COL_WIDTH\
))

# Definition
.PHONY: help
help:
	@$(call nop)
	$(info )
	$(info Usage:)
	$(info $(HELP_INDENT)make [target] [variable=value])
	$(info )
	$(info Targets:)
	$(foreach tgt,$(sort $(help_targets)),$(if $($(tgt).shortdesc),\
	  $(info $(HELP_INDENT)$(call rpad,$(patsubst help.%,%,$(tgt)),$(HELP_TARGET_COL_WIDTH)) $($(tgt).shortdesc))\
	))
	$(info )


#-------------------------------------------------------------------------------
# UPSTREAM: daniel-templates/template-project
#-------------------------------------------------------------------------------

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# TARGET: help.[target]
#   Prints detailed info about a specific target
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Config
$(eval $(call set_helptext,help.[target],\
  Prints detailed info about a specific target,\
  Targets can define help text using the "set_helptext" macro.$(LF)\
  See "functions.mak" for more information.,\
\
))

# Definition
.PHONY: help.%
help.%:
	@$(call nop)
	$(if $(filter $@,$(help_targets)),\
	  $(info )\
	  $(info Usage:)\
	  $(info $(HELP_INDENT)make $(patsubst help.%,%,$@) [variable=value])\
	  $(if $($@.shortdesc),\
	    $(info )\
	    $(info $(HELP_INDENT)$($@.shortdesc))\
	  )\
	  $(if $($@.longdesc),\
	    $(info )\
	    $(info $(HELP_INDENT)$(subst $(LF),$(LF)$(HELP_INDENT),$($@.longdesc)))\
	  )\
	  $(if $($@.variables),\
	    $(info )\
	    $(info $(call rpad,Variable:,$(HELP_VARN_COL_WIDTH))Value:)\
	    $(foreach varn,$(sort $($@.variables)),\
	      $(info $(HELP_INDENT)$(call rpad,$(varn),$(HELP_VARN_COL_WIDTH))$($(varn)))\
	    )\
	  )\
	  $(if $(strip $(foreach tgt,$(filter-out $@,$(help_targets)),$(if $(findstring $(patsubst help.%,%,$@),$(tgt)),$(tgt)))),\
	    $(info )\
	    $(info $(call rpad,Related Targets:,$(HELP_TARGET_COL_WIDTH))For more info, run "make help.[target]")\
	    $(foreach tgt,$(sort $(filter-out $@,$(help_targets))),\
	      $(if $(findstring $(patsubst help.%,%,$@),$(tgt)),\
	        $(info $(HELP_INDENT)$(call rpad,$(patsubst help.%,%,$(tgt)),$(HELP_TARGET_COL_WIDTH)) $($(tgt).shortdesc))\
	      )\
	    )\
	  )\
	  $(info )\
	,\
	  $(info )\
	  $(info No information available for target "$(patsubst help.%,%,$@)".)\
	  $(info )\
	)
