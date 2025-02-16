#===============================================================================
# config.mak
#
# Project configuration variables
#===============================================================================


#-------------------------------------------------------------------------------
# UPSTREAM: daniel-templates/template_project
#-------------------------------------------------------------------------------

DEFAULT_TARGET := all
CREATE_DIRS =
REMOVE_DIRS = $(CREATE_DIRS)

SOURCE_DIR  = src
GIT_CONFIG_FILE = .project/git/.gitconfig
GIT_HOOKS_DIR = .project/git/hooks

#-------------------------------------------------------------------------------
# UPSTREAM: (this project)
#-------------------------------------------------------------------------------


# CREATE_DIRS = tmp1/asdf1 tmp2/asdf2 tmp3/asdf3
# REMOVE_DIRS = tmp1 tmp2 tmp3
