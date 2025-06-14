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



setlocal DisableDelayedExpansion


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
) ^^^& for /F delims^^^^=^^^^ eol^^^^= %%A in ("!#@arg.tmp!") do set "#@arg.tmp=" ^^^&"


set ^"@ARG.FOREACH=%#@ARG.FOREACH%"


set ^"@ARG.PARSE=for %%# in (2 1) do if %%#==1 ( %#EOL%
for /F "tokens=1-3" %%1 in ("!@arg.args!") do if not "%%2"=="" (%#EOL%
%= Arg 1 = variable containing arg string. =% %#EOL%
  set "@arg.str=!%%1!"%#EOL%
%= Arg 2 = array name                      =% %#EOL%
%= Arg 3 = /append or empty to overwrite   =% %#EOL%
  if not defined %%2 (%= Array not defined =%%#EOL%
    set "%%2=%%2 %%2[#]"%#EOL%
    set "%%2[#]=0"%#EOL%
  ) else if /i "%%3"=="/append" (%= Array already defined, append mode =%%#EOL%
    (call )%= No-op =%%#EOL%
  ) else (%= Array already defined, overwrite mode =%%#EOL%
    for %%V in (!%%2!) do set "%%V="%#EOL%
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



set str=pos1%TAB%"""pos 2"""   """"  " "" "  """ """  /flg1 -flg2=!flg2val! /flg2= /flg2="""" --flg3:">%TAB%!flg3val!%TAB%<" /flg4="" /flg5:"""" /flg6=   
set "str="

setlocal EnableDelayedExpansion
echo(
echo(
%@ARG.PARSE% str args /append
%@ARG.PARSE% str args /append
%@ARG.PARSE% str args

echo(
for %%V in (str !args!) do echo(%%V=[!%%V!]
endlocal
endlocal

exit /b 0



setlocal DisableDelayedExpansion
set "str=pos1 "pos 2"  "" /flg1 /flg2=flg2val /flg3=" flg3 val" /flg4="" /flg5="
set "args=args args[#]"
set "args[#]=0"

setlocal EnableDelayedExpansion
%= Split on quotes. Replace spaces with {sp}, but only within pairs of doublequotes. =%
set "__pct=%%"
set "__numq=0"
set "__tmp1="
set "__tok=%str:"=" & set /A "__numq=(__numq+1)!__pct!2" & ( if !__numq!==0 ( set "__tok="!__tok!"" & set "__tok=!__tok: ={sp}!" )) & set "__tmp1=!__tmp1!!__tok!" & set "__tok=% " & set "__tmp1=!__tmp1!!__tok!"

%= Split on spaces. Add numbered flags to positional arguments, insert linefeeds between args, replace {sp} with spaces =%
set "__tmp2="
set "__tok=%__tmp1: =" & ( if defined __tok ( (if not "!__tok:~0,1!"=="/" (set /A "args[#]+=1" & set "__tok=/!args[#]!=!__tok!")) & set "__tmp2=!__tmp2!!__tok:{sp}= !!LF!" ) ) & set "__tok=%"

for /F "tokens=1* eol=  delims=/=" %%A in ("!__tmp2!") do (
    set "args=!args! args[%%A]"
    set "args[%%A]=%%~B"
)


:: Result should be:
::  args=args args[#] args[1] args[2] args[3] args[flg1] args[flg2] args[flg3] args[flg4]
::  args[#]=3
::  args[1]=pos1
::  args[2]=pos 2
::  args[3]=
::  args[flg1]=
::  args[flg2]=flg2val
::  args[flg3]= flg3 val
::  args[flg4]=
::  
for %%V in (str !args!) do echo(%%V=!%%V!

endlocal
endlocal



setlocal EnableDelayedExpansion
set "str=,item2,item3,item4,,item6,,item8"

%= COUNT occurrances of substring in str =%
set "cnt=0" & if defined str ( set "_tmp=%str:item=" & set /A cnt+=1 & set "_tmp=%" & set "_tmp=")

echo(
echo(str=!str!
echo(sub=item
echo(cnt=!cnt!
endlocal

setlocal EnableDelayedExpansion
set "str=,item2,item3,item4,,item6,,item8"

%= SPLIT string str on ',' into array arr =%
set "arr=arr arr[#]" & if defined str ( set "arr[#]=1" & set "arr=!arr! arr[!arr[#]!]" & set "arr[!arr[#]!]=%str:,=" & set /A arr[#]+=1 & set "arr=!arr! arr[!arr[#]!]" & set "arr[!arr[#]!]=%" ) else ( set "arr[#]=0" )

echo(
echo(str=!str!
echo(arr=!arr!
echo(  arr[#]=!arr[#]!
for /L %%i in (1 1 !arr[#]!) do echo(  arr[%%i]=!arr[%%i]!
endlocal




endlocal
exit /b 0