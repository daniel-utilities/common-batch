@call :batchinit & rem /throw.ERROR_HOOK=on_error_do_exit /exit.EXIT_HOOK=on_exit_do_nothing
:: -----------------------------------------------------------------------------
:: framework.bat
:: -----------------------------------------------------------------------------
setlocal EnableDelayedExpansion
:: call :require_elevated_privilege
:: call :require_nonelevated_privilege
:: -----------------------------------------------------------------------------
:start
:: -----------------------------------------------------------------------------

echo.
echo BATCH_FILENAME=!BATCH_FILENAME!
echo BATCH_FILE=!BATCH_FILE!
echo BATCH_DIR=!BATCH_DIR!
echo BATCH_WORKDIR=!BATCH_WORKDIR!
echo BATCH_STARTTIME=!BATCH_STARTTIME!
echo exit.EXIT_HOOK=!exit.EXIT_HOOK!
echo throw.ERROR_HOOK=!throw.ERROR_HOOK!
echo argparse.HELP_HOOK=!argparse.HELP_HOOK!
if defined BATCH_UNATTENDED echo BATCH_UNATTENDED=!BATCH_UNATTENDED!

echo.
echo TAB=[!TAB!]
echo  TAB=[!TAB!]
echo   TAB=[!TAB!]
echo    TAB=[!TAB!]

echo.
echo LF=[!LF!]
echo.
echo BATCH_ARGS ^(%BATCH_ARGS[#]% total^): !BATCH_ARGS!
for /l %%i in (1,1,%BATCH_ARGS[#]%) do echo   [%%i]=!BATCH_ARGS[%%i]!
echo.
echo BATCH_PRGS ^(%BATCH_PRGS[#]% total^): !BATCH_PRGS!
for /l %%i in (1,1,%BATCH_PRGS[#]%) do echo   [%%i]=!BATCH_PRGS[%%i]!
echo.
echo BATCH_FLGS ^(%BATCH_FLGS[#]% total^): !BATCH_FLGS!
for /l %%i in (1,1,%BATCH_FLGS[#]%) do (
    echo   [%%i]=!BATCH_FLGS[%%i]!
    call echo       !BATCH_FLGS[%%i]!=%%!BATCH_FLGS[%%i]!%%
)


:: -----------------------------------------------------------------------------
:end
:: -----------------------------------------------------------------------------
call :exit 0 & rem Optional: Append list of variables to return.
goto :EOF



:: -----------------------------------------------------------------------------
:: CALLBACKS
:: -----------------------------------------------------------------------------

:: call :on_help
:: Default help callback handler. Called by:  call :parse_args
::   Change by setting: argparse.HELP_HOOK
:on_help
    setlocal DisableDelayedExpansion
    echo.
    echo Usage:
    echo %BATCH_FILENAME% /?
    echo   Shows this help text.
    echo.
    set "exit.EXIT_HOOK="
    call :exit 0


:: call :on_error_do_exit
:: Default error callback handler. Called by:  call :throw
::   Change by setting: throw.ERROR_HOOK
:on_error_do_exit
    setlocal DisableDelayedExpansion
    call :exit 1

:: call :on_error_do_nothing
:on_error_do_nothing
    setlocal DisableDelayedExpansion
    call :return 1


:: call :on_exit_do_nothing
:: Default exit callback handler. Called by:  call :exit
::   Change by setting: exit.EXIT_HOOK
:on_exit_do_nothing
    setlocal DisableDelayedExpansion
    cd /d "%BATCH_WORKDIR%" >nul 2>&1
    if not defined BATCH_UNATTENDED pause
    call :return 0


:: -----------------------------------------------------------------------------
:: UTILITIES
:: -----------------------------------------------------------------------------



:: -----------------------------------------------------------------------------
:: FRAMEWORK (DO NOT EDIT)
:: -----------------------------------------------------------------------------

:: @call :batchinit
:batchinit
    @(goto) 2>nul & (
        setlocal DisableDelayedExpansion
        set  BATCH_STARTTIME=%TIME%
        echo off
        set  ERRORLEVEL=
        set ^"LF=^

^" 2>nul & rem The formatting of the above two lines are critical. DO NOT MODIFY
        ((for /L %%P in (1,1,70) do pause>nul)&set /p "TAB=")<"%COMSPEC%" & call set "TAB=%%TAB:~0,1%%"
        set "BATCH_FILENAME=%~nx0"
        set "BATCH_FILE=%~f0"
        set "BATCH_DIR=%~dp0" & call set "BATCH_DIR=%%BATCH_DIR:~0,-1%%"
        set "BATCH_WORKDIR=%CD%"
        set "exit.EXIT_HOOK=on_exit_do_nothing"
        set "throw.ERROR_HOOK=on_error_do_exit"
        set "argparse.HELP_HOOK=on_help"
        echo %CMDCMDLINE%|find /i """%~f0""">nul || set "BATCH_UNATTENDED=y"
        call set "BATCH_ARGS=%* %%*"
        call :parse_args BATCH_ARGS
    )

:: call :require_elevated_privilege
::   Checks the script is running with Administrator (elevated) privilege, else exits with an error.
:require_elevated_privilege
    setlocal DisableDelayedExpansion
    net file >nul 2>&1 || (
        set "exit.EXIT_HOOK="
        call :throw "Script '%BATCH_FILE%' must be run with Administrator [elevated] privilege."
        call :exit 1
    )
    call :return 0

:: call :require_nonelevated_privilege
::   Checks the script is running with User (nonelevated) privilege, else exits with an error.
:require_nonelevated_privilege
    setlocal DisableDelayedExpansion
    net file >nul 2>&1 && (
        set "exit.EXIT_HOOK="
        call :throw "Script '%BATCH_FILE%' must be run with User [nonelevated] privilege."
        call :exit 1
    )
    call :return 0

:: call :parse_args ARGSV           (Requires: :return, :pushv_popv, :dereference, :escape_for_pct_expansion)
:parse_args
    setlocal EnableDelayedExpansion
    set "__argsv__=%1" & if defined __argsv__ ( set "__args__=!%1!" ) else ( exit /b 1 )
    call :escape_for_pct_expansion __args__ EDE
    call :escape_for_pct_expansion __args__ EDE & rem string will be %-expanded twice
    set "BATCH_ARGS=" & set "BATCH_ARGS[#]=0" & set "__outv__=           BATCH_ARGS BATCH_ARGS[#]"
    set "BATCH_PRGS=" & set "BATCH_PRGS[#]=0" & set "__outv__=%__outv__% BATCH_PRGS BATCH_PRGS[#]"
    set "BATCH_FLGS=" & set "BATCH_FLGS[#]=0" & set "__outv__=%__outv__% BATCH_FLGS BATCH_FLGS[#]"
    set "__tok__=" & for %%L in (^"^

^") do for /F "tokens=* delims=" %%t in ("!__args__: =%%~L !") do (
        set "__tok__=!__tok__!%%t" & set "__arg__= !__tok__:""""="!"
        set "__n=-1" & for /F "tokens=* delims=" %%n in (^"!__arg__:^"^=^"^%%~L!^ ^") do set /A "__n+=1"
        set /a "__m=__n%%2" & if !__m! EQU 0 ( set "__tok__=" & rem Arg is incomplete if it contains an odd number of " quotes
            for /F "tokens=* delims= " %%a in ("!__arg__!") do (
                for /F "tokens=* delims=/ " %%b in ("!__arg__!") do (
                    for /F "tokens=1,* delims=/= " %%c in ("!__arg__!") do (  rem Arg is incomplete if only whitespace, =, /
                        set "__arg__=%%a" & set "__prg__=%%b" & set "__flg__=%%c" & set "__val__=%%d"
                        set "__ref__="& set "__name__=" & set "__value__="
                        if defined __arg__ (
                            set /A "BATCH_ARGS[#]+=1"
                            set "BATCH_ARGS[!BATCH_ARGS[#]!]=!__arg__!"
                            set "BATCH_ARGS=!BATCH_ARGS! !__arg__!"
                            if "!__arg__!"=="!__prg__!" ( set /A "BATCH_PRGS[#]+=1" & rem Positional arg
                                set "__ref__="
                                set "__name__=BATCH_PRGS[!BATCH_PRGS[#]!]"
                                set "__value__=!__prg__!"
                                set "BATCH_PRGS=!BATCH_PRGS! !__value__!"
                            ) else if "!__flg__!"=="?" (
                                if defined argparse.HELP_HOOK call :%argparse.HELP_HOOK%
                            ) else ( set /A "BATCH_FLGS[#]+=1" & rem Flag arg
                                set "__ref__=BATCH_FLGS[!BATCH_FLGS[#]!]"
                                set "__name__=!__flg__!"
                                set "__value__=!__val__!"
                                set "BATCH_FLGS=!BATCH_FLGS! !__name__!"
                            )
                            if defined __value__ if "!__value__:~0,1!"==^""" set "__value__=!__value__:~1,-1!"
                            if defined __value__ set "__value__=!__value__:""="!"
                            if defined __name__ set "!__name__!=!__value__!"
                            if defined __ref__ set "!__ref__!=!__name__!"
                            set "__outv__=!__outv__! BATCH_ARGS[!BATCH_ARGS[#]!] !__ref__! !__name__!"
    )   )   )   )   )   )
    call :return 0 %__outv__%

:: call :throw ["error message"]
::  Prints an error message, then calls throw.ERROR_HOOK.
:throw
    (goto) 2>nul & (
        setlocal DisableDelayedExpansion
        call echo   --[ %%~0 ]-- 1>&2
        if "%~1"=="" ( echo ERROR: A critical error has occurred. 1>&2
        ) else (       echo ERROR: %~1 1>&2 )
        if defined throw.ERROR_HOOK call :%throw.ERROR_HOOK%
        endlocal
    ) & (call)

::  call :return [ERRORLEVEL] [VARNAME] [VARNAME=localvarname] ...      (Requires: LF, CR)
::      Ends the caller's scope (function or script) and copies one or more variables to the caller's parent scope.
::
::  call :exit [ERRORLEVEL] [VARNAME] [VARNAME=localvarname] ...        (Requires: :return, LF, CR)
::      Calls %exit.EXIT_HOOK% (if defined), then exits this script.
::      Returns one or more variables to the parent script.
::
:return [ERRORLEVEL] [VARNAME] [VARNAME=localvarname] ...
    setlocal EnableDelayedExpansion & set "return.err=%ERRORLEVEL%"
    set "return.DDE.setcmd=(call )" & set "return.EDE.setcmd=(call )"
    if not defined return.switch_context.cmd set "return.switch_context.cmd=(goto) 2>nul"
    set "return.args=%*" & if not defined return.args goto :return.switch_context
    for %%L in ("!LF!") do for %%R in ("!CR!") do (
        for /f "tokens=1* delims==" %%a in ("!return.args: =%%~L!") do (
            set "return.var=" & set "return.DDE=" & set "return.EDE="
            for /f "tokens=1 delims=-0123456789" %%# in ("%%~a") do ( rem Arg is VARNAME or VARNAME=PASSBYREFERENCE
                set "return.var=%%~a"
                if "%%~b"=="" ( set "return.DDE=!%%~a!" ) else ( set "return.DDE=!%%~b!" )
                if defined return.DDE ( rem Escape special characters and append to setcmd
                    set "return.DDE=!return.DDE:%%=%%3!"
                    set "return.DDE=!return.DDE:"=%%4!"
                    set "return.DDE=!return.DDE:%%~L=%%~1!"
                    set "return.DDE=!return.DDE:%%~R=%%2!"
                    set "return.EDE=!return.DDE:^=^^^^!"
                    call :return.EDE.escape_exclamations
                )
                set "return.DDE.setcmd=!return.DDE.setcmd!&set "!return.var!=!return.DDE!"^!"
                set "return.EDE.setcmd=!return.EDE.setcmd!&set "!return.var!=!return.EDE!"^!"
            )
            if not defined return.var set /A "return.err=%%~a"  & rem Arg is an integer; set errorlevel
        )
    )
    goto :return.switch_context
:return.EDE.escape_exclamations
    set "return.EDE=%return.EDE:!=^^^!%" !
    exit /b
:return.switch_context
    for %%1 in ("!LF!") do for /f "tokens=1-3" %%2 in (^"!CR! %% "") do (
        (goto) 2>nul
        %return.switch_context.cmd%
        if "^!^" EQU "^!" (%return.EDE.setcmd%) else %return.DDE.setcmd%
        if %return.err% EQU 0 (call ) else if %return.err% equ 1 (call) else cmd /c exit %return.err%
    )

:exit [ERRORLEVEL] [VARNAME] [VARNAME=localvarname] ...
    if defined exit.EXIT_HOOK call :%exit.EXIT_HOOK%
    set "return.switch_context.cmd=call :exit.end_call_stack & (goto) 2>nul"
    goto :return
:exit.end_call_stack
    ( (goto) & (goto) & (
        setlocal DisableDelayedExpansion
        call set "caller=%%~0"
        setlocal EnableDelayedExpansion
        if "!caller:~0,1!"==":" call :exit.end_call_stack
        endlocal & endlocal
    ) ) 2>nul

