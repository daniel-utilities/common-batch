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
@echo off & goto :.%1 1>nul 2>nul || call man.bat "%~f0" "Usage" "/" "--" "Macro /exc:Detail" "%~n0 /exc:Detail"
exit /b 0


%============================  SECTION  ============================%  goto :EOF
:.--import
:./import
::  Import all macros into the current scope.
::
set "@MACRO.NAMESPACE=#%~n0"&:: Namespace; Macro-local variables should be created with this prefix
set "ns=%@MACRO.NAMESPACE%" &:: Alias for namespace
set "@MACRO.FULLNAME="      &:: Set before defining a macro
set "@MACRO.BASENAME="      &:: Set before defining a macro
:: List of temp variables to clear before returning
set "TMPV=@MACRO.NAME @MACRO.NAMESPACE @MACRO.END ns TMPV"
if "!!"=="" ( echo ERROR: Macro definition requires DisableDelayedExpansion. 1>&2 & goto :__exit_failure )
%------------------------------------------------------------------------------%

set ^"LF=^
%= EMPTY LINE =%
^"
set    ^"#LF=^^^%LF%%LF%^%LF%%LF%^"
set   ^"#EOL=^^^%LF%%LF%^"          %= User provides the missing LF when expanding this at the end of a macro line =%
set   ^"##LF=^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^"
set  ^"##EOL=^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^"
set  ^"###LF=^^^^^^^^^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^"
set ^"###EOL=^^^^^^^^^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^"

((for /L %%a in (1,1,70) do pause>nul) & set /p "TAB=")<"%COMSPEC%"
set "TAB=%TAB:~0,1%"

set "TRUE=0"
set "FALSE=1"
set "EDE=EnableDelayedExpansion"
set "DDE=DisableDelayedExpansion"



::.%<basename_no_ext>.EXAMPLE%  arg1  [arg2] ...
::  Brief macro summary
::
::..Detail.
::  Detailed macro summary
::
set "@MACRO.NAME=%NS%.EXAMPLE"
%========================================================================%
set ^"%@MACRO.NAME%=for %%# in (1 3 2 1) do if %%#==1 ( %#EOL%
%========================================================================% %#EOL%
%= SECTION 1  Clear Locals                                              =% %#EOL%
for %%V in (%= List of macro-local variables to clear =%%#EOL%
params params[#] !params! %#EOL%
) do set "%NS%.%%V=" %#EOL%
%========================================================================% %#EOL%
%= SECTION 2  Macro body                              =%) else if %%#==2 ( %#EOL%
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
%========================================================================% %#EOL%
%= SECTION 3  Input macro parameters      =% ) else set %ns%.params=!@MACRO.END!"

goto :__skip_test
:__test_EXAMPLE
echo HERE
exit /b 0
:__skip_test

goto :__exit_success

%------------------------------------------------------------------------------%
:__exit_success
set "IMPORTS=%NS% %IMPORTS%"
for %%V in (%TMPV%) do set "%%V="
exit /b 0
:__exit_failure
echo ERROR: Import %NS% failed 1>&2
for %%V in (%TMPV%) do set "%%V="
exit /b 1
:__check_macro MACRO_NAME
  setlocal EnableDelayedExpansion
  if "%~1"=="" ( echo ERROR: No macro provided. & exit /b 1 ) 1>&2
  if not defined %~1 ( echo ERROR: Macro %~1 is not defined. & exit /b 1 ) 1>&2
  if not "!%~1:*@MACRO.END=!"=="^!" ( echo ERROR: Macro %~1 has an invalid definition: & echo. & set "%~1" & echo. & exit /b 1 ) 1>&2
  exit /b 0
%==========================  END SECTION  ==========================%  goto :EOF



%============================  SECTION  ============================%  goto :EOF
:--test
:./test name [args]
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
%==========================  END SECTION  ==========================%  goto :EOF
