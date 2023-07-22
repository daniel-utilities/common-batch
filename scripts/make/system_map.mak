# system_map.mak


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

    # Detect shell type
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

    # Detect shell type
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

BACKSLASH := \$(strip)

ifeq "$(OS_TYPE)" "UNIX"
    SCRIPT_EXT := .sh
    EXEC_EXT :=
    FILESEP := /
    PATHSEP := :
endif
ifeq "$(OS_TYPE)" "WINDOWS"
    SCRIPT_EXT := .bat
    EXEC_EXT := .exe
    FILESEP := $(BACKSLASH)
    PATHSEP := ;
endif


#### MAP SHELL COMMANDS

ifeq "$(SHELL_TYPE)" "CMD"
    .SHELLFLAGS := /c
    CMDSEP := &
    NOP := call
    CHMOD := $(NOP)
    ECHO := echo
    LINE := echo.
    LS := dir /b
    MKDIR := mkdir
    RM := del /f /q
    RMDIR := rmdir /s /q
    SOURCE :=
endif
ifeq "$(SHELL_TYPE)" "POWERSHELL"
    .SHELLFLAGS := -NoProfile -Command
    CMDSEP := ;
    NOP := ? .
    CHMOD := $(NOP)
    ECHO := Write-Output
    LINE := Write-Output ''
    LS := Get-ChildItem -Name
    MKDIR := New-Item -ItemType Directory -Force -Path
    RM := Remove-Item -Force -Path
    RMDIR := Remove-Item -Force -Recurse -Path
    SOURCE :=
endif
ifeq "$(SHELL_TYPE)" "POSIX"
    .SHELLFLAGS := -c
    CMDSEP := ;
    NOP := :
    CHMOD := chmod
    ECHO := echo
    LINE := echo ""
    LS := ls -A -1 --color=no
    MKDIR := mkdir -p
    RM := rm -f
    RMDIR := rm -rf
    SOURCE := source
endif


$(info OS_TYPE:     $(OS_TYPE))
$(info SHELL_TYPE:  $(SHELL_TYPE))
$(info SHELL:       $(SHELL) $(.SHELLFLAGS))
