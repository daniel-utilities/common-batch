#===============================================================================
# platform.mak
#
# Defines mappings between common shell commands and their platform-specific
# variations.
#
# Usage:
#
#   Include in makefile:
#
#     include .project/make/functions.mak
#     include .project/make/platform.mak
#
#   Run a platform-independent shell command in a target definition block:
#
#     $(call mkdir,path/to/dir)
#
#   Run a shell command and store the output in a variable:
#
#     files := $(shell $(call ls,*.c))
#
#===============================================================================


#### SHELL PREFERENCES

CMD := cmd.exe
POWERSHELL := powershell.exe
SH := /bin/sh
BASH := /usr/bin/env bash
PWSH := /usr/bin/env pwsh

WINDOWS_SHELL_PREFERENCE := $(CMD)
UNIX_SHELL_PREFERENCE := $(BASH)


#### DETECT OS

## Windows
ifeq "$(OS)" "Windows_NT"
    OS_TYPE := WINDOWS

## UNIX-like (Linux, BSD, etc)
else
    OS_TYPE := UNIX
endif


#### DETECT SHELL

## Windows Shells
ifeq "$(SHLVL)" ""
    # Apply Windows shell preference
    SHELL := $(WINDOWS_SHELL_PREFERENCE)

    # Detect Windows shell type
ifeq "$(findstring powershell, $(SHELL))" "powershell"
    SHELL_TYPE := POWERSHELL
else
ifeq "$(findstring pwsh, $(SHELL))" "pwsh"
    SHELL_TYPE := POWERSHELL
else
ifeq "$(findstring cmd, $(SHELL))" "cmd"
    SHELL_TYPE := CMD
else  # Default
    SHELL_TYPE := CMD
endif
endif
endif

## UNIX Shells
else
    # Apply UNIX shell preference
    SHELL := $(UNIX_SHELL_PREFERENCE)

    # Detect UNIX shell type
ifeq "$(findstring pwsh, $(SHELL))" "pwsh"
    SHELL_TYPE := POWERSHELL
else
ifeq "$(findstring bash, $(SHELL))" "bash"
    SHELL_TYPE := POSIX
else
ifeq "$(findstring sh, $(SHELL))" "sh"
    SHELL_TYPE := POSIX
else  # Default
    SHELL_TYPE := POSIX
endif
endif
endif

endif


#### MAP OS PROPERTIES
# Apply when expanding environment variables in Make or interacting directly with the OS

BACKSLASH ?= \$(strip)

ifeq "$(OS_TYPE)" "WINDOWS"
    OS_FILESEP := $(BACKSLASH)
    OS_PATHSEP := ;
    EXEC_EXT := .exe
    LIB_EXT := .lib
    DLL_EXT := .dll
endif
ifeq "$(OS_TYPE)" "UNIX"
    OS_FILESEP := /
    OS_PATHSEP := :
    EXEC_EXT :=
    LIB_EXT := .a
    DLL_EXT := .so
endif


#### MAP SHELL PROPERTIES
# Apply when running shell commands or shell scripts from Make

ifeq "$(SHELL_TYPE)" "CMD"
    .SHELLFLAGS := /c
    FILESEP := $(BACKSLASH)
    PATHSEP := ;
    SCRIPT_EXT := .bat
endif
ifeq "$(SHELL_TYPE)" "POWERSHELL"
    .SHELLFLAGS := -NoProfile -Command
    FILESEP := $(BACKSLASH)
    PATHSEP := ;
    SCRIPT_EXT := .ps1
endif
ifeq "$(SHELL_TYPE)" "POSIX"
    .SHELLFLAGS := -c
    FILESEP := /
    PATHSEP := :
    SCRIPT_EXT := .sh
endif


#### SHELL COMMANDS
# Path arguments can be specified with "/" or "\" and will be automatically corrected for the platform.
#
# $(call true)                       Sets the shell command's exit code to true/success
# $(call false)                      Sets the shell command's exit code to false/failure
# $(call nop)                        Runs a shell command which does nothing. Useful for suppressing "Nothing to be done for target" messages.
# $(call echo,{string})              Prints the string
# $(call line)                       Print an empty line
# $(call ls,{path})                  Lists files under the given path
# $(call chmod,{args},{path})        Standard POSIX chmod. Calls "nop" on non-posix systems.
# $(call mkdir,{path})               Creates the directory, if it doesn't already exist.
# $(call rm,{path})                  Deletes a file, if it exists.
# $(call rmdir,{path})               Deletes a directory, if it exists.
# $(call copy,{src},{dst})           Copies {src} file to {dst}.
#                                      If {dst} does not exist, creates new file {dst}.
#                                      If {dst} is a file, overwrites.
#                                      If {dst} is a directory, creates new file {dst}/basename({src})
# $(call copydir,{src},{dst})        Copies {src} directory and its contents to {dst}.
#                                      If {dst} does not exist, creates new directory {dst}.
#                                      If {dst} is a directory, copies the CONTENTS of {src} into {dst}, overwriting files as necessary.
#

ifeq "$(SHELL_TYPE)" "CMD"
    CMDSEP := &
    SILENT := 1>nul
    true = (call )
    false = (call)
    nop = echo(1>nul
    echo = echo($(1)
    line = echo(
    ls = dir /b "$(call mkpath,$(1))"
    chmod = $(NOP)
    mkdir = if not exist "$(call mkpath,$(1))\" ( mkdir "$(call mkpath,$(1))" )
    rm = if exist "$(call mkpath,$(1))" ( del /f /q "$(call mkpath,$(1))" )
    rmdir = if exist "$(call mkpath,$(1))\" ( rmdir /s /q "$(call mkpath,$(1))" )
    copy = xcopy /Y /I /-I "$(call mkpath,$(1))" "$(call mkpath,$(2))"
    copydir = xcopy /Y /I /E "$(call mkpath,$(1))" "$(call mkpath,$(2))"
endif
ifeq "$(SHELL_TYPE)" "POWERSHELL"
    CMDSEP := ;
    SILENT :=
    true =
    false =
    nop = ? .
    echo = Write-Output '$(1)'
    line = Write-Output ''
    ls = Get-ChildItem -Name '$(call mkpath,$(1))'
    chmod = $(NOP)
    mkdir = New-Item -ItemType Directory -Force -Path '$(call mkpath,$(1))'
    rm = Remove-Item -Force -Path '$(call mkpath,$(1))'
    rmdir = Remove-Item -Force -Recurse -Path '$(call mkpath,$(1))'
    copy =
    copydir =
endif
ifeq "$(SHELL_TYPE)" "POSIX"
    CMDSEP := ;
    SILENT := > /dev/null
    true = true
    false = false
    nop = :
    echo = echo "$(1)"
    line = echo ""
    ls = ls -A -1 --color=no "$(call mkpath,$(1))"
    chmod = chmod $(1) "$(call mkpath,$(2))"
    mkdir = mkdir -p "$(call mkpath,$(1))"
    rm = rm -f "$(call mkpath,$(1))"
    rmdir = rm -rf "$(call mkpath,$(1))"
    copy = cp -f "$(call mkpath,$(1))" "$(call mkpath,$(2))"
    copydir = cp -rf "$(call mkpath,$(1))/." "$(call mkpath,$(2))"
endif


#$(info OS_TYPE:     $(OS_TYPE))
#$(info SHELL_TYPE:  $(SHELL_TYPE))
#$(info SHELL:       $(SHELL) $(.SHELLFLAGS))
