@echo off
setlocal DisableDelayedExpansion

:: TAB character (\t)
((for /L %%P in (1,1,70) do pause>nul)&set /p "\t=")<"%COMSPEC%"
set "\t=%\t:~0,1%"

:: LINEFEED character (\n)
set ^"LF=^

^"
:: LINEFEED character (\n) (alt)
set LF=^


set ^"\n=^^^%LF%%LF%^%LF%%LF%^^"

:: ENDLOCAL Macro
::   By Jeb (https://stackoverflow.com/a/29869518/10001931)
:: Calls endlocal, preserving the values of one or more variables across the boundary.
:: Usage:
::   %endlocal% var1 var2 ...
:: 
%=   I use EDE for EnableDelayeExpansion and DDE for DisableDelayedExpansion =%
set ^"endlocal=for %%# in (1 2) do if %%#==2 (%\n%
    setlocal EnableDelayedExpansion%\n%
    %=       Take all variable names into the varName array       =%%\n%
    set varName_count=0%\n%
    for %%a in (!args!) do set "varName[!varName_count!]=%%~a" ^& set /a varName_count+=1%\n%
    %= Build one variable with a list of set statements for each variable delimited by newlines =%%\n%
    %= The lists looks like --> set result1=myContent\n"set result1=myContent1"\nset result2=content2\nset result2=content2\n     =%%\n%
    %= Each result exists two times, the first for the case returning to DDE, the second for EDE =%%\n%
    %= The correct line will be detected by the (missing) enclosing quotes  =%%\n%
    set "retcontent=1!LF!"%\n%
    for /L %%n in (0 1 !varName_count!) do (%\n%
        for /F "delims=" %%C in ("!varName[%%n]!") do (%\n%
            set "content=!%%C!"%\n%
            set "retcontent=!retcontent!"set !varName[%%n]!=!content!"!LF!"%\n%
            if defined content (%\n%
                %= This complex block is only for replacing '!' with '^!'      =%%\n%
                %= First replacing   '"'->'""q'   '^'->'^^' =%%\n%
                set ^"content_EDE=!content:"=""q!"%\n%
                set "content_EDE=!content_EDE:^=^^!"%\n%
                %= Now it's possible to use CALL SET and replace '!'->'""e!' =%%\n%
                call set "content_EDE=%%content_EDE:^!=""e^!%%"%\n%
                %= Now it's possible to replace '""e' to '^', this is effectivly '!' -> '^!'  =%%\n%
                set "content_EDE=!content_EDE:""e=^!"%\n%
                %= Now restore the quotes  =%%\n%
                set ^"content_EDE=!content_EDE:""q="!"%\n%
            ) else set "content_EDE="%\n%
         set "retcontent=!retcontent!set "!varName[%%n]!=!content_EDE!"!LF!"%\n%
      )%\n%
    )%\n%
    echo retcontent=[!retcontent!]%\n%
    %= Now return all variables from retcontent over the barrier =%%\n%
    for /F "delims=" %%V in ("!retcontent!") do (%\n%
        %= Only the first line can contain a single 1 =%%\n%
        if "%%V"=="1" (%\n%
            %= We need to call endlocal twice, as there is one more setlocal in the macro itself =%%\n%
            endlocal%\n%
            endlocal%\n%
        ) else (%\n%
            %= This is true in EDE =%%\n%
            if "!"=="" (%\n%
                if %%V==%%~V (%\n%
                    %%V !%\n%
                )%\n%
            ) else if not %%V==%%~V (%\n%
                %%~V%\n%
            )%\n%
        )%\n%
    )%\n%
) else set args="

setlocal EnableDelayedExpansion
set "SCOPE=ORIGINAL"
set "X="
set "Y="
setlocal EnableDelayedExpansion & echo ^(!SCOPE! Scope^) & echo   X=[!X!] & echo   Y=[!Y!] & endlocal

setlocal EnableDelayedExpansion
set "SCOPE=NEW"
set "X=!LF!"
set "Y="
setlocal EnableDelayedExpansion & echo ^(!SCOPE! Scope^) & echo   X=[!X!] & echo   Y=[!Y!] & endlocal

%endlocal% X Y

setlocal EnableDelayedExpansion & echo ^(!SCOPE! Scope^) & echo   X=[!X!] & echo   Y=[!Y!] & endlocal


exit /b 0

set LF=^


rem ** Two empty lines are neccessary
set recreateLF=^%/n%%/n%
REM The contents of the variables recreateLF and LF are both a single linefeed
setlocal EnableDelayedExpansion
echo 1a: Line1!/n!1b: Line2
echo 2a: hallo%/n%2b: this is lost
(
echo 3a: hallo%/n%echo 3b: this is a legal command
)
set var1=this!/n!works
set "var2=this!/n!works too"
set var3=this%/n%fails
set "var4=this%/n%fails too"
set var5=this^%/n%%/n%works
set "var6=this^%/n%%/n%fails"
set ^"var7=this^%/n%%/n%works again"
endlocal

set ^"\n=^

^" 
set ^"#\n=^^^%\n%%\n%^%\n%%\n%^^"

set ^"##\n=^^^^^^^%\n%%\n%^%\n%%\n%^^^%\n%%\n%^%\n%%\n%^^^^^^"

set "_var=\n" & setlocal EnableDelayedExpansion
for %%L in ("!\n!") do for %%V in ("%_var%" "#var") do (
    set ^"#var=!%%~V:^^=^^^^!"
    set ^"#var=!#var:%%~L=^^%%~L%%~L!!__c__!"
)
endlocal & set ^"#%_var%=%#var%"

set "_var=#\n" & setlocal EnableDelayedExpansion
for %%L in ("!\n!") do for %%V in ("%_var%" "#var") do (
    set ^"#var=!%%~V:^^=^^^^!"
    set ^"#var=!#var:%%~L=^^%%~L%%~L!^^^^"
)
endlocal & set ^"#%_var%=%#var%"

set "_var=##\n" & setlocal EnableDelayedExpansion
for %%L in ("!\n!") do for %%V in ("%_var%" "#var") do (
    set ^"#var=!%%~V:^^=^^^^!"
    set ^"#var=!#var:%%~L=^^%%~L%%~L!!__c__!"
)
endlocal & set ^"#%_var%=%#var%"

setlocal EnableDelayedExpansion & echo. & echo \n=[!\n!] & endlocal
setlocal EnableDelayedExpansion & echo. & echo #\n=[!#\n!] & endlocal
setlocal EnableDelayedExpansion & echo. & echo ##\n=[!##\n!] & endlocal
setlocal EnableDelayedExpansion & echo. & echo ###\n=[!###\n!] & endlocal


set  ###EMBED3=echo line3     %###\n%
               echo line4     

set ##EMBED2=echo line2       %##\n%
             (                %##\n%
               %###EMBED3%    %##\n%
             )                %##\n%
             echo line5       

set #EMBED1=echo line1        %#\n%
           (                  %#\n%
             %##EMBED2%       %#\n%
           )                  %#\n%
           echo line6  

echo.
setlocal EnableDelayedExpansion & echo. & echo ###EMBED3=[!###EMBED3!] & endlocal
setlocal EnableDelayedExpansion & echo. & echo  ##EMBED2=[!##EMBED2!] & endlocal
setlocal EnableDelayedExpansion & echo. & echo   #EMBED1=[!#EMBED1!] & endlocal



exit /b 0


:: ##-macros are doubly-escaped, for use inside other macros only!
set ##EDE=setlocal EnableDelayedExpansion ^^^& set /A "#localdepth+=1"
set ##DDE=setlocal DisableDelayedExpansion ^^^& set /A "#localdepth+=1"
set ###EDE=setlocal EnableDelayedExpansion ^^^^^& set /A "#localdepth+=1"
set ###DDE=setlocal DisableDelayedExpansion ^^^^^& set /A "#localdepth+=1"
set ##ENDLOCALS=( for /L %%i in (!#localdepth! -1 0) do endlocal )

:: NAME  is a globally-defined constant.
:: #NAME is a globally-defined macro.
:: name  is a locally-defined variable.
:: #name is a locally-defined variable in a macro scope.

set #TEST=for /L %%# in (1 1 2) do if %%#==2 (%#\n%
    %##EDE%                                   %#\n%
    echo #localdepth=!#localdepth!            %#\n%
    echo #callenv=!#callenv!                  %#\n%
    for %%A in (!#args!) do (                 %#\n%
        echo %%A=!%%A!                        %#\n%
    )                                         %#\n%
    %##ENDLOCALS%                             %#\n%
) else (                                      %#\n%
    setlocal ^& set "#localdepth=0"           %#\n%
    if "!!"=="" ( set "#callenv=EDE" ) else ( set "#callenv=DDE" ) %#\n%
) ^& set #args=

set "var1=asdf1"
set "var2=asdf2"
rem setlocal EnableDelayedExpansion & echo !#TEST! & endlocal
%#TEST% var1 var2

echo.
setlocal EnableDelayedExpansion & echo #TEST=!#TEST! & endlocal
