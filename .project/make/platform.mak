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
#     include .project/make/platform.mak
#
#   Run a platform-independent shell command:
#
#     files := $(shell $(LS) "*.c")
#
#   Create a platform-independent relative file path:
#
#     paths := $(subst /,$(FILESEP),./path/to/a/file)
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

BACKSLASH := \$(strip)

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


#### MAP SHELL COMMANDS
# Use with the above shell properties
# Most commands take a "quoted/path" as argument.
# Example:
#
#   $(MKDIR) $(subst /,$(FILESEP),./path/to/a/dir)
#

ifeq "$(SHELL_TYPE)" "CMD"
    CMDSEP := &
    SILENT := 1>nul
    TRUE = (call )
    FALSE = (call)
    ECHO = echo($(1)
    NOP = 1>nul echo(
    CHMOD = $(NOP)
    LINE = echo(
    LS = dir /b "$(1)"
    MKDIR = if not exist "$(1)\" ( mkdir "$(1)" )
    RM = if exist "$(1)" ( del /f /q "$(1)" )
    RMDIR = if exist "$(1)\" ( rmdir /s /q "$(1)" )
endif
ifeq "$(SHELL_TYPE)" "POWERSHELL"
    CMDSEP := ;
    SILENT :=
    TRUE =
    FALSE =
    ECHO = Write-Output '$(1)'
    NOP = ? .
    CHMOD = $(NOP)
    LINE = Write-Output ''
    LS = Get-ChildItem -Name '$(1)'
    MKDIR = New-Item -ItemType Directory -Force -Path '$(1)'
    RM = Remove-Item -Force -Path '$(1)'
    RMDIR = Remove-Item -Force -Recurse -Path '$(1)'
endif
ifeq "$(SHELL_TYPE)" "POSIX"
    CMDSEP := ;
    SILENT := > /dev/null
    TRUE = true
    FALSE = false
    ECHO = echo "$(1)"
    NOP = :
    CHMOD = chmod "$(1)"
    LINE = echo ""
    LS = ls -A -1 --color=no "$(1)"
    MKDIR = mkdir -p "$(1)"
    RM = rm -f "$(1)"
    RMDIR = rm -rf "$(1)"
endif







$(info OS_TYPE:     $(OS_TYPE))
$(info SHELL_TYPE:  $(SHELL_TYPE))
$(info SHELL:       $(SHELL) $(.SHELLFLAGS))
