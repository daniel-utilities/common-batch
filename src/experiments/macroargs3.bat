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

:: %#@ARG.LIT:ARGNUM=TEST N% (DEFINED) [else (UNDEFINED)]
set ^"#@ARG.LIT=)else if !@arg.num! ARGNUM (%##LF%
if defined @arg.key set "@arg.val="%##LF%
if defined @arg.val"

:: %#@ARG.EXP:ARGNUM=TEST N% (DEFINED) [else (UNDEFINED)]
set ^"#@ARG.EXP=)else if !@arg.num! ARGNUM (set /A "@arg.val=!@arg.val!" 2^^^>nul%##LF%
if defined @arg.key set "@arg.val="%##LF%
if defined @arg.val"

:: %#@ARG.REF:ARGNUM=TEST N% (DEFINED) [else (UNDEFINED)]
set ^"#@ARG.REF=)else if !@arg.num! ARGNUM (if !ERRORLEVEL!==1 set "@arg.val=!%%A!"%##LF%
if defined @arg.key set "@arg.val="%##LF%
if defined @arg.val"

:: %#@ARG.LIT_LIT:ARGNUM=TEST N% (DEFINED) [else (UNDEFINED)]
set ^"#@ARG.LIT_LIT=)else if !@arg.num! ARGNUM (%##LF%
if not defined @arg.key set "@arg.val="%##LF%
if defined @arg.val"

:: %#@ARG.LIT_EXP:ARGNUM=TEST N% (DEFINED) [else (UNDEFINED)]
set ^"#@ARG.LIT_EXP=)else if !@arg.num! ARGNUM (set /A "@arg.val=!@arg.val!" 2^^^>nul%##LF%
if not defined @arg.key set "@arg.val="%##LF%
if defined @arg.val"

:: %#@ARG.LIT_REF:ARGNUM=TEST N% (DEFINED) [else (UNDEFINED)]
set ^"#@ARG.LIT_REF=)else if !@arg.num! ARGNUM (if !ERRORLEVEL!==1 set "@arg.val=!%%A!"%##LF%
if not defined @arg.key set "@arg.val="%##LF%
if defined @arg.val"

:: %#@ARG.EXP_LIT:ARGNUM=TEST N% (DEFINED) [else (UNDEFINED)]
set ^"#@ARG.EXP_LIT=)else if !@arg.num! ARGNUM (set /A "@arg.key=!@arg.key!" 2^^^>nul%##LF%
if not defined @arg.key set "@arg.val="%##LF%
if defined @arg.val"

:: %#@ARG.EXP_EXP:ARGNUM=TEST N% (DEFINED) [else (UNDEFINED)]
set ^"#@ARG.EXP_EXP=)else if !@arg.num! ARGNUM (set /A "@arg.key=!@arg.key!" 2^^^>nul ^^^&set /A "@arg.val=!@arg.val!" 2^^^>nul%##LF%
if not defined @arg.key set "@arg.val="%##LF%
if defined @arg.val"

:: %#@ARG.EXP_REF:ARGNUM=TEST N% (DEFINED) [else (UNDEFINED)]
set ^"#@ARG.EXP_REF=)else if !@arg.num! ARGNUM (set /A "@arg.key=!@arg.key!" 2^^^>nul ^^^&if !ERRORLEVEL!==1 set "@arg.val=!%%A!"%##LF%
if not defined @arg.key set "@arg.val="%##LF%
if defined @arg.val"



:: %@ARG.TEST%
set ^"@ARG.TEST=for %%# in (1 3 2 1) do if %%#==1 ( %#LF%
%========================================================================% %#LF%
%= SECTION 1  Clear Locals                                              =% %#LF%
for %%V in ( %#LF%
@arg.args %#LF%
@arg.num %#LF%
@arg.key %#LF%
@arg.val %#LF%
) do set "%%V=" %#LF%
%========================================================================% %#LF%
%= SECTION 2  Process Macro Args                     =% ) else if %%#==2 ( %#LF%
set "@arg.num=0" %#LF%
for %%A in (!@arg.args!) do ( set "@arg.val=%%A" %#LF%
  echo Arg: [!@arg.val!] %#LF%
  if not "!@arg.val:~-1!"==":" ( set /A "@arg.num+=1" %#LF%
    if !@arg.val!=="!@arg.val:~1,-1!" ( set "@arg.val=!@arg.val:~1,-1!" ^&(call ))else (call) %#LF%
    if 1==0 (call %#LF%
    %#@ARG.LIT:ARGNUM=LEQ 3%  ( echo  !@arg.num!:!TAB!val=[!@arg.val!] ) else ( echo  !@arg.num!:!TAB!val is undefined ) %#LF%
    %#@ARG.EXP:ARGNUM=LEQ 6%  ( echo  !@arg.num!:!TAB!val=[!@arg.val!] ) else ( echo  !@arg.num!:!TAB!val is undefined ) %#LF%
    %#@ARG.REF:ARGNUM=LEQ 10% ( echo  !@arg.num!:!TAB!val=[!@arg.val!] ) else ( echo  !@arg.num!:!TAB!val is undefined ) %#LF%
    %#@ARG.LIT_REF:ARGNUM=LEQ 15% ( echo  !@arg.num!:!TAB!key=[!@arg.key!], val=[!@arg.val!] ) else ( echo  !@arg.num!:!TAB!key or val is undefined ) %#LF%
    %#@ARG.EXP_REF:ARGNUM=GEQ 16% ( echo  !@arg.num!:!TAB!key=[!@arg.key!], val=[!@arg.val!] ) else ( echo  !@arg.num!:!TAB!key or val is undefined ) %#LF%
    ) %#LF%
    set "@arg.key=" %#LF%
  ) else ( set "@arg.key=!@arg.val:~0,-1!" %#LF%
    if !@arg.key!#=="!@arg.key:~1,-1!"# set "@arg.key=!@arg.key:~1,-1!" %#LF%
  ) %#LF%
) %#LF%
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
%@ARG.TEST% asdf:=str1 "str 2" "" 1 "1+1" "" emptyref "literal value" var0 "" "key1":=ref key2:="literal value" badkey:=key3:=emptyref "key4":="" :="good val bad key" 1:=ref "1+1":=ref "1+2":="literal value"
echo.









