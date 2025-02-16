#===============================================================================
# config.mak
#
# Project configuration variables
#===============================================================================

#-------------------------------------------------------------------------------
# UPSTREAM: daniel-templates/template_project
#-------------------------------------------------------------------------------

# Default Values
DEFAULT_TARGET := all

GIT_CONFIG_FILE = .project/git/.gitconfig
GIT_HOOKS_DIR = .project/git/hooks

# Project Directories
SOURCE_DIR = src
BUILD_DIR = build
LOG_DIR = logs

CREATE_DIRS =
REMOVE_DIRS = $(CREATE_DIRS)


#-------------------------------------------------------------------------------
# UPSTREAM: (this project)
#-------------------------------------------------------------------------------
# Overrides for this project

CREATE_DIRS = tmp1/asdf1 tmp2/asdf2 tmp3/asdf3
REMOVE_DIRS = tmp1 tmp2 tmp3
