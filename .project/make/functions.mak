#===============================================================================
# functions.mak
#===============================================================================

#-------------------------------------------------------------------------------
# UPSTREAM: daniel-templates/template_project
#-------------------------------------------------------------------------------

# Special Characters
define LF


endef

#### DEBUGGING
ifneq "$(SHOWTARGETS)" "false"
    define PRINT_TRACE
        $(info )
        $(info ======= Target:  $@  =======)
    endef
else
    PRINT_TRACE :=
endif

# If VERBOSE, show each command as its being run
ifneq ($(VERBOSE), true)
    V := @
endif


# filepath := $(call pathsearch,filename)
# Finds the first instance of a file in PATH
#
# Source: https://www.gnu.org/software/make/manual/html_node/Call-Function.html
#
PATHSEP ?= :
PATHSEARCH = $(firstword $(wildcard $(addsuffix /$(1),$(subst $(PATHSEP), ,$(PATH)))))

# newlist := $(call map,function,list)
# Applies the function to each element of the (space-separated) list
#
# Source: https://www.gnu.org/software/make/manual/html_node/Call-Function.html
#
MAP = $(foreach a,$(2),$(call $(1),$(a)))

#-------------------------------------------------------------------------------
# UPSTREAM: (this project)
#-------------------------------------------------------------------------------

