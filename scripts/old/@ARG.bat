::.SYNOPSIS
::  SCRIPT HELP TEXT
::  
@echo off
goto :.%~1 2>nul || call "man.bat" "%~f0" %2 %3 %4 %5 %6 %7 %8 %9


%============================= SECTION =============================%  goto :EOF
:./IMPORT
:.-IMPORT
:.--IMPORT
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

((for /L %%a in (1,1,70) do pause>nul) & set /p "TAB=")<"%COMSPEC%"
set "TAB=%TAB:~0,1%"

set "TRUE=0"
set "FALSE=1"

::.PARSE
:: %@ARG.PARSE%  ARRV  ARGV   -->   Array:ARRV  Array:ARRV.pos  Map:ARRV.flg
set ^"@ARG.PARSE=if not "!!"=="" (echo ERROR: Macro @ARG.PARSE requires EnableDelayedExpansion. 1^>^&2 ^&(call)%#EOL%
) else for %%# in (1 3 2 1) do if %%#==1 ( %#EOL%
%========================================================================% %#EOL%
%= SECTION 1  Clear Locals                                              =% %#EOL%
for %%V in ( %#EOL%
args %#EOL%
nquot %#EOL%
A %#EOL%
B %#EOL%
C %#EOL%
D %#EOL%
name %#EOL%
key %#EOL%
val %#EOL%
) do set "@arg.%%V=" %#EOL%
%========================================================================% %#EOL%
%= SECTION 2   Process macro params   =% ) else if %%#==2 ( %#EOL%
%=   P    array name prefix                                             =% %#EOL%
%=   Q    variable containing arguments to parse                        =% %#EOL%
for /F "tokens=1,2" %%P in ("!@arg.args!") do for %%L in ("!LF!") do ( %#EOL%
  set "%%P=%%P %%P[#]" ^& set "%%P[#]=0" %#EOL%
  set "%%P.pos=%%P.pos %%P.pos[#]" ^& set "%%P.pos[#]=0" %#EOL%
  set "%%P.flg=%%P.flg %%P.flg[#]" ^& set "%%P.flg[#]=0" %#EOL%
  set "@arg.args=!%%Q!" %#EOL%
  if defined @arg.args ( %#EOL%
    %= Double-escape '^' and '!' for percent-expansion  =% %#EOL%
    set ^"@arg.args=!@arg.args:"=""q!"%#EOL%
    set "@arg.args=!@arg.args:^=^^^^!"%#EOL%
    call set "@arg.args=%%@arg.args:^!=""e^!%%"%#EOL%
    set "@arg.args=!@arg.args:""e=^^^!"%#EOL%
    set ^"@arg.args=!@arg.args:""q="!"%#EOL%
%========================================================================% %#EOL%
%= OUTER LOOP  Split argstring into individual args                     =% %#EOL%
set "@arg.args=!@arg.args: =%%~L %%~L!" %#EOL%
set "@arg.args=!@arg.args:%TAB%=%%~L%TAB%%%~L!" %#EOL%
for /F delims^^=^^ eol^^= %%T in ("!@arg.args!") do ( %#EOL%
  set "@arg.arg=!@arg.arg!%%T" %= Append token T to arg % ^!%#EOL%
  set "@arg.nquot=-1" %= Count number of doublequotes in arg =% %#EOL%
  for /F delims^^=^^ eol^^= %%N in (^^^"!@arg.arg:^^^"^^=^^^"%##LF%!^^ ^^^") do set /A "@arg.nquot+=1" %#EOL%
  set /A "@arg.nquot%%=2" %= Arg is complete if even number of doublequotes =% %#EOL%
  if !@arg.nquot!==0 ( %= Filter invalid/empty args, then identify if arg is positional or flag arg =% %#EOL%
    for /F "tokens=* delims=%TAB% eol= " %%A in ("!@arg.arg!") do ( set "@arg.A=%%A" ^!%#EOL%
      for /F "tokens=* delims=/-%TAB% eol= " %%B in ("!@arg.arg!") do ( set "@arg.B=%%B" ^!%#EOL%
        for /F "tokens=1* delims==/-%TAB% eol= " %%C in ("!@arg.arg!") do ( set "@arg.C=%%C" ^& set "@arg.D=%%D" ^!%#EOL%
%========================================================================% %#EOL%
%= INNER LOOP  Process individual args                                  =% %#EOL%
set /A "%%P[#]+=1" %#EOL%
set "%%P[!%%P[#]!]=!@arg.A!" %#EOL%
set "%%P=!%%P! %%P[!%%P[#]!]" %#EOL%
if "!@arg.A!"=="!@arg.B!" ( %#EOL%
  set "@arg.name=%%P.pos" %#EOL%
  set /A "!@arg.name![#]+=1" %#EOL%
  set "@arg.key=!%%P.pos[#]!" %#EOL%
  set "@arg.val=!@arg.B!" %#EOL%
) else ( %#EOL%
  set "@arg.name=%%P.flg" %#EOL%
  set /A "!@arg.name![#]+=1" %#EOL%
  set "@arg.key=!@arg.C!" %#EOL%
  set "@arg.val=!@arg.D!" ^& if not defined @arg.val set "@arg.val=%TRUE%" %#EOL%
) %#EOL%
if defined @arg.val if "!@arg.val:~1,-1!"==!@arg.val!  set "@arg.val=!@arg.val:~1,-1!" %#EOL%
if defined @arg.val set ^^^"@arg.val=!@arg.val:^^^"^^^"^^=^^^"!^^^" %#EOL%
for %%N in (!@arg.name!) do ( %#EOL%
  set "%%N=!%%N! %%N[!@arg.key!]" %#EOL%
  set "%%N[!@arg.key!]=!@arg.val!" %#EOL%
) %#EOL%
%========================================================================% %#EOL%
          ) %#EOL%
        ) %#EOL%
      ) %#EOL%
      set "@arg.arg=" %#EOL%
    ) %#EOL%
  ) %#EOL%
%========================================================================% %#EOL%
  ) %#EOL%
) %#EOL%
%========================================================================% %#EOL%
%= SECTION 3  Read Args as String                     =% ) else set @arg.args= "
%= END MACRO DEFINITION =%
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
