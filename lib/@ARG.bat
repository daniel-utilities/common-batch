::.SYNOPSIS
::  SCRIPT HELP TEXT
::
@echo off & goto :.%1 1>nul 2>nul || cmd /d /c man.bat "%~f0" "Usage"
exit /b 0


%============================= SECTION =============================%  goto :EOF
:./import
:.--import
::  SECTION HELP TEXT
::
if "!!"=="" ( echo ERROR: Macro definition requires DisableDelayedExpansion. 1>&2 & goto :__failure )
::------------------------------------------------------------------------------

set "ERRORLEVEL="
set ^"LF=^
%= EMPTY LINE =%
^"
set    ^"#LF=^^^%LF%%LF%^%LF%%LF%^"
set   ^"#EOL=^^^%LF%%LF%^"          %= User provides the missing LF when expanding this at the end of a macro line =%
set   ^"##LF=^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^"
set  ^"##EOL=^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^"
set  ^"###LF=^^^^^^^^^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^"
set ^"###EOL=^^^^^^^^^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^"

((for /L %%A in (1,1,70) do pause>nul) & set /p "TAB=")<"%COMSPEC%"
set "TAB=%TAB:~0,1%"

set "TRUE=0"
set "FALSE=1"

::.#@ARG.FOREACH        (Requires EDE; Embeddable)
::. @ARG.FOREACH        (Requires EDE)
::  %<title>:{VAR}=args% ( echo %%A )
::    Runs the () code block for each "argument" in a variable called args.
::    Sets loop variable %%A for each iteration.
::    See @ARG.PARSE for argument formatting rules.
::
set ^"#@ARG.FOREACH=(%##EOL%
set "#@arg.tmp=" ^^^& set "#@arg.numq=0"%##EOL%
if defined {VAR} for /F delims^^^^=^^^^ eol^^^^= %%T in (^^^^^^^"!{VAR}:"="%###LF%!^^^^^^^") do (%##EOL%
  set /A "#@arg.numq=(#@arg.numq+1) %% 2"%##EOL%
  set "#@arg.tok=%%T"!%##EOL%
  if !#@arg.numq!==1 ( set ^^^^^^^"#@arg.tok=!#@arg.tok: =%###LF%!^^^^^^^"%##EOL%
  %=                =% set ^^^^^^^"#@arg.tok=!#@arg.tok:%TAB%=%###LF%!^^^^^^^"%##EOL%
  )%##EOL%
  set "#@arg.tmp=!#@arg.tmp!!#@arg.tok!"%##EOL%
)%##EOL%
set "#@arg.tok=" ^^^& set "#@arg.numq="%##EOL%
) ^^^& for /F delims^^^^=^^^^ eol^^^^= %%A in ("!#@arg.tmp:^^^^^^^^%%=%%!") do set "#@arg.tmp=" ^^^&"


set ^"@ARG.FOREACH=%#@ARG.FOREACH%"


::.@ARG.PARSE
::  %<title>% STRINGVAR MAPVAR [/append]
::    Splits a string into arguments, storing each in a uniquely-named variable.
::
::.<title>:Detail
::  Formatting:
::    Arguments must be separated by tabs or spaces, and may be formatted as:
::      ARGUMENT                TYPE                 RESULT
::      value                   Positional arg   --> MAPVAR[1]=value
::      "val with spaces"       Positional arg   --> MAPVAR[2]=valwith spaces
::      ""                      Empty positional --> MAPVAR[3]=
::      /flg1=value             Flag with value  --> MAPVAR[flg1]=value
::      /flg2="val with space"  Flag with value  --> MAPVAR[flg2]=val with space
::      /flg3                   Empty flag       --> MAPVAR[flg3]=
::      /flg4=                  Empty flag       --> MAPVAR[flg4]=
::      /flg5=""                Empty flag       --> MAPVAR[flg5]=
::
::    Double quotes {"} should always be escaped as {""}.
::    Command-line arguments should use normal escaping rules for special
::      characters, in order for them to survive the initial {%*} expansion:
::        {%}   -->   {^%}
::        { ^ & < > | ( ) }   -->   { ^^ ^& ^< ^> ^| ^( ^) }  if not in quotes
::    Flags may also look like:
::        /flag:...
::       --flag=...
::       --flag:...
::
::  Special Variables:
::    The above set of arguments would also result in the following variables:
::
::      MAPVAR[#]=3
::        The total number of positional arguments.
::
::      MAPVAR=MAPVAR MAPVAR[#] MAPVAR[1] MAPVAR[2] MAPVAR[3] MAPVAR[flg1] ...
::        A space-separated list of variables associated with this map.
::
::  Append Mode (/append) vs Overwrite Mode (default):
::    In Overwrite Mode, if multiple arguents are specified with the same name,
::    only the last value will be stored:
::      /1="default"  "new value"  -->   MAPVAR[1]=new value
::
::    In Append Mode each value is stored on a new line under the same variable:
::      /1="default"  "new value"  -->   MAPVAR[1]=default
::                                                 new value
::  Example usage:
::    Parse command line arguments into a map called "args":
::
::      setlocal DisableDelayedExpansion
::      set ^"argstr= /1="default value" %*"
::      setlocal EnableDelayedExpansion
::      %<title>% argstr args
::
::    Print all positional args:
::
::      for /L %%i in (1,1,!args[#]!) do echo(!args[%%i]!
::
::    Check if the /? flag was specified:
::
::      if not "!args:args[?]=!"=="!args!" ( %= flag was specified =% )
::
::    Undefine the map:
::
::      for %%V in (!args!) do set "%%V="
::
set ^"@ARG.PARSE=for %%# in (2 1) do if %%#==1 ( %#EOL%
for /F "tokens=1-3" %%1 in ("!@arg.args!") do if not "%%2"=="" (%#EOL%
%= Arg 1 = variable containing arg string. =% %#EOL%
  set "@arg.str=!%%1!"%#EOL%
%= Arg 2 = Map variable name               =% %#EOL%
%= Arg 3 = /append, or empty to overwrite  =% %#EOL%
  if not defined %%2 (%= Initialize the map =%%#EOL%
    set "%%2=%%2 %%2[#]"%#EOL%
    set "%%2[#]=0"%#EOL%
  )%#EOL%
%= Escape '^' and '!' for 2x percent-expansion in EDE =% %#EOL%
  if defined @arg.str (%#EOL%
    set ^"@arg.str=!%%1:"=""q!"%#EOL%
    set "@arg.str=!@arg.str:^=^^^^^^^^!"%#EOL%
    call set "@arg.str=%%@arg.str:^!=""e^!%%"%#EOL%
    set "@arg.str=!@arg.str:""e=^^^^^^^!"%#EOL%
    set ^"@arg.str=!@arg.str:""q="!"%#EOL%
  )%#EOL%
%= For each arg, check if it's a flag. If not, prepend a numbered flag to it. =% %#EOL%
  set "@arg.tmp="%#EOL%
  %#@ARG.FOREACH:{VAR}=@arg.str% (%#EOL%
    set "@arg.tok=%%A"!%#EOL%
    if "!@arg.tok:~0,1!"=="/" (set "@arg.tmp=!@arg.tmp!!@arg.tok!!LF!"%#EOL%
    ) else if "!@arg.tok:~0,1!"=="-" (set "@arg.tmp=!@arg.tmp!!@arg.tok!!LF!"%#EOL%
    ) else (set /A "%%2[#]+=1" ^& set "@arg.tmp=!@arg.tmp!/!%%2[#]!=!@arg.tok!!LF!")%#EOL%
    )%#EOL%
%= For each arg, store as a variable. =% %#EOL%
  for /F "tokens=1* eol=/ delims=/-=:" %%A in ("!@arg.tmp!") do (%#EOL%
    set "@arg.tok=%%~B"!%#EOL%
    if defined @arg.tok set ^^^"@arg.tok=!@arg.tok:^^^"^^^"^^=^^^"!^^^"%#EOL%
    if "!%%2:%%2[%%A]=!"=="!%%2!" (%= Var not defined =%%#EOL%
      set "%%2=!%%2! %%2[%%A]"%#EOL%
      set "%%2[%%A]=!@arg.tok!"%#EOL%
    ) else if /i "%%3"=="/append" (%= Var already defined, append mode =%%#EOL%
      set "%%2[%%A]=!%%2[%%A]!!LF!!@arg.tok!"%#EOL%
    ) else (%= Var already defined, overwrite mode =%%#EOL%
      set "%%2[%%A]=!@arg.tok!"%#EOL%
    )%#EOL%
  )%#EOL%
)%#EOL%
set "@arg.args="%#EOL%
set "@arg.str="%#EOL%
set "@arg.tok="%#EOL%
set "@arg.tmp="%#EOL%
) else set @arg.args="
if %ERRORLEVEL% NEQ 0 goto :__failure


::------------------------------------------------------------------------------
:__success
set "IMPORTS=%~n0 %IMPORTS%"
exit /b 0
:__failure
echo ERROR: %~n0 Import failed 1>&2
exit /b 1
%=========================== END SECTION ===========================%  goto :EOF


%============================= SECTION =============================%  goto :EOF
:./TEST
:.-TEST
:.--TEST
::  SECTION HELP TEXT
::
setlocal DisableDelayedExpansion
call "%~f0" /import || goto :__failure
set ^"args=%*^"
if not defined args set "args=abc !TRUE! "!FALSE!" & ^ "%TAB%de f"  /ghi -jkl=mno --pqr="st  u" %TAB%"" """"  /?  "
::------------------------------------------------------------------------------

echo.
set @ARG.PARSE
echo.

setlocal EnableDelayedExpansion
echo #######################################################
echo %%@ARG.PARSE%% args args
echo IN:  args=^[!args!^]
%@ARG.PARSE% args args

echo.
for %%V in (!args! !args.pos! !args.flg!) do (
  echo OUT: %%V=^[!%%V!^]
)
echo.

if defined args.flg[?] echo HELP FLAG DETECTED

::------------------------------------------------------------------------------
:__success
exit /b 0
:__failure
exit /b 1
%=========================== END SECTION ===========================%  goto :EOF
