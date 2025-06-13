::One-liner to place at top of script to achieve autogoto functionality:
:: @echo off & goto :.%1 1>nul 2>nul || (echo(&echo(  %~nx0&echo(&for /f "tokens=* delims=:." %%A in ('findstr /R /C:"^:::" /C:"^:\." "%~f0"') do @echo(%%A) & for /f "tokens=1* delims=?" %%A in ("%~1") do if not "%~1"=="%%A" @exit /b 0

@echo off
echo(
echo(----[%~nx0]----
echo(Running: "goto :.%1"
echo(
goto :.%1 1>nul 2>nul && (
    echo(  Now in Block 2   ^(goto returned SUCCESS^)
) || (
    echo(  Now in Block 3   ^(goto returned FAILURE^)
)
echo(  Now in Block 4   ^(script was not automatically terminated^)
echo(
echo(Printing usage info and exiting...
echo(
for /f "tokens=* delims=:." %%A in ('findstr /R /C:"^:::" /C:"^:\." "%~f0"') do @echo(%%A
:: cmd /d /c man.bat "%~f0" "Usage"
exit /b 0


:::.Usage:
:::
:::  autogoto.bat /FLAG    Attempts to jump to label :./FLAG
:::  autogoto.bat          Attempts to jump to label :.
:::
:::..Labels:
:::  The following labels are defined in autogoto.bat:
:::    :.--flag      (Normal flag)
:::    :./flag       (Normal flag)
:::    :./?          (Help flag)
:::    :.            (No flag)
:::
:::..Blocks:
:::  autogoto.bat prints a trace of what blocks of code are executed.
:::    Block 1:  runs if 'goto' jumps to a label.
:::    Block 2:  runs if 'goto' returns SUCCESS.
:::    Block 3:  runs if 'goto' returns FAILURE.
:::    Block 4:  runs if the script was not automatically terminated.
:::
:::..Results:
:::                 Example                  Blocks Traversed
:::  Type           Usage                    1   2   3   4
:::-----------------------------------------------------------
:::  Normal flag:   autogoto.bat /label1     1
:::  Invalid flag:  autogoto.bat /asdf               3
:::  Help flag:     autogoto.bat /?                  3   4
:::  No flag:       autogoto.bat             1
:::


%===============================% goto :EOF
:.--flag   (Normal flag)
:./flag
echo(  Now in Block 1 ^(Jumped to label :.%1^)
echo(
echo(Exiting...
echo(
exit /b 0


%===============================% goto :EOF
:./?        (Help flag)
echo(  Now in Block 1 ^(Jumped to label :.%1^)
echo(
echo(Exiting...
echo(
exit /b 0


%===============================% goto :EOF
:.          (No arguments provided)
echo(  Now in Block 1 ^(Jumped to label :.%1^)
echo(
echo(Exiting...
echo(
exit /b 0

