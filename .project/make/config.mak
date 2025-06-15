#===============================================================================
# config.mak
#
# Project configuration variables
#===============================================================================

#-------------------------------------------------------------------------------
# UPSTREAM: daniel-templates/template-project
#-------------------------------------------------------------------------------

# Default Values
DEFAULT_TARGET ?= help
DISABLE_IMPLICIT ?= true

GIT_CONFIG_FILE = .project/git/.gitconfig
GIT_HOOKS_DIR = .project/git/hooks

# Project Directories
SOURCE_DIR = src
BUILD_DIR = build
LOG_DIR = logs

CREATE_DIRS =
REMOVE_DIRS = $(CREATE_DIRS)


#-------------------------------------------------------------------------------
# CURRENT PROJECT
#-------------------------------------------------------------------------------
# Overrides for this project

