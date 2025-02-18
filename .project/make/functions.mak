#===============================================================================
# functions.mak
#===============================================================================

#-------------------------------------------------------------------------------
# UPSTREAM: daniel-templates/template-project
#-------------------------------------------------------------------------------

# Special Characters
EMPTY :=
SPACE := $(EMPTY) $(EMPTY)
BACKSLASH := \$(strip)
INDENT := $(SPACE)$(SPACE)

define LF


endef


#### DEBUGGING
ifneq "$(SHOWTARGETS)" "false"
    PRINT_TRACE = $(info $(LF)======= Target:  $@  =======)
else
    PRINT_TRACE :=
endif


# $(eval $(call set_helptext,target,text))
# Defines a target "help_{target}" which prints a description of {target}.
# It will be automatically invoked with the command "make help".
#
define set_helptext
help: | help_$(strip $(1))
.PHONY: help_$(strip $(1))
help_$(strip $(1)): | help_header
	$$(info $$(INDENT)$(strip $(1)))
	$$(info $$(INDENT)$$(INDENT)$(strip $(2)))
endef



# filepath = $(call pathsearch,filename)
# Finds the first instance of a file in PATH
#
# Source: https://www.gnu.org/software/make/manual/html_node/Call-Function.html
#
PATHSEP ?= :
pathsearch = $(firstword $(wildcard $(addsuffix /$(1),$(subst $(PATHSEP), ,$(PATH)))))


# newlist = $(call map,function,list)
# Applies the function to each element of the (space-separated) list
#
# Source: https://www.gnu.org/software/make/manual/html_node/Call-Function.html
#
map = $(foreach a,$(2),$(call $(1),$(a)))


# str = $(call concat sep,list)
# Concatentates a list of strings with the given separator.
#
concat = $(subst ?,,$(subst ? ,$(1),$(foreach a,$(2) $(3) $(4) $(5) $(6) $(7) $(8) $(9),$(a)?)))


# mkpath = $(call mkpath,list)
# Concatenates a list of path segments into a single path.
# Corrects / and \ to $(FILESEP) in the final result.
#
FILESEP ?= /
mkpath = $(subst /,$(FILESEP),$(subst $(BACKSLASH),$(FILESEP),$(call concat,$(FILESEP),$(1),$(2),$(3),$(4),$(5),$(6),$(7),$(8))))


#-------------------------------------------------------------------------------
# UPSTREAM: (this project)
#-------------------------------------------------------------------------------

