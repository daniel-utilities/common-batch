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


set ^"@FOREACHLINE=for /F ^^^"eol^^=%##LF%^^ delims^^=^^^""

set ^"#@FOREACHLINE=for /F ^^^^^^^"eol^^^^=%###LF%^^^^ delims^^^^=^^^^^^^""

set ^"@TEST.#FOREACHLINE=%#@FOREACHLINE%"



set ^"multiline=line1%#EOL%
 line2%#EOL%
  line3%#EOL%
%#EOL%
   line4"

setlocal EnableDelayedExpansion

echo.
echo ############################################
echo ########  TEST @FOREACHLINE    #############
echo.
echo @FOREACHLINE:
echo [!@FOREACHLINE!]
echo.
echo @TEST.#FOREACHLINE:
echo [!@TEST.#FOREACHLINE!]
echo.
%@FOREACHLINE% %%L in ("!multiline!") do echo Line: [%%L]
echo.
%@TEST.#FOREACHLINE% %%L in ("!multiline!") do echo Line: [%%L]
echo.
echo ############################################
