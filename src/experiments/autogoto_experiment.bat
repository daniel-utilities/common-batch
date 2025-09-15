::##############################################################################
::
::  autogoto.bat
::
::##############################################################################
:::.Summary:
:::
:::  An experimental format for simple, functional batch scripting.
:::
:::  Place the following code at top of script to enable autogoto functionality:
:::
:::    @echo off & for /f "tokens=1-3 delims=/-" %%1 in (".autogoto./%1") do (if "%%3"=="" (goto :%%1%%2) else goto) 2>nul || (%=Usage Info=% setlocal DisableDelayedExpansion&echo.&echo Usage:&echo.&(for /F "tokens=1* delims=:." %%A in ('findstr /RIC:"^:\.autogoto\.\ " "%~f0"') do echo   %~nx0  %%B)&(for /F "tokens=1* delims=:." %%A in ('findstr /RIC:"^:\.autogoto\.[^\ ]" "%~f0"') do echo   %~nx0 /%%B)&endlocal)
:::
:::..Details:
:::
:::  Jumps immediately to a label corresponding to the first argument --flag.
:::  Define new labels using the syntax:
:::
:::    :.autogoto.[flag]               Description text
:::    (your code here)
:::    exit /b [ERRORLEVEL]
:::
:::  Then the script will jump to this label if called as:
:::
:::    script.bat /[flag]
:::    script.bat --[flag]
:::    script.bat [flag]
:::
:::  The default (no argument) flag can be defined as:
:::
:::    :.autogoto.                       Description text
:::    ...
:::
:::  If an invalid flag or /? is provided, prints available autogoto flags before exiting.
:::     Uses "findstr" to print each line starting with ":.autogoto."
:::
:::  If /? is provided, also prints detailed documentation.
:::     Uses "man.bat" to print each line starting with ":::".
:::
:::
:::..Methodology:
:::
:::  The following labels are defined in autogoto.bat:
:::    :.autogoto.--flag      (Normal flag)
:::    :.autogoto./flag       (Normal flag)
:::    :.autogoto./?          (Help flag)
:::    :.autogoto.            (No flag)
:::
:::  autogoto.bat prints a trace of what blocks of code are executed.
:::    Block 1:  runs if 'goto' jumps to a label.
:::    Block 2:  runs if 'goto' returns SUCCESS.
:::    Block 3:  runs if 'goto' returns FAILURE.
:::    Block 4:  runs if the script was not automatically terminated.
:::
:::
:::..Results:
:::                 Example                  Blocks Traversed
:::  Type           Usage                    1   2   3   4
:::-----------------------------------------------------------
:::  Normal flag:   autogoto.bat /flag       1
:::  Invalid flag:  autogoto.bat /asdf               3
:::  Help flag:     autogoto.bat /?                  3   4
:::  No flag:       autogoto.bat             1
:::
:::
:::  When GOTO fails to find a matching label, its script is terminated after
:::    completing the code block containing GOTO.
:::  This gives us time to print usage info before termination.
:::  If the label contains the sequence "/?", GOTO fails, but does NOT terminate
:::    the script automatically.
:::

@echo off
cls
echo.
%= Attempt to jump to first argument =%
%= Removes '/' and '-' from the beginning of arg 1 =%
%= Removes from the middle as well, but a flag with / in the middle is invalid anyway =%
for /f "tokens=1-3 delims=/-" %%1 in (".autogoto./%1") do (if "%%3"=="" (goto :%%1%%2) else goto) 2>nul || (
    %= Script was called with an invalid flag =%
    echo   AUTOGOTO.BAT^: Now in Block 3   ^(goto returned FAILURE^)
    %= Print Usage Info =%
    (setlocal DisableDelayedExpansion&echo Usage:&echo.&(for /F "tokens=1* delims=:." %%A in ('findstr /RIC:"^:\.autogoto\.\ " "%~f0"') do echo   %~nx0  %%B)&(for /F "tokens=1* delims=:." %%A in ('findstr /RIC:"^:\.autogoto\.[^\ ]" "%~f0"') do echo   %~nx0 /%%B)&endlocal)
)
echo   AUTOGOTO.BAT^: Now in Block 4   ^(script was not automatically terminated^)


%=====================================================================% goto :EOF
:.autogoto.                  No arguments provided
echo(  AUTOGOTO.BAT^: Now in Block 1 ^(No arguments provided^).
echo(  Exiting...
exit /b 0

%=====================================================================% goto :EOF
:.autogoto.flag              Normal flag
echo(  AUTOGOTO.BAT^: Now in Block 1 ^(Normal Flag^).
echo(  Exiting...
exit /b 0


%=====================================================================% goto :EOF
:.autogoto.? [keyword]       Help flag
echo(  AUTOGOTO.BAT^: Now in Block 1 ^(Help Flag^).
%= Print Usage Info =%
setlocal DisableDelayedExpansion
call "%~f0" invalid/flag

%= Print Detailed Info =%
man.bat "%~f0" "%~2 /exc:.autogoto." 2>nul
echo(  Exiting...
exit /b 1


