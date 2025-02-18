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

# Machine-specific (untracked) configuration
include $(wildcard $(MAKE_DIR)/*.local.mak)

# Set default target
DEFAULT_TARGET ?= all
$(DEFAULT_TARGET):

# Target definitions
include $(wildcard $(MAKE_TARGETS_DIR)/*.mak)

# Machine-specific (untracked) target definitions
include $(wildcard $(MAKE_TARGETS_DIR)/*.local.mak)
