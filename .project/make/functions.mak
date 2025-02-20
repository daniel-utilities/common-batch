#===============================================================================
# functions.mak
#===============================================================================

#-------------------------------------------------------------------------------
# UPSTREAM: daniel-templates/template-project
#-------------------------------------------------------------------------------

# Special Characters
EMPTY :=
SPACE := $(EMPTY) $(EMPTY)
TAB := $(EMPTY)	$(EMPTY)
COMMA := ,
PERCENT := %$(EMPTY)
BACKSLASH := \$(EMPTY)
POUND := \#
DOLLAR := $$
define LF


endef



# Debugging
ifneq "$(SHOWTARGETS)" "false"
    PRINT_TRACE = $(info $(LF)======= Target:  $@  =======)
else
    PRINT_TRACE :=
endif



# padded_str = $(call rpad,str,col)
# padded_str = $(call lpad,str,col)
# Pads str with whitespace so the total length is the same as col.
# Col is a sequence of "." to specify the column width.
# Example:
#   col := ..............................
#   str := Some Text
#   $(info [$(col)])                        [..............................]
#   $(info [$(str)])                        [Some Text]
#   $(info [$(call rpad,$(str),$(col))])    [Some Text                     ]
#   $(info [$(call lpad,$(str),$(col))])    [                     Some Text]
#
__pad_subst := a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 1 2 3 4 5 6 7 8 9 0 ! @ \# $$ ^ & * ( ) - _ + = [ ] { } | \ : ; " ' < , > . ? / ~ `
__pad_recurse = $(if $(strip $(1)),$(call __pad_recurse,$(filter-out $(firstword $(1)),$(1)),$(2),$(subst $(firstword $(1)),$(2),$(3))),$(3))
__pad_clear_if_eq = $(if $(subst $(2),,$(1)),$(1),)
rpad = $(if $(1),$(1)$(subst .,$(SPACE),$(call __pad_clear_if_eq,$(2:$(call __pad_recurse,$(__pad_subst),.,$(subst %,.,$(subst $(SPACE),.,$(1))))%=%),$(2))),$(subst .,$(SPACE),$(2)))
lpad = $(if $(1),$(subst .,$(SPACE),$(call __pad_clear_if_eq,$(2:$(call __pad_recurse,$(__pad_subst),.,$(subst %,.,$(subst $(SPACE),.,$(1))))%=%),$(2)))$(1),$(subst .,$(SPACE),$(2)))



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



# $(eval $(call set_helptext,target,\
# short description text, \
# $(HELP_INDENT)optional extended%(LF)\
# $(HELP_INDENT)multiline text\
# ))
# Defines a target "help.{target}" which prints a description of {target}.
# It will be automatically invoked with the command "make help".
#
define set_helptext
help_targets += help.$(strip $(1))
help.$(strip $(1)).shortdesc := $(strip $(2))
help.$(strip $(1)).longdesc := $(3)
.PHONY: help.$(strip $(1))
help.$(strip $(1)):
	$$(info )
	$$(info Usage:)
	$$(info $$(HELP_INDENT)$$(call rpad,$$(patsubst help.%,%,$$@),$$(HELP_TARGET_COL_WIDTH)) $$($$@.shortdesc))
	$$(info )
	$$(if $$($$@.longdesc),$$(info $$($$@.longdesc)$$(LF)))
endef


#-------------------------------------------------------------------------------
# UPSTREAM: (this project)
#-------------------------------------------------------------------------------

