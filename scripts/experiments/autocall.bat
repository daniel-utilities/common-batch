@echo off
echo(
echo(----[%~nx0]----
echo(Running: "call :.%1"
echo(
call :.%1 && (
    echo(  Now in Block 2   ^(subroutine or 'call' returned SUCCESS^)
) || (
    echo(  Now in Block 3   ^(subroutine or 'call' returned FAILURE^)
)
echo(  Now in Block 4   ^(script not automatically terminated^)
echo(
echo(Printing usage info and exiting...
echo(
cmd /d /c man.bat "%~f0" "Usage"
exit /b 0


::.Usage:
::
::  <basename> /FLAG    Attempts to jump to label :./FLAG
::  <basename>          Attempts to jump to label :.
::
::..Labels:
::  The following labels are defined in <basename>:
::    :.--flag      (Normal flag)
::    :./flag       (Normal flag)
::    :./?          (Help flag)
::    :.            (No flag)
::
::..Blocks:
::  <basename> prints a trace of what blocks of code are executed.
::    Block 1:  runs if 'call' jumps to a label.
::    Block 2:  runs if label (subroutine) or 'call' returns SUCCESS.
::    Block 3:  runs if label (subroutine) or 'call' returns FAILURE.
::    Block 4:  runs if the script was not automatically terminated.
::
::..Results:
::  Type:          Example Usage:     <tab> Blocks Traversed:
::                                          1   2   3   4
::  Normal flag:   <basename> /label1 <tab> 1   2       4
::  Invalid flag:  <basename> /asdf   <tab>         3   4
::      Also prints CALL error text.
::  Help flag:     <basename> /?      <tab>         3   4
::      Also prints CALL help text.
::  No flag:       <basename>         <tab> 1   2       4
::


%===============================% goto :EOF
:.--flag   (Normal flag)
:./flag
echo(  Now in Block 1 ^(Jumped to label :.%1^)
echo(
echo(Returning SUCCESS...
echo(
exit /b 0


%===============================% goto :EOF
:./?        (Help flag)
echo(  Now in Block 1 ^(Jumped to label :.%1^)
echo(
echo(Returning SUCCESS...
echo(
exit /b 0


%===============================% goto :EOF
:.          (No arguments provided)
echo(  Now in Block 1 ^(Jumped to label :.%1^)
echo(
echo(Returning SUCCESS...
echo(
exit /b 0

