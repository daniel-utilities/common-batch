@echo off
setlocal DisableDelayedExpansion
set ^"LF=^
%= EMPTY LINE =%
^" 
set    ^"#LF=^^^%LF%%LF%^%LF%%LF%^"
set   ^"#EOL=^^^%LF%%LF%^"          %= User provides the missing LF when expanding this at the end of a macro line =%
set   ^"##LF=^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^"
set  ^"##EOL=^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^"
((for /L %%a in (1,1,70) do pause>nul) & set /p "TAB=")<"%COMSPEC%"
set "TAB=%TAB:~0,1%"

set ^"DDE=DisableDelayedExpansion"
set ^"EDE=EnableDelayedExpansion"

:: %@STRING.PRINTLN:{VAR}=strv%                 Print value of variable called "strv"
:: %@STRING.PRINTLN:{VAR}=strv%                 Print value of variable called "strv"
:: %@STRING.PRINTLN:!{VAR}!=string literal%     Print a string literal
:: %@STRING.PRINTLN: ... % 1>&2                 Print to error stream instead of output stream
::  All forms are followed by a linefeed. Use @STRING.PRINT to disable this behavior.
set ^"@STRING.PRINTLN=(setlocal %EDE%%#EOL%
echo(!{VAR}!%#EOL%
endlocal)"

set ^"@STRING.PRINT=(setlocal %EDE%%#EOL%
<nul set /P "@STRING.PRINT.temp=!{VAR}!"%#EOL%
endlocal)"

:: %@STRING.PRINTLN_DEBUG:{VAR}=strv%
set ^"@STRING.PRINTLN=(setlocal %EDE%%#EOL%
echo({VAR}=[!{VAR}!]%#EOL%
endlocal)"

set ^"MAP_1= key1=val1%#EOL%
             key2=val2%#EOL%
             key3=val3%#EOL%
"

%@TEST%

%@STRING.PRINTLN:{VAR}=MAP_1%

set ^"MAP_2= key1=val1%##EOL%
             key2=val2%##EOL%
             key3=val3%##EOL%
"

%@STRING.PRINTLN:{VAR}=MAP_2%

setlocal %DDE%
for /F "tokens=1* delims==%TAB% " %%A in (^"%MAP_1%^") do echo [%%A]--^>[%%B]
endlocal

setlocal %EDE%
for /F "tokens=1* delims==%TAB% " %%A in (^"%MAP_2%^") do echo [%%A]--^>[%%B]
endlocal

exit /b 0