#===============================================================================
# system_map.mak
#
# Defines mappings between common shell commands and their platform-specific
# variations.
#
# Usage:
#
#   Include in makefile:
#
#     include .project/make/system_map.mak
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
endif
ifeq "$(OS_TYPE)" "UNIX"
    OS_FILESEP := /
    OS_PATHSEP := :
    EXEC_EXT :=
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
    ECHO := echo(
    NOP := 1>nul echo(
    CHMOD := $(NOP)
    LINE := echo(
    LS := dir /b
    MKDIR := mkdir
    RM := 2>nul del /f /q
    RMDIR := 2>nul rmdir /s /q
endif
ifeq "$(SHELL_TYPE)" "POWERSHELL"
    CMDSEP := ;
    ECHO := Write-Output
    NOP := ? .
    CHMOD := $(NOP)
    LINE := Write-Output ''
    LS := Get-ChildItem -Name
    MKDIR := New-Item -ItemType Directory -Force -Path
    RM := Remove-Item -Force -Path
    RMDIR := Remove-Item -Force -Recurse -Path
endif
ifeq "$(SHELL_TYPE)" "POSIX"
    CMDSEP := ;
    ECHO := echo
    NOP := :
    CHMOD := chmod
    LINE := echo ""
    LS := ls -A -1 --color=no
    MKDIR := mkdir -p
    RM := rm -f
    RMDIR := rm -rf
endif

$(info OS_TYPE:     $(OS_TYPE))
$(info SHELL_TYPE:  $(SHELL_TYPE))
$(info SHELL:       $(SHELL) $(.SHELLFLAGS))
