#===============================================================================
# makefile
#
# Minimal makefile which can be extended and specialized on a per-project basis
# by adding additional makefiles to the MAKE_DIR
#===============================================================================

# Import paths
MAKE_DIR = .project/make
MAKE_TARGETS_DIR = $(MAKE_DIR)/targets

# Basic functions
include $(MAKE_DIR)/functions.mak

# Platform-specific definitions
include $(MAKE_DIR)/platform.mak

# Project-specific configuration
include $(MAKE_DIR)/config.mak

# Set default target
DEFAULT_TARGET ?= all
$(DEFAULT_TARGET):

# Import additional targets
include $(wildcard $(MAKE_TARGETS_DIR)/*.mak)
