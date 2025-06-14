@echo off
setlocal DisableDelayedExpansion

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

set "A1=asdf"
set "A2="asdf""
set ^"B1=""
set ^"B2=""""
set "C1= "
set "C2=" ""
set "D1=!"
set "D2="!""
set "E1=^"
set "E2="^^""
set "F1=="
set "F2="=""
set "G1="
set "G2="""
set "H1=;"
set "H2=";""
setlocal EnableDelayedExpansion

for %%V in (A1 A2 B1 B2 C1 C2 D1 D2 E1 E2 F1 F2 G1 G2 H1 H2) do (
    if #"!%%V:~1,-1!"==#!%%V! (
        echo %%V=[!%%V!]  ^(quoted^)
    ) else (
        echo %%V=[!%%V!]  ^(unquoted^)
    )
)

endlocal
echo.
echo.

setlocal DisableDelayedExpansion
for /F "tokens=1,2* eol=: delims=:" %%A in (^"^
_arg1:"default 1":%1^%LF%%LF%^
_arg2:A1:%2^%LF%%LF%^
_arg3:"default 3":%3^%LF%%LF%^
") do (
    set "%%A=%%C"
    :: Dereference %%A back into itself
    setlocal EnableDelayedExpansion
    if #"!%%A:~1,-1!"==#!%%A! (  set "%%A=!%%A:~1,-1!"     %= A contains "Quoted value" or "" =%
    ) else for %%V in (!%%A!) do ( set "%%A=!%%V!" )       %= A contains Unquoted_Value or is empty =%
    if defined %%A ( for /F delims^=^ eol^= %%V in ("!%%A!") do ( endlocal & set "%%A=%%V" ) ) else ( endlocal & set "%%A=" )

    if not defined %%A (
        set "%%A=%%B"
        :: Dereference %%A back into itself
        setlocal EnableDelayedExpansion
        if #"!%%A:~1,-1!"==#!%%A! (  set "%%A=!%%A:~1,-1!"     %= A contains "Quoted value" or "" =%
        ) else for %%V in (!%%A!) do ( set "%%A=!%%V!" )       %= A contains Unquoted_Value or is empty =%
        if defined %%A ( for /F delims^=^ eol^= %%V in ("!%%A!") do ( endlocal & set "%%A=%%V" ) ) else ( endlocal & set "%%A=" )
    )
)

if "!!"=="" ( echo ERROR: did not exit EDE scope & exit /b 1 )
setlocal EnableDelayedExpansion 
echo _arg1=[!_arg1!]
echo _arg2=[!_arg2!]
echo _arg3=[!_arg3!]
exit /b 0