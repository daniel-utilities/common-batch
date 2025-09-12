@echo off
setlocal DisableDelayedExpansion
set "ERRORLEVEL="
((for /L %%P in (1,1,70) do pause>nul)&set /p "TAB=")<"%COMSPEC%" & call set "TAB=%%TAB:~0,1%%"
set ^"LF=^

^"
set "EXC=ERROR:EXC"
set "PCT=ERROR:PCT"
set "empty="
set "1prcnt=1prcnt[%%]"
set "2prcnt=2prcnt[%%PCT%%]"
set "1exclm=1exclm[!]"
set "2exclm=2exclm[!EXC!]"
set "1caret=1caret[^]"
set "2caret=2caret[^^]"
set 1quote=1quote^[^"^]
set "2quote=2quote[""]"
set "1backq=1backq[`]"
set "1tilde=1tilde[`]"
set "1equal=1equal[=]"
set "1exclm=1exclm[!]"
set "1tabch=1tabch[%TAB%]"
set ^"1newln=1newln[^

]"
set "9bad=9bad[=&`|<>)(?]"
setlocal EnableDelayedExpansion
:: #####################################
set "teststrA=string A"
set "teststrB=string B"
set "teststrC=string C"
set "teststr1=!1quote! !9bad! !1prcnt! !2prcnt! !1exclm! !2exclm! !1caret!"
set "teststr2=!1quote! !9bad! !1caret!"
set "teststr3=!1quote! !9bad! !1newln!"
:: #####################################


echo.
echo ########################################################
echo   :generate_str_formatter
echo ########################################################
echo.
set "fmt=[{s}]\t[{s:~-2}]\n[{8#s}]\t[{-8#s:~0,2}]\n[{}]"
echo Format string: "%fmt%"
echo Input variables: a b c d
echo Output variable: out
echo.
call :generate_str_formatter formatter fmt out a b c d
echo String formatter:
set formatter
echo.
echo Applying formatter to input variables...
setlocal enabledelayedexpansion
%formatter%
echo out=!out!
endlocal
echo.


echo.
echo ########################################################
echo   :printvar
echo ########################################################
call :printvar trickystring1 trickystring2 "arr[@]"
echo.

exit /b 0


:: #############################################################################
:: #############################################################################

:: call :printvar VAR1 VAR2 ...
::   Prints the name and value of each variable.
:printvar
:print_var
    setlocal disabledelayedexpansion
    set ^"LF=^

^" 2>nul & rem The formatting of the above two lines are critical. DO NOT REMOVE
    set "__fmt__={s}="{s}""
    set "__formatter__=set "__out__=" & set "_s4=!__name__!"  & set "_s5=!__value__!"  & set "__out__=!_s4!="!_s5!"""
    rem call :generate_str_formatter __formatter__ __fmt__ __out__ __name__ __value__ & set __formatter__
    setlocal enabledelayedexpansion
    for %%a in (%*) do for /F "tokens=1,* delims=@" %%a in ("%%~a") do ( rem Expand wildcard (@) in variable name
        if "%%b"=="" (  rem No wildcard (@) in variable name
            set "__name__=%%a" & set "__value__=!%%a!"
            %__formatter__% & echo !__out__!
        ) else (        rem Wildcard (@) in variable name
            for /F "usebackq tokens=1 delims==" %%n in (`set %%a`) do (
                set "__var__=%%n" & if /I "!__var__!"=="!__var__:%%b=!%%b" (
                    set "__name__=%%n" & set "__value__=!%%n!"
                    %__formatter__% & echo !__out__!
                )
            )
        )
    )
    exit /b 0


:: call :generate_str_formatter FORMATTERV "format" OUTV INV1 INV2 ...
::   Generates a command which formats a string OUTV from one or more input variables INV#.
:generate_str_formatter
    set ^"LF=^

^" 2>nul & rem The formatting of the above two lines are critical. DO NOT REMOVE
    if not defined TAB ((for /L %%P in (1,1,70) do pause>nul)&set /p "TAB=")<"%COMSPEC%" & call set "TAB=%%TAB:~0,1%%"
    setlocal disabledelayedexpansion
    set "_fmtv=%~1" & if not defined _fmtv exit /b 1
    set "_fmts=%~2" & if not defined _fmts exit /b 1
    set "_outv=%~3"
    set "_num=3"                & rem Number of args to skip before assigning substitution variable names
    set "_preops=set "%_outv%="" & rem Command to init all substitution variables.
    set "_postop="              & rem String which will ultimately delay-expand into the correct final value.
    set "SPACES=                                                                                "
    setlocal enabledelayedexpansion
    for %%L in (^"!LF!^") do ( set "toks=!%_fmts%:{=%%~L{!" & set "toks=!toks:}=}%%~L!" )
    for /F "tokens=* delims=" %%a in (^"!toks!^") do (
        if "!!"=="" endlocal
        for /F "tokens=1,* delims={}" %%b in ("%%a") do if "{%%b}"=="%%a" (
            for /F "tokens=1,* delims=#" %%c in ("%%b") do (
                for /F "tokens=1,2,* delims=#:" %%e in ("%%b") do (
                    set /a "_num+=1"
                    if "%%d"=="" ( rem Pad=0   Var=%%e Preop=%%f
                        call set "_var=_%%e%%_num%%"
                        if "%%f"=="" ( set "_pre=" ) else ( set "_pre=:%%f" )
                        set "_pad="
                    ) else (       rem Pad=%%c Var=%%f Preop=%%g
                        call set "_var=_%%f%%_num%%"
                        if "%%g"=="" ( set "_pre=" ) else ( set "_pre=:%%g" )
                        if %%c GTR 0 call set "_pad=& set "%%_var%%=!%%_var%%!%%SPACES%%" & set "%%_var%%=!%%_var%%:~0,%%c!""
                        if %%c LSS 0 call set "_pad=& set "%%_var%%=%%SPACES%%!%%_var%%!" & set "%%_var%%=!%%_var%%:~%%c!""
                    )
                )
            )
            call call set "_src=%%%%~%%_num%%"
            call set "_preops=%%_preops%% & set "%%_var%%=!%%_src%%%%_pre%%!" %%_pad%%"
            call set "_postop=%%_postop%%!%%_var%%!"
        ) else (
            call set "_postop=%%_postop%%%%a"
        )
    )
    set "formatter=%_preops% & set "%_outv%=%_postop%""
    call set "formatter=%%formatter:\t=%TAB%%%"
    call set "formatter=%%formatter:\n=!LF!%%"
    setlocal enabledelayedexpansion
    for /F "tokens=* delims=" %%v in ("!formatter!") do (goto) 2>nul & set "%_fmtv%=%%v" & (call )
    exit /b 1 & rem SHOULD NOT BE HERE


:: #############################################################################
:: #############################################################################


:: call :return [ERRORLEVEL] [VAR1] [VAR2] ...        (Requires: :pushv_popv, :dereference, :escape_for_pct_expansion)
::  Ends the caller's scope (function or script) and copys one or more variables to the caller's parent scope.
:return
    setlocal DisableDelayedExpansion & set "_exitcode_=%ERRORLEVEL%"
    set "_copyvars_=" & for /F "tokens=* delims=-0123456789 " %%a in ("%*") do set "_copyvars_=%%a"
    if not "%_copyvars_%"=="%*" set "_exitcode_=%1"
    set "_switchcmd_=(goto) 2>nul & (goto) 2>nul"
    call :pushv_popv _switchcmd_ _copyvars_ & if "%_exitcode_%"=="0" (call ) else (call)
    echo ERROR: Failed to :return 2>nul & exit /b 99
    
:: call :pushv_popv  "CMD"|CMDV  "VAR1 VAR2..."|VARLISTV    (Requires: :dereference, :escape_for_pct_expansion)
::  Saves some variables, runs a command, then restores the variables to their original values.
:pushv_popv
    setlocal EnableDelayedExpansion
    set ^"__LF__=^

^"& call :dereference __switchcmd__=%%%%1
    call :dereference __copyvars__=%%%%2
    for %%m in (EDE DDE) do set "__setcmd%%m__=(call )!__LF__!" & for %%v in (%__copyvars__%) do (
        set "%%v_%%m=!%%v!" & rem Store separately VAR_EDE and VAR_DDE
        call :escape_for_pct_expansion %%v_%%m %%m
        call :escape_for_pct_expansion %%v_%%m %%m & rem value will be %-expanded twice in the new scope!
        set "__setcmd%%m__=!__setcmd%%m__!set "%%v=!%%v_%%m!"!__LF__!" & rem __setcmdEDE__ and __setcmdDDE__
    )
    (goto) 2>nul &( %__switchcmd__%
                    if "!!"=="" ( %__setcmdEDE__% ) else ( %__setcmdDDE__% ) & rem Copy variables to new scope
                    for %%a in (%__copyvars__%) do if defined %%a ( rem Remove extra double-quotes from each value
                        setlocal EnableDelayedExpansion
                        for /F tokens^=*^ delims^=^ eol^= %%b in ("!%%a:""""="!"^
                        
                        ) do (  endlocal
                                set "%%a=%%b"
    )               )   ) & (call )



:: call :dereference VAR=REF || set "VAR=default value"     (Requires: :escape_for_pct_expansion)
::   Dereferences a variable, copying its value to VAR.
:dereference
    if "!!"=="" ( setlocal DisableDelayedExpansion & set "__mode__=EDE") else ( setlocal DisableDelayedExpansion & set "__mode__=DDE" )
    set "__dstv__=%~1" & if not defined __dstv__ exit /b 1
    (goto) 2>nul &( setlocal DisableDelayedExpansion
                    call set "__src__=%2"
                    set "%__dstv__%="
                    setlocal EnableDelayedExpansion
                    if defined __src__ (
                        if "!__src__:~1,-1!"==!__src__! (   rem PBV (Pass-by-value)
                            set "%__dstv__%=!__src__:~1,-1!"
                            if defined %__dstv__% set "%__dstv__%=!%__dstv__%:""="!"
                        ) else (                            rem PBR (Pass-by-reference)
                            for %%v in (!__src__!) do set "%__dstv__%=!%%v!"
                        )
                    )
                    call :escape_for_pct_expansion %__dstv__% %__mode__%
                    if defined %__dstv__% (
                       for /F tokens^=*^ delims^=^ eol^= %%a in ("!%__dstv__%:""="!"^

                       ) do (   endlocal & endlocal
                                set "%__dstv__%=%%a"
                                (call )
                       )
                    ) else (    endlocal & endlocal
                                set "%__dstv__%="
                                (call)
    )               )

:: call :escape_for_pct_expansion  VAR  DDE|EDE     (Requires: Nothing)
::   Modifies VAR such that "%VAR%" expands to "original contents of VAR" .
:escape_for_pct_expansion
    setlocal EnableDelayedExpansion
    set "var=%~1" & if not defined var exit /b 1
    set "mode=%~2" & if not "!mode!"=="EDE" set "mode=DDE" & rem Default to DDE
    set "val=!%var%!"
    if not defined val ( (goto) 2>nul & set "var=" & (call ) )
    set "val=!val:"=""!"
    goto :__escape_for_pct_expansion_in_%mode%
:__escape_for_pct_expansion_in_EDE
    set "valEDE=!val:^=^^^^!"
    set "valDDE=!val:^=^^!"
    (goto) 2>nul & if "!!"=="" ( rem (copying from EDE to EDE)
        set "%var%=%valEDE:!=^^^!%^!"
    ) else (                     rem (copying from DDE to EDE)
        set "%var%=%valDDE:!=^!%!"
    )
:__escape_for_pct_expansion_in_DDE
    set "valEDE=!val:^=^^!"
    set "valDDE=!val:^=^!"
    (goto) 2>nul & if "!!"=="" ( rem (copying from EDE to DDE)
        set "%var%=%valEDE:!=^!%!"
    ) else (                     rem (copying from DDE to DDE)
        set "%var%=%valDDE:!=!%"
    )


