::==============================================================================
::  autogoto_template.bat
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
@echo off & goto :.autogoto.%1 1>nul 2>nul ||(setlocal DisableDelayedExpansion&echo(&echo(Usage^:&echo(&(for /F tokens^=^1^*^ delims^=:.^ eol^= %%A in ('findstr /R /C:"^:\.autogoto\." "%~f0"') do echo(  %~nx0 %%B)&echo(&(for /F "tokens=1* delims=?" %%A in ("%~1") do if not "%~1"=="%%A" (call man.bat "%~f0" "/exc:autogoto" %2 %3 %4 %5 %6 %7 %8 %9 2>nul&exit /b 1)))



%====================================================================%  goto :EOF
:.autogoto.                     Description text
setlocal DisableDelayedExpansion
:: This code executed if script is run with no arguments.
:: Remove this section to prevent the script from running without arguments.
exit /b 0
%==========================  END .autogoto.  ========================%  goto :EOF




%====================================================================%  goto :EOF
:.autogoto./flag                Description text
setlocal DisableDelayedExpansion
:: This code executed if script is run with the first argument "/flag"
exit /b 0
%=======================  END .autogoto./flag  ======================%  goto :EOF



%====================================================================%  goto :EOF
:.autogoto./? [keyword]         Prints detailed documentation.
:: This section is inaccessible but included to provide the "/?" help text.
%=========================  END .autogoto./?  =======================%  goto :EOF
