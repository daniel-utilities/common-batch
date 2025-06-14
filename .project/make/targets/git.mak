#===============================================================================
# git.mak
#
# Quick access to common Git operations.
#
# Usage:
#   From project root directory, run "make git"
#
# Adding Prerequisites:
#   Define prereq targets at the end of this file.
#   For each prereq, redefine the parent target to add the prereq targets:
#
#     parent: prereq | prereq_orderonly
#
#   The top-level target runs if any of its "normal" prereqs are newer.
#   The top-level target ignores the timestamps of its "orderonly" prereqs;
#     they run if they need to, but won't force the top-level to update as well.
#   Targets should be .PHONY if they do not produce an actual file on the system.
#===============================================================================

# Config
$(eval $(call set_helptext,git,\
  Quick access to common Git operations.,\
  This is a standard top-level target.$(LF)\
  Projects can change the behavior of this target through$(LF)\
  two methods:$(LF)\
  $(LF)\
  1: define new targets and append them as prereqs$(LF)\
  _    (see git.mak for details)$(LF)\
  2: leverage existing prereqs by overwriting their variables$(LF)\
  _    (see Related Targets below),\
$(EMPTY)\
))

# Definition
.PHONY: git
git:
	$(PRINT_TRACE)


#-------------------------------------------------------------------------------
# UPSTREAM: daniel-templates/template-project
#-------------------------------------------------------------------------------

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# TARGET: git.gitconfig
#   Sets Git:include.patth to project .gitconfig
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Config
GIT_CONFIG_FILE ?= .project/git/.gitconfig
GIT_HOOKS_DIR ?= .project/git/hooks

$(eval $(call set_helptext,git.gitconfig,\
$(EMPTY),\
  Sets Git property "include.path" to GIT_CONFIG_FILE.$(LF)\
  Also sets executable on files in GIT_HOOKS_DIR.,\
  GIT_CONFIG_FILE\
  GIT_HOOKS_DIR\
))

# Definition
.PHONY: git.gitconfig
git.gitconfig:
#ifneq "$(shell git config --local --get include.path)" "../$(GIT_CONFIG_FILE)"
	$(PRINT_TRACE)
	git config --local include.path ../$(GIT_CONFIG_FILE)
	$(call chmod,--verbose u+x,$(GIT_HOOKS_DIR)/*)
#endif



#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# TARGET: git.gitignore
#   Untrack files identified in the repo's .gitignore.
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Config
$(eval $(call set_helptext,git.gitignore,\
$(EMPTY),\
  Untrack files identified in the repo's .gitignore.$(LF)\
  $(LF)\
  Modifies Git repo only. Local working tree is unaffected.$(LF)\
  $(LF)\
  If a file has already been committed to the repo$(COMMA) and$(LF)\
  is later added to .gitignore$(COMMA) the file remains in the$(LF)\
  repo until it is explicitly removed from tracking.$(LF)\
  $(LF)\
  This is equivalent to running:$(LF)\
  $(LF)\
  git rm -rf --cached .$(LF)\
  git add --all$(LF),\
$(EMPTY),\
))

# Definition
.PHONY: git.gitignore
git.gitignore:
	$(PRINT_TRACE)
	git rm -rf --cached .
	git add --all



#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# TARGET: git.attributes
#   Reencode files according to the repo's .gitattributes.
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Config
$(eval $(call set_helptext,git.gitattributes,\
$(EMPTY),\
  Reencode files according to the repo's .gitattributes.$(LF)\
  $(LF)\
  Modifies local files AND Git repo.$(LF)\
  $(LF)\
  When .gitattributes is changed, some files may not have$(LF)\
  the correct encoding or line ending format anymore.$(LF)\
  This removes$(COMMA) re-adds$(COMMA) and renormalizes all files$(LF)\
  in the repo$(COMMA) then hard-resets to update the working tree as well.$(LF)\
  $(LF)\
  This is equivalent to running:$(LF)\
  $(LF)\
  git add --renormalize .$(LF),\
  git rm -rf --cached .$(LF)\
  git reset --hard$(LF),\
$(EMPTY),\
))

# Definition
.PHONY: git.gitattributes
git.gitattributes:
	$(PRINT_TRACE)
	git add --renormalize .
	git rm -rf --cached .
	git reset --hard

#-------------------------------------------------------------------------------
# CURRENT PROJECT
#-------------------------------------------------------------------------------


