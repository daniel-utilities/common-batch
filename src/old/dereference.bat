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
echo PBR Single-characters, DDE/EDE
echo ##################################################
echo.
for %%v in (1tilde 1backq 1exclm 2exclm 1prcnt 2prcnt 1caret 2caret 1amper 1opren 1cpren 1equal 1tabch 1obrak 1cbrak 1vpipe 1colon 1semic 1quote 2quote 1leftc 1rghtc 1qmark 1space) do (
    for %%m in (DDE EDE) do (
        set /a "NUM_TESTS+=1"
        call :test.begin %%m %%v && (
            set /a "NUM_SUCCESSFUL+=1"
        ) || (
            if "%PAUSE_ON_ERROR%"=="y" pause
            if "%EXIT_ON_FIRST_ERROR%"=="y" exit /b 1
        )
    )
)

echo.
echo ##################################################
echo PBR Strings with/without content, DDE/EDE
echo ##################################################
echo.
for %%v in (0, 1, 2, 3, 4, 5, 6, 7, 8, A, B, C) do (
    for %%m in (DDE EDE) do (
        set /a "NUM_TESTS+=1"
        call :test.begin %%m teststr%%v && (
            set /a "NUM_SUCCESSFUL+=1"
        ) || (
            if "%PAUSE_ON_ERROR%"=="y" pause
            if "%EXIT_ON_FIRST_ERROR%"=="y" exit /b 1
        )
    )
)

echo.
echo ##################################################
echo PBV Strings with/without content, DDE/EDE
echo ##################################################
echo.
for %%v in (0, 1, 2, 3, 4, 5, 6, 7, 8, A, B, C, D) do (
    for %%m in (DDE EDE) do (
        set /a "NUM_TESTS+=1"
        call :test.begin %%m "!teststr%%v!" && (
            set /a "NUM_SUCCESSFUL+=1"
        ) || (
            if "%PAUSE_ON_ERROR%"=="y" pause
            if "%EXIT_ON_FIRST_ERROR%"=="y" exit /b 1
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

:: call :dereference VAR=REF || set "VAR=default value"     (Requires: :escape_for_pct_expansion)
::   Dereferences a variable, copying its value to VAR.
::    o If REF contains %, it is first expanded.
::    o If %-expanded-REF is "quoted", it is considered a "pass-by-value";
::        The unquoted literal value is copied into VAR.
::    o If %-expanded-REF is unquoted, it is considered a "pass-by-ref" variable name;
::        The contents of this variable are copied into VAR.
::
::   Returns 0 if VAR is nonempty, 1 if VAR is empty.
::
::  Usage:
::    o Dereference a numbered argument: ( so %1 may contain "pass-by-value" or PASSBYREF )
::        call :dereference arg=%%%%1
::       
::    o Copy the contents of var1 into var2:
::        call :dereference var2=var1
::        
::
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
    




:: #############################################################################
:: #############################################################################

:test.begin
    setlocal DisableDelayedExpansion
    set "MODE=%~1"
    set "TESTVAR=%2"
    :: set "RESULTCODE=" & set /A "RESULTCODE=%~3" 2>nul || set /A "RESULTCODE=0"

    setlocal EnableDelayedExpansion
    set "original=" & rem Actual value to test against
    if defined TESTVAR (
        if "!TESTVAR:~1,-1!"==!TESTVAR! (   rem PBV
            set "original=!TESTVAR:~1,-1!"
            if defined original set "original=!original:""="!"
        ) else (                            rem PBR
            set "original=!%TESTVAR%!"
        )
    )
    set "val="     & rem Value returned by :dereference
    if defined original ( set /A "checkcode=0" ) else ( set /A "checkcode=1" )

    if "%MODE%"=="EDE" ( setlocal EnableDelayedExpansion ) else ( setlocal DisableDelayedExpansion )
    call :dereference val=%%%%2 && set /A "exitcode=0" || set /A "exitcode=1"

    :: TEST RESULTS
    setlocal EnableDelayedExpansion
    if !exitcode! NEQ !checkcode! (
        echo ERROR: Test !NUM_TESTS! failed. ^(Returned ERRORLEVEL=!exitcode!, expected !checkcode!^)
        call :__print_test
        exit /b 1
    )
    if not "!val!"=="!original!" (
        echo ERROR: Test !NUM_TESTS! failed.
        call :__print_test
        exit /b 1
    )
    if not "!HIDE_SUCCESSFUL_TESTS!"=="y" call :__print_test
    exit /b 0

:__print_test
    setlocal EnableDelayedExpansion
    echo ######## TEST !NUM_TESTS!: !TESTVAR! ^(!MODE!^) ########
    echo   Original: str=[!original!], !TAB! Checkcode=!checkcode!
    echo   Returned: str=[!val!], !TAB!  Exitcode=!exitcode!
    if %exitcode% EQU 1 (
    echo     ^(Detected no content^)
    )
    echo.
    goto :EOF




:: #############################################################################
:: #############################################################################

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
