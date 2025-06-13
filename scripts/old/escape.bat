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
echo Single-characters, DDE/EDE to DDE/EDE
echo ##################################################
echo.
for %%v in (1tilde 1backq 1exclm 2exclm 1prcnt 2prcnt 1caret 2caret 1amper 1opren 1cpren 1equal 1tabch 1obrak 1cbrak 1vpipe 1colon 1semic 1quote 2quote 1leftc 1rghtc 1qmark 1space) do (
    for %%f in (DDE EDE) do (
        for %%t in (DDE EDE) do (
            set /a "NUM_TESTS+=1"
            call :test.begin %%f %%t %%v && (
                set /a "NUM_SUCCESSFUL+=1"
            ) || (
                if "%PAUSE_ON_ERROR%"=="y" pause
                if "%EXIT_ON_FIRST_ERROR%"=="y" exit /b 1
            )
        )
    )
)

echo.
echo ##################################################
echo Strings with/without content, DDE/EDE to DDE/EDE
echo ##################################################
echo.
for %%v in (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, B, C, D) do (
    for %%f in (DDE EDE) do (
        for %%t in (DDE EDE) do (
            set /a "NUM_TESTS+=1"
            call :test.begin %%f %%t teststr%%v && (
                set /a "NUM_SUCCESSFUL+=1"
            ) || (
                if "%PAUSE_ON_ERROR%"=="y" pause
                if "%EXIT_ON_FIRST_ERROR%"=="y" exit /b 1
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


:: call :escape_for_pct_expansion  VAR  DDE|EDE     (Requires: Nothing)
::   Modifies VAR such that "%VAR%" expands to "original contents of VAR" .
::   Typically, without escaping, "%VAR%" will NOT expand correctly if VAR contains
::     any literal !, ^, or an odd number of double-quotes ".
::   Escaping procedure is different depending on whether VAR will be expanded
::     inside a scope with EnableDelayedExpansion or DisableDelayedExpansion, so
::     it is necessary to specify in advance DDE or EDE to modify VAR for that environment.
:: Params:
::   VAR: Name of variable to modify.
::     Result is agnostic to the caller's DelayedExpansion status;
::     Returns the same escaped string whether DelayedExpansion is enabled or disabled in the caller.
::   DDE|EDE: Escape mode
::     VAR will be modified for quoted-%-expansion inside a scope with DDE or EDE.
::
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





:: #############################################################################
:: #############################################################################
:test.begin
    setlocal EnableDelayedExpansion
    set "FROM=%~1"
    set "TO=%~2"
    set "TESTVAR=%~3"

    set "original=!%TESTVAR%!"  & rem Original value
    set "escaped=!original!"    & rem Value operated on by "escape_for_pct_expansion"
    set "expanded="             & rem Value after %-expansion occurs

    :: SCOPE: "FROM"
    if "%FROM%"=="EDE" ( setlocal EnableDelayedExpansion ) else ( setlocal DisableDelayedExpansion )
    call :escape_for_pct_expansion escaped %TO%

    :: SCOPE: "TO"
    if "%TO%"=="EDE" ( set "#MACRO_CHANGESCOPE=setlocal EnableDelayedExpansion" ) else ( set "#MACRO_CHANGESCOPE=setlocal DisableDelayedExpansion" )
    set "__srcv__=escaped"   & rem Source variable
    set "__dstv__=expanded"  & rem Destination variable
    setlocal EnableDelayedExpansion
    if defined %__srcv__% (
        for /F tokens^=*^ delims^=^ eol^= %%a in ("!%__srcv__%:""="!"^

        ) do (  endlocal & %#MACRO_CHANGESCOPE%
                set "%__dstv__%=%%a"
        )
    ) else (    endlocal & %#MACRO_CHANGESCOPE%
                set "%__dstv__%="
    )

    :: TEST RESULTS
    if "%TO%"=="EDE" if not "!!"=="" (
        echo ERROR: Test %NUM_TESTS% failed to switch to EDE scope.
        call :__print_test
        exit /b 1
    )
    if "%TO%"=="DDE" if "!!"=="" (
        echo ERROR: Test %NUM_TESTS% failed to switch to DDE scope.
        call :__print_test
        exit /b 1
    )
    setlocal EnableDelayedExpansion
    if "!original!"=="!expanded!" (
        if not "%HIDE_SUCCESSFUL_TESTS%"=="y" call :__print_test
    ) else (
        echo ERROR: Test %NUM_TESTS% failed.
        call :__print_test
        exit /b 1
    )
    endlocal
    exit /b 0

:__print_test
    setlocal EnableDelayedExpansion
    echo ######## TEST !NUM_TESTS!: !TESTVAR! ^(!FROM!--^>!TO!^) ########
    echo   Original: str=[!original!]
    echo   Escaped:  str=[!escaped!]
    echo   Expanded: str=[!expanded!]
    echo.
    goto :EOF
