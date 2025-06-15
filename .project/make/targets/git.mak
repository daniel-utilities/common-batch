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
  _    (see Related Targets below)$(LF)\
  $(LF),\
$(EMPTY)\
))

# Definition
.PHONY: git
git: | help.git


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
  Sets Git property "include.path" to ../GIT_CONFIG_FILE.$(LF)\
  Also sets executable bit on files in GIT_HOOKS_DIR.$(LF)\
  $(LF),\
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
  This process is equivalent to running:$(LF)\
  $(LF)\
    git rm -rf --cached .$(LF)\
    git add --all$(LF)\
    git commit -m "GIT_COMMIT_MESSAGE"$(LF)\
  $(LF),\
  GIT_COMMIT_MESSAGE\
))

# Definition
.PHONY: git.gitignore
git.gitignore: | git.require.no-uncommitted-changes
	$(PRINT_TRACE)
	git rm -rf --cached .
	git add --all
	-git commit -m "$(GIT_COMMIT_MESSAGE)"



#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# TARGET: git.gitattributes
#   Reencode files according to the repo's .gitattributes.
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Config
GIT_COMMIT_MESSAGE ?= Renormalized files according to .gitattributes

$(eval $(call set_helptext,git.gitattributes,\
$(EMPTY),\
  Reencode files according to the repo's .gitattributes.$(LF)\
  $(LF)\
  Modifies local files AND Git repo.$(LF)\
  $(LF)\
  When .gitattributes is changed, some files may not have$(LF)\
  the correct encoding or line ending format anymore.$(LF)\
  This renormalizes and commits changes to all files in the repo$(COMMA)$(LF)\
  then hard-resets to that commit so these changes are reflected$(LF)\
  in the working-tree as well.$(LF)\
  $(LF)\
  This process is equivalent to running:$(LF)\
  $(LF)\
    git add --renormalize .$(LF),\
    git commit -m "GIT_COMMIT_MESSAGE"$(LF)\
    git rm -rf --cached .$(LF)\
    git reset --hard$(LF)\
  $(LF)\
  Be sure these changes are also reflected in .vscode/settings.all.json$(LF)\
  $(LF),\
  GIT_COMMIT_MESSAGE\
))

# Definition
.PHONY: git.gitattributes
git.gitattributes: | git.require.no-uncommitted-changes
	$(PRINT_TRACE)
	git add --update --renormalize .
	-git commit -m "$(GIT_COMMIT_MESSAGE)"
	git rm -rf --cached .
	git reset --hard




#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# TARGET: git.require.no-uncommitted-changes
#   Terminates make if repository contains unstaged or staged but uncommitted changes.
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Config
$(eval $(call set_helptext,git.require.no-uncommitted-changes,\
$(EMPTY),\
  Terminates make with an error message if repository contains$(LF)\
  unstaged changes$(COMMA) or staged but uncommitted changes.$(LF)\
  $(LF)\
  This process is equivalent to running:$(LF)\
  $(LF)\
    git add . && git diff --quiet && git diff --cached --quiet$(LF)\
  $(LF),\
$(EMPTY),\
))

# Definition
.PHONY: git.require.no-uncommitted-changes
git.require.no-uncommitted-changes:
	$(PRINT_TRACE)
	git add . && git diff --quiet && git diff --cached --quiet



#-------------------------------------------------------------------------------
# CURRENT PROJECT
#-------------------------------------------------------------------------------


