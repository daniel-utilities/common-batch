@echo off
setlocal disabledelayedexpansion
echo.



exit /b 0

:: #############################################################################
:: #############################################################################

:cleanpath2
    setlocal enabledelayedexpansion
    for /f "tokens=* delims= " %%a in ("%~2") do set "cleanpath=%%a"
    for /f "tokens=* delims= " %%a in ("%cleanpath%") do set "cleanpath=%%a"
    for /l %%a in (1,1,31) do if "!str:~-1!"==" " set str=!str:~0,-1!
    (goto) 2>nul &  set "%~1=%cleanpath%" 2>nul * (call )

:: call :cleanpath PATH_VAR "path"      (Requires: :return)
:cleanpath
    setlocal enabledelayedexpansion
    call :trim input_path "%~2"
    if "%input_path:~-1%"=="\" (
        set "input_path=!input_path:~0,-1!"
    )
    if "%input_path:~-1%"=="/" (
        set "input_path=!input_path:~0,-1!"
    )
    call :return 0 %1="%input_path%"



:: call :basename BASENAME_VAR "path"   (Requires: :return)
:basename
    setlocal enabledelayedexpansion
    call :cleanpath input_path "%~2"
    for /F "delims=" %%i in ("%input_path%") do set "basename=%%~nxi"
    (goto) 2>nul & set "%~1=%basename%" 2>nul & (call )


:: call :basename_no_ext BASENAME_VAR "path"    (Requires: :return)
:basename_no_ext
    setlocal enabledelayedexpansion
    call :cleanpath input_path "%~2"
    for /F "delims=" %%i in ("%input_path%") do set "basename=%%~ni"
    (goto) 2>nul & set "%~1=%basename%" 2>nul & (call )


:: call :dirname DIRNAME_VAR "path"     (Requires: :return)
:dirname
    setlocal enabledelayedexpansion
    call :cleanpath input_path "%~2"
    for /F "delims=" %%i in ("%input_path%") do set "dirname=%%~dpi"
    (goto) 2>nul & set "%~1=%dirname%" 2>nul & (call )





:: call :get_relative_path "ROOTPATH" "SUBPATH" RELPATHV   (Requires: :return)
:get_relative_path
    setlocal enabledelayedexpansion
    set "rootpath=%~1"
    set "itempath=%~2"
    set "ret_var=%~3"
    call :str_starts_with "%itempath%" "%rootpath%" || exit /b 1
    call :str_length "%rootpath%" rootlen 
    set /a "start_idx=rootlen+1"
    set "relpath=!itempath:~%start_idx%!"
    endlocal & if "%ret_var%" neq "" (set %ret_var%=%relpath%) else echo %ret_var%
    exit /b 0


:: call :get_batch_file PATHV     (Requires: :return)
:get_batch_file
    setlocal DisableDelayedExpansion
    set "%~1=%~f0" || exit /b 1
    call :return 0 %~1





:: #############################################################################
:: #############################################################################

:: call :return [ERRORLEVEL] [VAR1] [VAR2] ...        (Requires: :pushv_popv, :dereference, :escape_for_pct_expansion)
::  Ends the caller's scope (function or script) and copys one or more variables to the caller's parent scope.
:return
    setlocal DisableDelayedExpansion & set "_exitcode_=%ERRORLEVEL%"
    set "_copyvars_=" & for /F "tokens=* delims=-0123456789 " %%a in ("%*") do set "_copyvars_=%%a"
    if not "%_copyvars_%"=="%*" set "_exitcode_=%1"
    set "_switchcmd_=(goto) 2>nul & (goto) 2>nul"
    call :pushv_popv _switchcmd_ _copyvars_ & if "%_exitcode_%"=="0" (call ) else (call)
    echo ERROR: Failed to :return 2>nul & exit /b 99
    
:: call :pushv_popv  "CMD"|CMDV  "VAR1 VAR2..."|VARLISTV    (Requires: :dereference, :escape_for_pct_expansion)
::  Saves some variables, runs a command, then restores the variables to their original values.
:pushv_popv
    setlocal EnableDelayedExpansion
    set ^"__LF__=^

^"& call :dereference __switchcmd__=%%%%1
    call :dereference __copyvars__=%%%%2
    for %%m in (EDE DDE) do set "__setcmd%%m__=(call )!__LF__!" & for %%v in (%__copyvars__%) do (
        set "%%v_%%m=!%%v!" & rem Store separately VAR_EDE and VAR_DDE
        call :escape_for_pct_expansion %%v_%%m %%m
        call :escape_for_pct_expansion %%v_%%m %%m & rem value will be %-expanded twice in the new scope!
        set "__setcmd%%m__=!__setcmd%%m__!set "%%v=!%%v_%%m!"!__LF__!" & rem __setcmdEDE__ and __setcmdDDE__
    )
    (goto) 2>nul &( %__switchcmd__%
                    if "!!"=="" ( %__setcmdEDE__% ) else ( %__setcmdDDE__% ) & rem Copy variables to new scope
                    for %%a in (%__copyvars__%) do if defined %%a ( rem Remove extra double-quotes from each value
                        setlocal EnableDelayedExpansion
                        for /F tokens^=*^ delims^=^ eol^= %%b in ("!%%a:""""="!"^
                        
                        ) do (  endlocal
                                set "%%a=%%b"
    )               )   ) & (call )



:: call :dereference VAR=REF || set "VAR=default value"     (Requires: :escape_for_pct_expansion)
::   Dereferences a variable, copying its value to VAR.
:dereference
    if "!!"=="" ( setlocal DisableDelayedExpansion & set "__mode__=EDE") else ( setlocal DisableDelayedExpansion & set "__mode__=DDE" )
    set "__dstv__=%~1" & if not defined __dstv__ exit /b 1
    (goto) 2>nul &( setlocal DisableDelayedExpansion
                    call set "__src__=%2"
                    set "%__dstv__%="
                    setlocal EnableDelayedExpansion
                    if defined __src__ (
                        if "!__src__:~1,-1!"==!__src__! (   rem PBV (Pass-by-value)
                            set "%__dstv__%=!__src__:~1,-1!"
                            if defined %__dstv__% set "%__dstv__%=!%__dstv__%:""="!"
                        ) else (                            rem PBR (Pass-by-reference)
                            for %%v in (!__src__!) do set "%__dstv__%=!%%v!"
                        )
                    )
                    call :escape_for_pct_expansion %__dstv__% %__mode__%
                    if defined %__dstv__% (
                       for /F tokens^=*^ delims^=^ eol^= %%a in ("!%__dstv__%:""="!"^

                       ) do (   endlocal & endlocal
                                set "%__dstv__%=%%a"
                                (call )
                       )
                    ) else (    endlocal & endlocal
                                set "%__dstv__%="
                                (call)
    )               )

:: call :escape_for_pct_expansion  VAR  DDE|EDE     (Requires: Nothing)
::   Modifies VAR such that "%VAR%" expands to "original contents of VAR" .
:escape_for_pct_expansion
    setlocal EnableDelayedExpansion
    set "var=%~1" & if not defined var exit /b 1
    set "mode=%~2" & if not "!mode!"=="EDE" set "mode=DDE" & rem Default to DDE
    set "val=!%var%!"
    if not defined val ( (goto) 2>nul & set "var=" & (call ) )
    set "val=!val:"=""!"
    goto :__escape_for_pct_expansion_in_%mode%
:__escape_for_pct_expansion_in_EDE
    set "valEDE=!val:^=^^^^!"
    set "valDDE=!val:^=^^!"
    (goto) 2>nul & if "!!"=="" ( rem (copying from EDE to EDE)
        set "%var%=%valEDE:!=^^^!%^!"
    ) else (                     rem (copying from DDE to EDE)
        set "%var%=%valDDE:!=^!%!"
    )
:__escape_for_pct_expansion_in_DDE
    set "valEDE=!val:^=^^!"
    set "valDDE=!val:^=^!"
    (goto) 2>nul & if "!!"=="" ( rem (copying from EDE to DDE)
        set "%var%=%valEDE:!=^!%!"
    ) else (                     rem (copying from DDE to DDE)
        set "%var%=%valDDE:!=!%"
    )
:: call :return [ERRORLEVEL] [VAR1] [VAR2] ...        (Requires: :pushv_popv, :dereference, :escape_for_pct_expansion)
::  Ends the caller's scope (function or script) and copys one or more variables to the caller's parent scope.
::  Params:
::      ERRORLEVEL: 0 (success), >= 1 (failure)
::              If not specified as a param, returns the current ERRORLEVEL of the caller's scope.
::      VARN:   Name of variable to create in the caller's environment.
::              Its value is copied from the local environment.
:return
    setlocal DisableDelayedExpansion & set "_exitcode_=%ERRORLEVEL%"
    set "_copyvars_=" & for /F "tokens=* delims=-0123456789 " %%a in ("%*") do set "_copyvars_=%%a"
    if not "%_copyvars_%"=="%*" set "_exitcode_=%1"
    set "_switchcmd_=(goto) 2>nul & (goto) 2>nul"
    call :pushv_popv _switchcmd_ _copyvars_ & if "%_exitcode_%"=="0" (call ) else (call)
    echo ERROR: Failed to :return 2>nul & exit /b 99
    