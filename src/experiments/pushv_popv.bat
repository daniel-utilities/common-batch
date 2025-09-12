@echo off
setlocal DisableDelayedExpansion
set "ERRORLEVEL="
set "EXC=ERROR:EXC"
set "PCT=ERROR:PCT"
set /a "NUM_TESTS=0"
set /a "NUM_SUCCESSFUL=0"
:: #############################################################################
set "1tilde=~"
set "1backq=`"
set "1exclm=!"
set "2exclm=!EXC!"
set "1prcnt=%%"
set "2prcnt=%%PCT%%"
set "1caret=^"
set "2caret=^^"
set "1amper=&"
set "1opren=("
set "1cpren=)"
set "1equal=="
set "1obrak=["
set "1cbrak=]"
set "1vpipe=|"
set "1colon=:"
set "1semic=;"
set 1quote=^"
set "2quote="""
set "1leftc=<"
set "1rghtc=>"
set "1qmark=?"
set "1space= "
((for /L %%P in (1,1,70) do pause>nul)&set /p "TAB=")<"%COMSPEC%" & call set "TAB=%%TAB:~0,1%%"
set "1tabch=%TAB%"
set ^"1newln=^

"
:: #############################################################################
setlocal EnableDelayedExpansion
set "teststr0=STRING"
set "teststr1=  STRING"
set "teststr2=STRING  "
set "teststr3=!1quote!STRING!1quote!"
set "teststr4=!1quote!STRING"
set "teststr5=!1quote!!1exclm!STRING"
set "teststr6=!1quote!!2exclm!STRING"
set "teststr7=!1quote!!1caret!STRING"
set "teststr8=!1quote!!1exclm!!1caret!STRING"
set "teststr9=!1tilde!!1backq!!1exclm!!2exclm!!1prcnt!!2prcnt!!1caret!!2caret!!1amper!!1opren!!1cpren!!1equal!!1tabch!!1obrak!!1cbrak!!1vpipe!!1colon!!1semic!!1quote!!2quote!!1leftc!!1rghtc!!1qmark!!1space!STRING"
set "teststrA="
set "teststrB=!1quote!"
set "teststrC=!1quote!!1quote!"
set "teststrD=!1tilde!!1backq!!1exclm!!2exclm!!1prcnt!!2prcnt!!1caret!!2caret!!1amper!!1opren!!1cpren!!1equal!!1tabch!!1obrak!!1cbrak!!1colon!!1semic!!2quote!!1qmark!!1space!STRING"
set "testmultiline0=line1!1newln!"
set "testmultiline1=line1!1newln!line2"
set "testmultiline2=line1!1newln!line2!1newln!"
set "testmultiline3=!1newln!"
:: #############################################################################
cls
echo.
echo ##################################################
echo Starting test harness...
echo ##################################################
echo.

set "HIDE_SUCCESSFUL_TESTS=n"
set "EXIT_ON_FIRST_ERROR=n"
set "PAUSE_ON_ERROR=n"

echo.
echo ##################################################
echo Single Characters and Strings, DDE/EDE to DDE/EDE
echo ##################################################
echo.
for %%a in (1tilde 1backq 1exclm 2exclm 1prcnt 2prcnt 1caret 2caret 1amper 1opren 1cpren 1equal 1tabch 1obrak 1cbrak 1vpipe 1colon 1semic 1quote 2quote 1leftc 1rghtc 1qmark 1space) do (
    for %%b in (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, B, C, D) do (  rem teststr#
        for %%f in (DDE EDE) do (
            for %%t in (DDE EDE) do (
                set /a "NUM_TESTS+=1"
                call :test.begin %%f %%t %%a teststr%%b && (
                    set /a "NUM_SUCCESSFUL+=1"
                ) || (
                    if "%PAUSE_ON_ERROR%"=="y" pause
                    if "%EXIT_ON_FIRST_ERROR%"=="y" exit /b 1
                )
            )
        )
    )
)


echo.
echo ##################################################
echo Completed %NUM_SUCCESSFUL%/%NUM_TESTS% tests successfully.
echo ##################################################
echo.
if %NUM_SUCCESSFUL% NEQ %NUM_TESTS% exit /b 1
exit /b 0


:: #############################################################################
:: #############################################################################



:: call :pushv_popv  "CMD"|CMDV  "VAR1 VAR2..."|VARLISTV    (Requires: :dereference, :escape_for_pct_expansion)
::  Saves some variables, runs a command, then restores the variables to their original values.
::    1. Saves each variable in VARLIST locally
::    2. Returns to the caller's scope
::    3. Runs CMD (from the caller's scope)
::    4. Restores the original value of each variable in VARLIST
::
:: Params:
::  "CMD"|CMDV      "Quoted": Command to run, OR
::                  (Unquoted): Variable name containing a command.
::  "VARS"|VARLISTV "Quoted": Space-separated list of variables to restore, OR
::                  (Unquoted): Variable name containing a list of variables.
::
:: Usage:
::  Return variables from a script or function using:
::    set "CMD=(goto) 2>nul"
::    call :pushv_popv CMD "var1 var2..."
:: 
::  Transfer variables across a setlocal barrier using:
::    set "CMD=endlocal & setlocal EnableDelayedExpansion"
::    call :pushv_popv CMD "var1 var2..."
::    
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



:: #############################################################################
:: #############################################################################


:test.begin
    :: SCOPE: "BASE" (strN is undefined)
    setlocal EnableDelayedExpansion & set SCOPE=BASE:EDE
    for /F "tokens=1,2,*" %%a in ("%*") do (
        set "FROM=%%~a"
        set "TO=%%~b"
        set "TESTVARS=%%~c"
    )
    set "CHECKCODE=0"

    set "EDE=EnableDelayedExpansion"
    set "DDE=DisableDelayedExpansion"
    set "cmd=endlocal & endlocal & setlocal !%TO%! & set SCOPE=TO:%TO%" & rem Macro command to transition from scope FROM to TO
    set "varlist="  & rem List of variables carried from FROM to TO
    set "num_vars=0" & for %%v in (%TESTVARS%) do (
        set /A "num_vars+=1"
        set "original!num_vars!=!%%v!"  & rem Original value to compare against
        set "val!num_vars!="            & rem Values carried from FROM to TO
        set "varlist=!varlist! val!num_vars!"
    )

    :: SCOPE: "FROM" (strN = originalN)
    setlocal %EDE% & set SCOPE=FROM:INTERMEDIATE
    for /L %%i in (1,1,%num_vars%) do set "val%%i=!original%%i!"
    setlocal !%FROM%! & set SCOPE=FROM:%FROM%

    :: SCOPE: "TO" (strN = originalN, if successful)
    ::
    :: BASE  -->  FROM    (setlocal EDE|DDE)
    ::              |
    ::   +-<--------+     (endlocal & endlocal) \
    ::   |                                      |--- call :pushv_popv
    ::   +-------> TO     (setlocal EDE|DDE)    /
    ::
    call :pushv_popv cmd varlist && set /A "exitcode=0" || set /A "exitcode=1"

    :: TEST RESULTS
    if "%TO%"=="EDE" if not "!!"=="" goto :__test_bad_scope_switch
    if "%TO%"=="DDE" if "!!"=="" goto :__test_bad_scope_switch
    if not "%SCOPE%"=="TO:%TO%" goto :__test_bad_scope_switch
    if %exitcode% NEQ %checkcode% goto :__test_bad_exitcode
    setlocal %EDE% & set "err=0"
    for /L %%i in (1,1,%num_vars%) do if not "!val%%i!"=="!original%%i!" set "err=1"
    if %err% EQU 1 goto :__test_unsuccessful
    goto :__test_successful

:__test_bad_scope_switch
    echo ERROR: Test %NUM_TESTS% returned to scope %SCOPE%, expected TO:%TO%.
    goto :__test_unsuccessful
:__test_bad_exitcode
    echo ERROR: Test %NUM_TESTS% returned EXITCODE=%exitcode%, expected %CHECKCODE%.
    goto :__test_unsuccessful
:__test_unsuccessful
    echo ERROR: Test %NUM_TESTS% failed.
    call :__print_test
    exit /b 1
:__test_successful
    if not "%HIDE_SUCCESSFUL_TESTS%"=="y" call :__print_test
    exit /b 0

:__print_test
    setlocal EnableDelayedExpansion
    echo ######## TEST !NUM_TESTS!: !TESTVARS! ^(!FROM!--^>!TO!^) ########
    for /L %%i in (1,1,%num_vars%) do (
        echo  TESTVAR[%%i]
        echo    Original: str%%i=[!original%%i!]
        echo    Returned: str%%i=[!val%%i!]
    )
    echo.
    goto :EOF



:: #############################################################################
:: #############################################################################


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

