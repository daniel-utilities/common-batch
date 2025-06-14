::.SUMMARY.Usage:
::  <basename> ARGS
::
::
::  For a list of all macros in this file, use:
::    man.bat "<fullpath>" "<basename_no_ext>. !help"
::
::  For help with a specific macro, use:
::    man.bat "<fullpath>" ".MACRONAME"
::
::==============================================================================
::  @MACRO.bat
::==============================================================================
:::.Summary:
:::
:::  Simple description text.
:::
:::.Details:
:::
:::  Detailed description text.
:::
::==============================================================================
@echo off & goto :.autogoto.%1 1>nul 2>nul ||(setlocal DisableDelayedExpansion&echo(&echo(Usage^:&echo(&(for /F tokens^=^1^*^ delims^=:.^ eol^= %%A in ('findstr /R /C:"^:\.autogoto\." "%~f0"') do echo(  %~nx0 %%B)&echo(&(for /F "tokens=1* delims=?" %%A in ("%~1") do if not "%~1"=="%%A" (call man.bat "%~f0" "/exc:autogoto /exc:detail" %2 %3 %4 %5 %6 %7 %8 %9 2>nul&exit /b 1)))





%====================================================================%  goto :EOF
:.autogoto./import [verify=true]            Import all macros into the current scope.

if "!!"=="" call :throw "Macro definition requires DisableDelayedExpansion."

set "@MACRO.PREFIX=%~n0"            %= Macro names should be prefixed with this to identify what file they came from.     =%
set "ns=%@MACRO.PREFIX%.local"      %= Macro-local variable names should be prefixed with this.                           =%
set "@MACRO.NAME="                  %= Macro names should be formatted as @MACRO.PREFIX.[NAME]                            =%
set "@MACRO.VERIFY="                %= If defined, a marker is placed at the end of each macro for verification purposes. =%
if /I "%~2"=="verify" if /I "%~3"=="true" set "@MACRO.VERIFY=!@MACRO.END!"

%= List of temp variables to clear before returning to caller. =%
set "@MACRO.TMPV=@MACRO.PREFIX ns @MACRO.NAME @MACRO.VERIFY @MACRO.TMPV"

::==============================================================================
:: Constants used in macro definitions

set ^"LF=^
%= EMPTY LINE IS MANDATORY HERE =%
^"
set    ^"#LF=^^^%LF%%LF%^%LF%%LF%^"                           %= Percent-Expands to a single LF in DDE =%
set   ^"#EOL=^^^%LF%%LF%^"                                    %= User provides the missing LF when expanding this at the end of a macro line =%
set   ^"##LF=^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^"   %= Produces a single LF after two percent-expansions in DDE =%
set  ^"##EOL=^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^"
set  ^"###LF=^^^^^^^^^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^"
set ^"###EOL=^^^^^^^^^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^"

if not defined TAB ((for /L %%a in (1,1,70) do pause>nul) & set /p "TAB=")<"%COMSPEC%"
set "TAB=%TAB:~0,1%"

set "TRUE=0"
set "FALSE=1"
set "EDE=EnableDelayedExpansion"
set "DDE=DisableDelayedExpansion"



::==============================================================================
set "@MACRO.NAME=%@MACRO.PREFIX%.EXAMPLE"
:::.%<basename_no_ext>.EXAMPLE%  arg1 [arg2] ...
:::  Brief macro summary
:::
:::..Detail.
:::  Detailed macro summary
:::
set ^"%@MACRO.NAME%=for %%# in (1 3 2 1) do if %%#==1 ( %#EOL%
%------------------------------------------------------------------------% %#EOL%
%- SECTION 1  Clear Locals                                              -% %#EOL%
for %%V in (%= List of macro-local variables to clear =%%#EOL%
params params[#] !params! %#EOL%
) do set "%ns%.%%V=" %#EOL%
%------------------------------------------------------------------------% %#EOL%
%- SECTION 2  Macro body                              -%) else if %%#==2 ( %#EOL%
echo ==== Inside macro %@MACRO.NAME%... ==== %#EOL%
set "%ns%.params[#]=0" %#EOL%
for %%A in (!%ns%.params!) do (%#EOL%
  if !%ns%.params[#]!==0 set "%ns%.params=params params[#]" %#EOL%
  set /A "%ns%.params[#]+=1" %#EOL%
  set "%ns%.params[!%ns%.params[#]!]=%%A" %#EOL%
) %#EOL%
for /L %%i in (1,1,!%ns%.params[#]!) do (%#EOL%
  echo   Param %%i=[!%ns%.params[%%i]!] %#EOL%
) %#EOL%
echo ==== Leaving macro %@MACRO.NAME%... ==== %#EOL%
%------------------------------------------------------------------------% %#EOL%
%- SECTION 3  Input macro parameters      -% ) else set %ns%.params=%@MACRO.END%"

goto :__skip_test
:__test_EXAMPLE
echo HERE
exit /b 0
:__skip_test

goto :__exit_success

%------------------------------------------------------------------------------%
:__exit_success
set "IMPORTS=%@MACRO.PREFIX% %IMPORTS%"
for %%V in (%@MACRO.TMPV%) do set "%%V="
exit /b 0
:__exit_failure
echo ERROR: Import %NS% failed 1>&2
for %%V in (%@MACRO.TMPV%) do set "%%V="
exit /b 1
:__check_macro MACRO_NAME
  setlocal EnableDelayedExpansion
  set "errmsg="
  if "%~1"==""                      set "errmsg=No macro provided."
  if not defined %~1                set "errmsg=Macro %~1 is not defined."
  if not "!%~1:*@MACRO.END=!"=="^!" set "errmsg=Macro %~1 has an invalid definition:!LF!%~1=[!%~1!]!LF!"
  if defined errmsg ( call :throw errmsg ) else exit /b 0
%======================  END .autogoto./import  =====================%  goto :EOF



%====================================================================%  goto :EOF
:.autogoto./test name [args]                Runs built-in unit tests.
::  Runs tests for <basename> macros.
::  Returns:
::    ERRORLEVEL    0 if all tests were successful, 1 if tests failed.
::
setlocal DisableDelayedExpansion
call "%~f0" /import || ( echo ERROR: Failed to import macros from %~nx0. 1>&2 & goto :__exit_failure )
set ^"NS=%~n0.TEST^"
set ^"tests=%~2^" & if not defined tests set "tests=EXAMPLE"
shift & shift
set ^"args=%1 %2 %3 %4 %5 %6 %7 %8 %9^"
set /A "num_tests=0"
set /A "num_success=0"
for %%T in (%tests%) do (
    if not defined %NS%.%%T (
        echo ERROR: Test %NS%.%%T is not defined. 1>&2
    ) else (
        set /A "num_tests+=1"
        call
    )
)
if defined testname
:: if not defined args set "args=abc !TRUE! "!FALSE!" & ^ "%TAB%de f"  /ghi -jkl=mno --pqr="st  u" %TAB%"" """"  /?  "
echo Running test %NS%.%testname% with args %args%

exit /b 0
set @MACRO.EXAMPLE
setlocal EnableDelayedExpansion
echo =======================================================
echo Calling Macro:
echo %%@MACRO.EXAMPLE%% !args!
echo.
%@MACRO.EXAMPLE% %args%
endlocal & set "EXITCODE=%ERRORLEVEL%"
if not "%EXITCODE%"=="0" goto :__exit_failure

%------------------------------------------------------------------------------%
:__exit_success
exit /b 0
:__exit_failure
exit /b 1
%=======================  END .autogoto./test  ======================%  goto :EOF



%====================================================================%  goto :EOF
:.autogoto./? [macro]                       Prints detailed documentation.
:: This section is inaccessible but included to provide the "/?" help text.
%=========================  END .autogoto./?  =======================%  goto :EOF



::==============================================================================
:throw "Error message"|msg_var [ERRORLEVEL]
::
::   Prints an error message, returns to the caller, calls :exit ERRORLEVEL
::
    setlocal DisableDelayedExpansion & set "ERRORLEVEL=%ERRORLEVEL%"
    set ^"throw.msgv=%1"
    set "throw.msg=%~1"
    setlocal EnableDelayedExpansion
    if defined throw.msgv if "!throw.msgv!"=="!throw.msg!" ( set "throw.msg=!%1!"
    ) else set ^"throw.msg=!throw.msg:""="!"
    if not defined throw.msg set "throw.msg=ERROR: A critical error has occurred."
    if not "%~2"=="" ( set "ERRORLEVEL=%~2"
    ) else if "!ERRORLEVEL!"=="0" set "ERRORLEVEL=1"
    (goto) 2>nul & (
        setlocal DisableDelayedExpansion & call echo(  --[ %%~nx0 ]-- 1>&2 & endlocal
        setlocal EnableDelayedExpansion  &      echo(%throw.msg%      1>&2 & endlocal !
        call :exit %ERRORLEVEL%
    )



::==============================================================================
:exit [ERRORLEVEL]
::
::   Runs exit /b ERRORLEVEL from the caller's context.
::
    setlocal DisableDelayedExpansion & set "ERRORLEVEL=%ERRORLEVEL%"
    if not "%~1"=="" set "ERRORLEVEL=%~1"
    (goto) 2>nul & (
        %=======================================================================%
        %=                              Cleanup                                =%
        %=======================================================================%

        for %%V in (%@MACRO.TMPV%) do set "%%V="

        %=======================================================================%
        exit /b %ERRORLEVEL%
    )
