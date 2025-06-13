@echo off
setlocal DisableDelayedExpansion


echo.
set "SKIP_EMPTY_TOKENS=false"
set "list=item1;"item 2";;;"%%notexpanded%%";"
set "cmd=call echo  [%%_num%%]: %%_utok%%"
set list
echo Echoing list using pass-by-reference args:
call :foreach _num list ";" cmd
echo Returned:
echo _num=%_num%
echo.


echo.
set "SKIP_EMPTY_TOKENS=true"
set "list=item1;"item 2";;;"%%notexpanded%%";"
set "cmd=call echo  [%%_num%%]: %%_utok%%"
set list
echo Echoing list using pass-by-reference args ^(skipping empty tokens^):
call :foreach _num list ";" cmd
echo Returned:
echo _num=%_num%
echo.


echo.
set "SKIP_EMPTY_TOKENS=false"
set "list=item1;"item 2";;;"%%notexpanded%%";"
set list
echo Echoing list using pass-by-reference args ^(no cmd specified^):
call :foreach _num list ";"
echo Returned:
echo _num=%_num%
echo.


echo.
set "SKIP_EMPTY_TOKENS=false"
set "list=item1;""item 2"";;;""%%%%notexpanded%%%%"";"
set "cmd=call echo  [%%%%_num%%%%]: %%%%_utok%%%%"
set list
echo Echoing list using pass-by-value args:
call :foreach _num "%list%" ";" "%cmd%"
echo Returned:
echo _num=%_num%
echo.


echo.
set "SKIP_EMPTY_TOKENS=true"
set "list=previous list"
set "newitems=%%pct%% !exc!   "quotes" ^ & | [ ] ( ) < >"
set "cmd=call set "list=%%list%%, %%_tok%%" & call echo list="%%list%%""
set list
set newitems
echo Appending new items to list...
call :foreach list newitems " " cmd
echo Returned:
echo list="%list%"
echo.

exit /b 0


    


:: call :foreach  OUTV|"outv list"  LSTV|"list"  SEPV|"sep"  [CMDV|"cmd"]   (Requires: :return, :pushv_popv, :dereference, :escape_for_pct_expansion)
::   Splits a list into tokens using a SEP string, then runs command CMD on each token.
::   
::   OUTV: List of variables to return to the parent call context.
::         Variable name (unquoted) or "quoted list of variable names".
::         o Internal variable _num contains the total number of tokens.
::         o Can define new variables in command (CMD) and return them using OUTV.
::   LSTV: String to tokenize.
::         Variable name (unquoted) OR "double quoted value".
::   SEP:  String or character to split LIST.
::         Variable name (unquoted) OR "double quoted value".
::   CMD:  Command to run on each token. Runs with delayed expansion DISABLED.
::         Variable name (unquoted) OR "double quoted value".
::         Referencing variables:
::         o Tokens (quoted and unquoted):
::             ... %%t %%~t ...                (when not preceded by "call")
::             call ... %%_tok%% %%_utok%% ... (when inside a "call" body)
::         o Number of tokens (updated each loop):
::             call ... %%_num%% ...
::         o Other variables (external or local):
::             call ... %%var%%
::         Run a function each loop:
::             call :functionname ARGS
::   
::   The following :foreach calls have the same result:
::     Using Pass-by-reference variables:
::     o Escape  %  as  %%
::     o Escape  ^  as  ^^  (only for EnableDelayedExpansion)
::
::       set "list=item1;"item 2";"%%notexpanded%%""
::       set "cmd=call echo  [%%_num%%]: %%_utok%%"
::       call :foreach _num list ";" cmd
::
::     Using Pass-by-value args:
::     o Escape  %  as  %%%%
::     o Escape  "  as  ""
::
::       set "list=item1;""item 2"";""%%%%notexpanded%%%%"""
::       set "cmd=call echo  [%%%%_num%%%%]: %%%%_utok%%%%"
::       call :foreach _num "%list%" ";" "%cmd%"
::
:foreach
    setlocal DisableDelayedExpansion & set "_localdepth=0"
    set "_num=0"
    set "_out=%~1"
    call :dereference _lst=%%%%2 || call :return %_out%
    call :dereference _sep=%%%%3
    call :dereference _cmd=%%%%4 || set "_cmd=echo(%%t"
    setlocal EnableDelayedExpansion & set /A "_localdepth+=1"
    if defined _sep for %%L in (^"^

^") do set "_lst="!_lst:%_sep%="%%~L"!"" & rem The formatting of the above two lines are critical. DO NOT REMOVE
    for /F "tokens=* delims=" %%t in (^"!_lst!^") do (
        setlocal EnableDelayedExpansion & set /A "_localdepth+=1"
        for /L %%z in (!_localdepth!,-1,1) do endlocal & rem Run outer loop in foreach's base context
        if "%%t"=="""" ( rem Empty token; do not change
            if /i not "%SKIP_EMPTY_TOKENS%"=="true" (
                set /A "_num+=1" & set "_tok=%%~t" & set "_utok=%%~t"
                %_cmd%
            )
        ) else ( rem Nonempty token; unquote once
            for /F "tokens=* delims=" %%t in ("%%~t") do (
                set /A "_num+=1" & set "_tok=%%t" & set "_utok=%%~t"
                %_cmd%
            )
        )
    )
    call :return %_out%

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
