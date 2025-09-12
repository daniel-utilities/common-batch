::==============================================================================
::  @MACRO.bat
::==============================================================================
:::.Summary:
:::  Template macro library.
:::
:::..Loading and Using Macros:
:::  Run  <basename> /list  for a list of available macros.
:::
:::    :: Load macros
:::    setlocal DisableDelayedExpansion
:::    call "path\to\<basename>" /import || exit /b 1
:::
:::    :: Use macros
:::    setlocal EnableDelayedExpansion
:::    %<basename_no_ext>.NAME% [arg1] [arg2] ...
:::
:::..What is a macro?
:::  Batchfile "Macros" are regular variables containing executable code,
:::  which executes upon expansion.
:::
:::  Macros can accept arguments, modify variables, run programs, and
:::  use 'for' and 'if', but they cannot use 'call' or percent-expansion.
:::  Their purpose is portability and performance. It is often easier to
:::  source a macro library (such as this one) than to maintain a function
:::  and its dependencies within a script. Moreover, macros are typically
:::  an order of magnitude faster than the equivalent function, since they
:::  are already loaded into memory.
:::
:::  Macros are defined in DDE mode (`setlocal DisableDelayedExpansion`)
:::  because they contain many special characters which would otherwise need
:::  lengthy escape sequences.
:::
:::  Macro expansion requires EDE mode (`setlocal EnableDelayedExpansion`),
:::  because code is parsed after %%-expansion and before !!-expansion.
:::
::==============================================================================
@echo off & for /f "tokens=1-3 delims=/-" %%1 in (".autogoto./%1") do (if "%%3"=="" (goto :%%1%%2) else goto) 2>nul || (%=Usage Info=% setlocal DisableDelayedExpansion&echo.&echo Usage:&echo.&(for /F "tokens=1* delims=:." %%A in ('findstr /RIC:"^:\.autogoto\.[^\ ]" "%~f0"') do echo   %~nx0 /%%B)&endlocal)



%====================================================================%  goto :EOF
:.autogoto.import              Import macros into the current scope.

if "!!"=="" 2>&1 echo ERROR: Macro definition requires DisableDelayedExpansion.& exit /b 1

set ^"LF=^
%= EMPTY LINE =%
^"
set "TAB=	"
if defined #LF goto :continue
set    ^"#LF=^^^%LF%%LF%^%LF%%LF%^"                           %= Percent-Expands to a single LF in DDE =%
set   ^"#EOL=^^^%LF%%LF%^"                                    %= User provides the missing LF when expanding this at the end of a macro line =%
set   ^"##LF=^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^"   %= Produces a single LF after two percent-expansions in DDE =%
set  ^"##EOL=^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^"
set  ^"###LF=^^^^^^^^^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^"
set ^"###EOL=^^^^^^^^^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^"
:continue


::==============================================================================
:::.%@MACRO<dot>EXAMPLE<dot>1% {str:arg1} {str:arg2} {str:arg3} [str:arg4]...
:::  Example macro definition.
:::
:::  Consumes a space-separated list of arguments placed after the macro.
:::  Internally, assigns the first three to metavariables %1, %2, %3, and the
:::  remainder to %4.
:::  Limitations:
:::  - for /f fails if arg1-arg3 contain whitespace, even within quotes.
:::  - for    fails if arg4 contains '?' or '*'.
:::
::-------- BEGIN MACRO DEFINITION ----------------------------------------------
for %%@ in (@MACRO.EXAMPLE.1) do 2>nul set ^"%%@=for %%# in (1 2) do if %%#==2 ( %#EOL%
%------------------------------------------------------------------------% %#EOL%
%- SECTION 2  Macro Body                                                -% %#EOL%
echo(--^^^> %%@: Entering Section 1%#EOL%
for /f "tokens=1-3*" %%1 in ("!%%@.args!") do ( %#EOL%
	echo(      {arg1}=[%%~1]%#EOL%
	echo(      {arg2}=[%%~2]%#EOL%
	echo(      {arg3}=[%%~3]%#EOL%
	set "%%@.args[#]=3" %#EOL%
	for %%a in (%%4) do (%#EOL%
		set /A "%%@.args[#]+=1"%#EOL%
		echo(      [arg!%%@.args[#]!]=[%%~a]%#EOL%
	) %#EOL%
)%#EOL%
for %%v in (args args[#]) do set "%%@.%%v=" %= Cleanup local variables =% %#EOL%
echo(--^^^> %%@: Leaving Section 1%#EOL%
%------------------------------------------------------------------------% %#EOL%
%- SECTION 1  Collect Macro Arguments               -% ) else set %%@.args=!=!^"^
&& (setlocal EnableDelayedExpansion & if not "!%%@:~-3!"=="^!=^!" (endlocal&call) else endlocal) || (1>&2 echo(ERROR: Invalid macro definition in %~nx0.& exit /b 1)
::-------- END MACRO DEFINITION ------------------------------------------------
goto :continue
:test.@MACRO.EXAMPLE.1 [var:args]
	setlocal EnableDelayedExpansion
	set "args=!%~1!" & if "!args: =!"=="" set "args=value1 "value2" "" "optional 1" "optional 2""
	echo(Executing:!LF!  %%@MACRO.EXAMPLE.1%% !args!
	echo(!LF!Macro Output:!LF!vvvvvvvvvvvvvvvvvvvv
	%@MACRO.EXAMPLE.1% !args!
	echo(^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	exit /b 0
:continue
::==============================================================================



::==============================================================================
:::.%@MACRO<dot>EXAMPLE<dot>2:$$={var:arg1}% ( ... )
:::  Example macro definition.
:::
:::  Short macros may execute more quickly if their arguments are substituted
:::  directly into the code at runtime.
:::  Since we no longer need to list arguments after the macro, the macro may
:::  instead be provided a code block to execute using 'for' or 'if'.
:::
::-------- BEGIN MACRO DEFINITION ----------------------------------------------
for %%@ in (@MACRO.EXAMPLE.2) do 2>nul set ^"%%@=for %%# in (1 2 3) do if %%#==1 ( %#EOL%
%------------------------------------------------------------------------% %#EOL%
%- SECTION 1  Before External Code Block                                -% %#EOL%
echo(--^^^> %%@: Entering Section 1%#EOL%
set "%%@.args=$$" %= Runtime substitution ends up here =% %#EOL%
echo(--^^^> %%@: Leaving Section 1%#EOL%
%------------------------------------------------------------------------% %#EOL%
%- SECTION 3  After External Code Block              -% ) else if %%#==3 ( %#EOL%
echo(--^^^> %%@: Entering Section 2%#EOL%
for %%v in (args) do set "%%@.%%v=" %= Cleanup local variables =% %#EOL%
echo(--^^^> %%@: Leaving Section 2%#EOL%
%------------------------------------------------------------------------% %#EOL%
%- SECTION 2  Execute External Code Block -% ) else for %%a in (!%%@.args!) do^"^
&& (setlocal EnableDelayedExpansion & if not "!%%@:~-2!"=="do" (endlocal&call) else endlocal) || (1>&2 echo(ERROR: Invalid macro definition in %~nx0.& exit /b 1)
::-------- END MACRO DEFINITION ------------------------------------------------
goto :continue
:test.@MACRO.EXAMPLE.2 [var:args]
	setlocal EnableDelayedExpansion
	set "args=!%~1!" & if "!args: =!"=="" set "args=value1 "value2" "" "optional 1" "optional 2""
	echo(Executing:!LF!  %%@MACRO.EXAMPLE.2:$$=^^!args^^!%% ^( ... ^)
	echo(!LF!Macro Output:!LF!vvvvvvvvvvvvvvvvvvvv
	%@MACRO.EXAMPLE.2:$$=!args!% ( echo(  arg=[%%a])
	echo(^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	exit /b 0
:continue
::==============================================================================




set "IMPORTS=%IMPORTS% %~n0"
exit /b 0
%======================  END .autogoto.import  ======================%  goto :EOF



%====================================================================%  goto :EOF
:.autogoto.list                Lists available macros.
setlocal DisableDelayedExpansion
echo.
echo For more info on a particular definition, use:
echo   %~nx0 /? [macro]
echo.
echo Available macros:
echo.
:: This is just a massively stripped-down version of man.bat
for /F tokens^=^*^ delims^=:.^ eol^= %%l in ('findstr /RIC:"^:::\..*%%%~n0" "%~f0"') do (
	setlocal EnableDelayedExpansion
	set "line=%%l"
	set "line=!line:<basename>=%~nx0!"
	set "line=!line:<basename_no_ext>=%~n0!"
	set "line=!line:<dot>=.!"
	set "line=!line:<pct>=%%!"
	echo   !line!
	endlocal
)
echo.
exit /b 0
%========================  END .autogoto.list =======================%  goto :EOF



%====================================================================%  goto :EOF
:.autogoto.? [macro]           Prints detailed documentation.
setlocal DisableDelayedExpansion
if "%~2"=="" (
	call "%~f0" print/usage
	man.bat "%~f0" "Summary"
) else (
	man.bat "%~f0" "%~2 /exc:Summary /exc:.autogoto."
)
exit /b 1
%=========================  END .autogoto.?  ========================%  goto :EOF



%====================================================================%  goto :EOF
:.autogoto.test name [args]    Runs built-in unit tests.
::  Runs tests for macros.
::  Returns:
::    ERRORLEVEL    0 if all tests were successful, 1 if tests failed.
::
set "div==================================================="

:: Import macro definitions from this file
setlocal DisableDelayedExpansion
call "%~f0" /import || (2>&1 echo One or more macros failed to import.& exit /b 1)
setlocal EnableDelayedExpansion

:: Use "reflection" to build a list of macros
set "macros="
if not "%~2"=="" cls
for /f tokens^=1*^ delims^=^=^ eol^= %%v in ('"set %~n0 | findstr /B /L /C:%~n0"') do if "%~2"=="" (
	set "macros=!macros! %%v"
) else if "%%v"=="%~2" (
	echo !LF!!div!
	set %%v
	echo !div!
	set "macros=!macros! %%v"
) else if "%%v"=="%~n0.%~2" (
	echo !LF!!div!
	set %%v
	echo !div!
	set "macros=!macros! %%v"
)
if "!macros!"=="" (2>&1 echo No macros available, or invalid macro specified.& exit /b 1)

:: Run tests
set /A "num_tests=0"
set /A "num_success=0"
set ^"args=%3 %4 %5 %6 %7 %8 %9^"
for %%v in (!macros!) do (
	set /A "num_tests+=1"
	echo !LF!---^> Test !num_tests!: %%v!LF!!div!
	call :test.%%v args && (
		set /A "num_success+=1"
		echo !div!!LF!---^> Test !num_tests!: SUCCESS
	) || (
		echo !div!!LF!---^> Test !num_tests!: FAILED
	)
)

:: Print results
echo !LF!!div!
echo %~nx0: !num_success!/!num_tests! tests passed.!LF!
if "!num_tests!"=="!num_success!" (exit /b 0) else exit /b 1
%=======================  END .autogoto.test  =======================%  goto :EOF


