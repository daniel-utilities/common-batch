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
:::    @echo off & goto :.autogoto.%1 1>nul 2>nul ||(setlocal DisableDelayedExpansion&echo(&echo(Usage^:&echo(&(for /F tokens^=^1^*^ delims^=:.^ eol^= %%A in ('findstr /R /C:"^:\.autogoto\." "%~f0"') do echo(  %~nx0 %%B)&echo(&(for /F "tokens=1* delims=?" %%A in ("%~1") do if not "%~1"=="%%A" (call man.bat "%~f0" "/exc:autogoto" %2 %3 %4 %5 %6 %7 %8 %9 2>nul&exit /b 1)))
:::
:::
:::.Details:
:::
:::  Jumps immediately to a label corresponding to the first argument --flag.
:::  Define new labels using the syntax:
:::
:::    :.autogoto.--[flag]               Description text
:::    :.autogoto./[flag]                [alternative form]
:::    (your code here)
:::    exit /b [ERRORLEVEL]
:::
:::  Then the script will jump to this label if called as:
:::
:::    script.bat --[flag]
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
:::.Methodology:
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
:::.Results:
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
:::  If the label contains the character "?", GOTO fails, but does NOT terminate
:::    the script automatically; must detect this condition and exit manually.
:::

@echo off
cls
    %= Attempt to jump to first argument =%
echo(
echo(  AUTOGOTO.BAT^: running: "goto :.autogoto.%1"
echo(
goto :.autogoto.%1 1>nul 2>nul && (
    %= Script was called with a valid flag =%
    echo(  AUTOGOTO.BAT^: Now in Block 2   ^(goto returned SUCCESS^)
) || (
    %= Script was called with an invalid flag =%
    echo(  AUTOGOTO.BAT^: Now in Block 3   ^(goto returned FAILURE^)
    setlocal DisableDelayedExpansion
    echo(&echo(Usage^:&echo(&(for /F tokens^=^1^*^ delims^=:.^ eol^= %%A in ('findstr /R /C:"^:\.autogoto\." "%~f0"') do echo(  %~nx0 %%B)&echo(
)
    %= Script was called with the help flag =%
echo(  AUTOGOTO.BAT^: Now in Block 4   ^(script was not automatically terminated^)
call man.bat "%~f0" "/exc:autogoto" %2 %3 %4 %5 %6 %7 %8 %9 2>nul
exit /b 1


%=====================================================================% goto :EOF
:.autogoto.--flag               Normal flag
:.autogoto./flag                Normal flag
echo(  AUTOGOTO.BAT^: Now in Block 1 ^(Jumped to label :.autogoto.%1^)
echo(  AUTOGOTO.BAT^: Exiting...
exit /b 0


%=====================================================================% goto :EOF
:.autogoto./? [keyword]         Help flag
echo(  AUTOGOTO.BAT^: Now in Block 1 ^(Jumped to label :.autogoto.%1^)
echo(  AUTOGOTO.BAT^: Exiting...
exit /b 0


%=====================================================================% goto :EOF
:.autogoto.                     No arguments provided
echo(  AUTOGOTO.BAT^: Now in Block 1 ^(Jumped to label :.autogoto.%1^)
echo(  AUTOGOTO.BAT^: Exiting...
exit /b 0

