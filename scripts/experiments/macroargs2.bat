@echo off
setlocal DisableDelayedExpansion
set LF=^
%= This empty line is necessary =%
%= This empty line is necessary =%
((for /L %%a in (1,1,70) do pause>nul) & set /p "TAB=")<"%COMSPEC%"
set "TAB=%TAB:~0,1%"
for /f %%a in ('copy /Z %COMSPEC% nul') do set "CR=%%a"
for /f "tokens=1 delims=#" %%a in ('"prompt #$H# & echo on & for %%b in (1) do rem"') do set "BS=%%a"
set "BS=%BS:~0,1%"
for /f %%a in ('cls') do set "FF=%%a"
set ^"#LF=^^^%LF%%LF%^%LF%%LF%^^"
set ^"##LF=^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^^^^^^"

:: #@ARG.TYPE:ARGNUM=TEST N% (DEFINED) [else (UNDEFINED)]
:: #@ARG.TYPE_TYPE:ARGNUM=TEST N% (DEFINED) [else (UNDEFINED)]
::
::   TYPE       Type of value to consume at arg N. VALUE is processed as TYPE, then stored in @arg.val.
::              VALUE is processed as TYPE, then stored in @arg.val.
::                LIT       Consume a literal string. Arg is unquoted, then stored in @arg.val.
::                EXP       Consume an integer or math expression (syntax must be compatible with set /A).
::                REF       Consume a reference. If arg is quoted, the literal unquoted value is stored in @arg.val.
::                          If arg is unquoted, arg is treated as a variable name, and @arg.val is set to the value of that variable.
::
::   TYPE_TYPE  Type of KEY:=VALUE pair to consume at arg N.
::              Both KEY and VALUE are processed separately, then stored in @arg.key and @arg.val.
::                LIT_LIT   Consume a KEY:=VALUE pair, where KEY is type LIT, and VALUE is type LIT.
::                LIT_EXP   
::                LIT_REF   
::                EXP_LIT   
::                EXP_EXP   
::                EXP_REF   
::
::   TEST N     Numeric comparison of !@arg.num! against a constant N.
::              EQU, NEQ, LSS, LEQ, GTR, GEQ
::
::   DEFINED    Code to run if value is specified.

:: %#@ARG.LIT:ARGNUM=TEST N% (defined) [else (undefined)]
set ^"#@ARG.LIT=)else if !@arg.num! ARGNUM (if not defined @arg.key (%##LF%
(call ))"

:: %#@ARG.EXP:ARGNUM=TEST N% (defined) [else (undefined)]
set ^"#@ARG.EXP=)else if !@arg.num! ARGNUM (if not defined @arg.key (%##LF%
set /A "@arg.val=!@arg.val!" 2^^^>nul%##LF%
(call ))"

:: %#@ARG.REF:ARGNUM=TEST N% (defined) [else (undefined)]
set ^"#@ARG.REF=)else if !@arg.num! ARGNUM (if not defined @arg.key (%##LF%
if !ERRORLEVEL!==0 (set "@arg.val[!@arg.num!]=!@arg.val!") else set "@arg.val[!@arg.num!]=!%%A!"%##LF%
set "@arg.val=@arg.val[!@arg.num!]"%##LF%
(call ))"

:: %#@ARG.LIT_LIT:ARGNUM=TEST N% (defined) [else (undefined)]
set ^"#@ARG.LIT_LIT=)else if !@arg.num! ARGNUM (if defined @arg.key if defined @arg.val (%##LF%
(call ))"


:: %@ARG.TEST%
set ^"@ARG.TEST=for %%# in (1 3 2 1) do if %%#==1 ( %#LF%
%========================================================================% %#LF%
%= SECTION 1  Clear Locals                                              =% %#LF%
for %%V in (%#LF%
@arg.args %#LF%
@arg.keys %#LF%
@arg.vals %#LF%
@arg.num %#LF%
@arg.key %#LF%
@arg.val %#LF%
) do set "%%V=" %#LF%
%========================================================================% %#LF%
%= SECTION 2  Process Macro Args                     =% ) else if %%#==2 ( %#LF%
set "@arg.num=0" ^& (call ) %#LF%
for %%A in (!@arg.args!) do ( %#LF%
  if !ERRORLEVEL!==0 set /A "@arg.num+=1" ^& set "@arg.key=" %#LF%
  set "@arg.val=%%A" %#LF%
  if "!@arg.val:~-1!"==":" ( %#LF%
    set "@arg.key=!@arg.val:~0,-1!" ^& set "@arg.val=" %#LF%
    if !@arg.key!#=="!@arg.key:~1,-1!"# (set "@arg.key=!@arg.key:~1,-1!" ^&(call )) else (call) %#LF%
  ) else ( %#LF%
    if !@arg.val!#=="!@arg.val:~1,-1!"# (set "@arg.val=!@arg.val:~1,-1!" ^&(call )) else (call) %#LF%
  ) %#LF%
  echo Arg: [%%A] %#LF%
  (if 1==0 (call %#LF%
  %#@ARG.LIT:ARGNUM=LEQ 3% %#LF%
  %#@ARG.EXP:ARGNUM=LEQ 6% %#LF%
  %#@ARG.REF:ARGNUM=LEQ 10% %#LF%
  ) else (call)) %#LF%
  if defined @arg.key if defined @arg.val set "@arg.key=" ^& set "@arg.val=" ^& (call ) %#LF%
  if !ERRORLEVEL!==0 ( %#LF%
    if defined @arg.val ( set "@arg.vals=!@arg.vals!:!@arg.val!" ) else set "@arg.vals=!@arg.vals!:""" %#LF%
    if defined @arg.key ( set "@arg.keys=!@arg.keys!:!@arg.key!" ) else set "@arg.keys=!@arg.keys!:""" %#LF%
  ) %#LF%
) %#LF%
set @arg.keys %#LF%
set @arg.vals %#LF%
for /F "tokens=1-9* eol= delims=:" %%1 in ("!@arg.keys!") do ( %#LF%
  for /F "tokens=1-9* eol= delims=:" %%A in ("!@arg.vals!") do ( %#LF%
    echo !TAB! 1=[%%1]!TAB! A=[%%A] %#LF%
    echo !TAB! 2=[%%2]!TAB! B=[%%B] %#LF%
    echo !TAB! 3=[%%3]!TAB! C=[%%C] %#LF%
    echo !TAB! 4=[%%4]!TAB! D=[%%D] %#LF%
    echo !TAB! 5=[%%5]!TAB! E=[%%E] %#LF%
    echo !TAB! 6=[%%6]!TAB! F=[%%F] %#LF%
    echo !TAB! 7=[%%7]!TAB! G=[%%G]=[!%%G!] %#LF%
    echo !TAB! 8=[%%8]!TAB! H=[%%H]=[!%%H!] %#LF%
    echo !TAB! 9=[%%9]!TAB! I=[%%I]=[!%%I!] %#LF%
) ) %#LF%
%========================================================================% %#LF%
%= SECTION 3  Macro Body                                                =% %#LF%
if !@arg.num! GEQ 0 ( %#LF%
(call ) %#LF%
) %#LF%
%========================================================================% %#LF%
%= SECTION 4  Load Macro Args                          =% ) else set @arg.args="



setlocal EnableDelayedExpansion

cls
echo.
set @ARG.TEST
echo.

echo.
echo @ARG.TEST
set "emptyref="
set "ref=dereferenced value"
%@ARG.TEST% str1 "str 2" "" 1 "1+1" "" ref "literal value" emptyref
echo.









