@echo off
setlocal DisableDelayedExpansion
set "args=%*" & if defined args goto :start
"%~f0"  /?  ""  un!quote!d  " !quote!d = ""with"" / spaces! "  /flag1  /flag2=un!quote!d  /flag3=" !quote!d = ""with"" / spaces! "
exit /b 0
:start

set "quote=ERROR"
set "argparse.HELP_HOOK=on_help_test"
set "args=%*"
set "BATCH_ARGS="
set "BATCH_ARGS[#]="
set "BATCH_PRGS="
set "BATCH_PRGS[#]="
set "BATCH_FLGS="
set "BATCH_FLGS[#]="
for /l %%i in (1,1,32) do set "BATCH_ARGS[%%i]="
for /l %%i in (1,1,32) do set "BATCH_PRGS[%%i]="
for /l %%i in (1,1,32) do set "BATCH_FLGS[%%i]="
set "flag1="
set "flag2="
set "flag3="
set "?="

setlocal EnableDelayedExpansion
echo.
echo ################################################
echo   Parsing Args String ^(into EDE^):
echo   %%*="!args!"
echo ################################################
echo.
endlocal

setlocal EnableDelayedExpansion
call :parse_args args

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
endlocal


setlocal EnableDelayedExpansion
echo.
echo ################################################
echo   Parsing Args String ^(into DDE^):
echo   %%*=!args!
echo ################################################
echo.
endlocal

setlocal EnableDelayedExpansion
call :parse_args args

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
endlocal

exit /b 0


:on_help_test
    echo.
    echo HELP FLAG DETECTED
    echo.
    exit /b 0


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
    set ^"__LF__=^

^"& set "__dst__=%~1" & if not defined __dst__ exit /b 1
    (goto) 2>nul & ( setlocal DisableDelayedExpansion
                     call set "%__dst__%=%2"
                     setlocal EnableDelayedExpansion
                     if defined %__dst__% ( for /F "tokens=* delims=" %%a in ("!%__dst__%:""="!"%__LF__%) do (
                         if "%%a"=="%%~a" ( set "%__dst__%=!%%a!" ) else ( set "%__dst__%=%%~a" )
                     ) )
                     call :escape_for_pct_expansion %__dst__% %__mode__%
                     if defined %__dst__% ( for /F "tokens=* delims=" %%a in ("!%__dst__%:""="!"%__LF__%) do (
                        endlocal & endlocal & set "%__dst__%=%%~a" & (call )
                     ) ) else (
                        endlocal & endlocal & set "%__dst__%=" & (call)
    )                )

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
