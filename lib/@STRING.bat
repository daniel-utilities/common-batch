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

:: Special characters
::  ((for /L %%a in (1,1,70) do pause>nul) & set /p "TAB=")<"%COMSPEC%"
::  set "TAB=%TAB:~0,1%"
::  for /f %%a in ('copy /Z %COMSPEC% nul') do set "CR=%%a"
::  for /f "tokens=1 delims=#" %%a in ('"prompt #$H# & echo on & for %%b in (1) do rem"') do set "BS=%%a"
::  set "BS=%BS:~0,1%"
::  for /f %%a in ('cls') do set "FF=%%a"
::  for /f %%a in ('forfiles /m "%~nx0" /c "cmd /c echo 0x1B"') do set "ESC=%%a"

::.@STRING.PRINT          (Embeddable, Expandable in DDE)
::  Print the contents of a variable, without the usual linefeed.
::.@STRING.PRINTLN        (Embeddable, Expandable in DDE)
::  Print the contents of a variable, followed by a linefeed (similar to ECHO).
::
::  %<title>:{VAR}=strv%                 Print value of variable strv
::  %<title>:!{VAR}!=string literal%     Print a string literal
::  %<title>: ... % 1>&2                 Redirect to error stream
set ^"@STRING.PRINTLN=(setlocal EnableDelayedExpansion%##EOL%
echo(!{VAR}!%##EOL%
endlocal)"

set ^"@STRING.PRINT=(setlocal EnableDelayedExpansion%##EOL%
<nul set /P "#@STRING.PRINT.temp=!{VAR}!"%##EOL%
endlocal)"

::.@STRING.PRINT_DEBUG    (Embeddable, Expandable in DDE)
::  Print the contents of a variable, including the variable name.
::  See usage examples for @STRING.PRINT.
set ^"@STRING.PRINTLN=(setlocal EnableDelayedExpansion%##EOL%
echo({VAR}=[!{VAR}!]%##EOL%
endlocal)"

::.@STRING.TOLOWERCASE
::.#@STRING.TOLOWERCASE
::  %<title>:{VAR}=strv%  -->  strv
set ^"#@STRING.TOLOWERCASE=for %%X in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do if defined {VAR} set "{VAR}=!{VAR}:%%X=%%X!""


::  %<title>% STRV [STRV2] ...  -->  STRV [STRV2] ...
set ^"@STRING.TOLOWERCASE=for %%# in (2 1) do if %%#==1 ( %#EOL%
for %%V in (!@str.vars!) do ( %#EOL%
  set "@str.val=!%%V!" %#EOL%
  %#@STRING.TOLOWERCASE:{VAR}=@str.val% %#EOL%
  set "%%V=!@str.val!" %#EOL%
) %#EOL%
set "@str.vars=" ^& set "@str.val=" %#EOL%
) else set @str.vars= "


::.#@STRING.LENGTH
::  %#<title>:{VAR}=strv%  -->  strv.len
::  Based on: https://ss64.org/viewtopic.php?f=2&t=17
set ^"#@STRING.LENGTH=set "{VAR}.len=0" ^^^& set "@str.tmp=_!{VAR}!" %##EOL%
for %%N in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do if not "!@str.tmp:~%%N,1!"=="" ( %##EOL%
set /A "{VAR}.len+=%%N" %##EOL%
set "@str.tmp=!@str.tmp:~%%N!" %##EOL%
) %##EOL%
set "@str.tmp=""


::.@STRING.LENGTH
::  %<title>% STRV [STRV2] ...  -->  STRV.len [STRV2.len] ...
set ^"@STRING.LENGTH=for %%# in (2 1) do if %%#==1 ( %#EOL%
for %%V in (!@str.vars!) do ( %#EOL%
  set "@str.val=!%%V!" %#EOL%
  %#@STRING.LENGTH:{VAR}=@str.val% %#EOL%
  set "%%V.len=!@str.val.len!" %#EOL%
) %#EOL%
set "@str.vars=" ^& set "@str.val=" ^& set "@str.val.len=" %#EOL%
) else set @str.vars= "


::.#@STRING.COUNT
::  %#<title>:{VAR},{VAR}=strv,subv%  -->  strv.cnt.subv
set ^"#@STRING.COUNT=for /F "tokens=1-2 delims=;, " %%U in ("{VAR},{VAR}") do (%##EOL%
 set "%%U.cnt.%%V=0"%##EOL%
 if defined %%U for %%L in ("!LF!") do for /F delims^^^^=^^^^ eol^^^^= %%W in ("!%%V!") do (%##EOL%
  set "%%U.cnt.%%V=-1"%##EOL%
  for /F delims^^^^=^^^^ eol^^^^= %%N in ("!%%U:%%W=#%%~L!#") do set /A "%%U.cnt.%%V+=1"%##EOL%
 )%##EOL%
)"


::.@STRING.COUNT
::  %<title>%  (STRV,SUBV)  [(STRV2,SUBV2)] ...  -->  STRV.cnt.SUBV  [STRV2.cnt.SUBV2] ...
set ^"@STRING.COUNT=for %%# in (2 1) do if %%#==1 ( %#EOL%
for /F "tokens=1-2 delims=;" %%U in (^^^"!@str.vars:^^ ^^=%##LF%!^^^") do ( %#EOL%
  set "@str.str=!%%U!" %#EOL%
  set "@str.sub=!%%V!" %#EOL%
  %#@STRING.COUNT:{VAR},{VAR}=@str.str,@str.sub% %#EOL%
  set "%%U.cnt.%%V=!@str.str.cnt.@str.sub!" %#EOL%
) %#EOL%
set "@str.vars="^& set "@str.str="^& set "@str.sub="^& set "@str.str.cnt.@str.sub=" %#EOL%
) else set @str.vars= "


set ^"#@STRING.ESCAPE_FOR_PCT_EXPAND_IN_EDE_1X=if defined {VAR} (%##EOL%
set ^^^"{VAR}=!{VAR}:"=""q!"%##EOL%
set "{VAR}=!{VAR}:^=^^^^!"%##EOL%
call set "{VAR}=%%{VAR}:^!=""e^!%%"%##EOL%
set "{VAR}=!{VAR}:""e=^^^!"%##EOL%
set ^^^"{VAR}=!{VAR}:""q="!"%##EOL%
)"


set ^"@STRING.ESCAPE_FOR_PCT_EXPAND_IN_EDE_1X=%#@STRING.ESCAPE_FOR_PCT_EXPAND_IN_EDE_1X%"


set ^"#@STRING.ESCAPE_FOR_PCT_EXPAND_IN_EDE_2X=if defined {VAR} (%##EOL%
set ^^^"{VAR}=!{VAR}:"=""q!"%##EOL%
set "{VAR}=!{VAR}:^=^^^^^^^^!"%##EOL%
call set "{VAR}=%%{VAR}:^!=""e^!%%"%##EOL%
set "{VAR}=!{VAR}:""e=^^^^^^^!"%##EOL%
set ^^^"{VAR}=!{VAR}:""q="!"%##EOL%
)"


set ^"@STRING.ESCAPE_FOR_PCT_EXPAND_IN_EDE_2X=%#@STRING.ESCAPE_FOR_PCT_EXPAND_IN_EDE_2X%"


set ^"#@STRING.ESCAPE_FOR_PCT_EXPAND_IN_EDE_3X=if defined {VAR} (%##EOL%
set ^^^"{VAR}=!{VAR}:"=""q!"%##EOL%
set "{VAR}=!{VAR}:^=^^^^^^^^^^^^^^^^!"%##EOL%
call set "{VAR}=%%{VAR}:^!=""e^!%%"%##EOL%
set "{VAR}=!{VAR}:""e=^^^^^^^^^^^^^^^!"%##EOL%
set ^^^"{VAR}=!{VAR}:""q="!"%##EOL%
)"


set ^"@STRING.ESCAPE_FOR_PCT_EXPAND_IN_EDE_3X=%#@STRING.ESCAPE_FOR_PCT_EXPAND_IN_EDE_3X%"


echo.
echo #######################################################
set #@STRING.COUNT
echo.

setlocal EnableDelayedExpansion
echo #######################################################
echo %%@STRING.LENGTH%% str1 str2 str3
set "str1=ab cd"
set "str2=01234567899876543210"
set "str3="
echo.
echo IN:  str1: [!str1!]
echo IN:  str2: [!str2!]
echo IN:  str3: [!str3!]
%@STRING.LENGTH:{VAR}=str% str1 str2 str3
echo.
echo OUT: str1.len: [!str1.len!]
echo OUT: str2.len: [!str2.len!]
echo OUT: str3.len: [!str3.len!]
echo.


echo #######################################################
echo %%@STRING.COUNT%% str1;sub str2;sub str3;sub
set "str1=a string "with quotes"" hmm"
set "str2=""""""""""""""""""""""""""""""""""""""""""""""""
set "str3="
set "sub=""
echo.
echo IN:  str1: [!str1!]
echo IN:  str2: [!str2!]
echo IN:  str3: [!str3!]
echo IN:  sub=!sub!
echo.
%@STRING.COUNT% str1;sub str2;sub str3;sub
echo OUT: str1.cnt.sub: [!str1.cnt.sub!]
echo OUT: str2.cnt.sub: [!str2.cnt.sub!]
echo OUT: str3.cnt.sub: [!str3.cnt.sub!]
echo.


echo #######################################################
echo %%@STRING.TOLOWERCASE%% str1 str2 str3
set "str1=a String WITH "Many Uppercase Letters""
set "str2=aNoThEr UppErcaSe String "
set "str3="
echo.
echo IN:  str1: [!str1!]
echo IN:  str2: [!str2!]
echo IN:  str3: [!str3!]
echo.
%@STRING.TOLOWERCASE% str1 str2 str3
echo OUT: str1: [!str1!]
echo OUT: str2: [!str2!]
echo OUT: str3: [!str3!]
echo.
echo #######################################################

exit /b 0
