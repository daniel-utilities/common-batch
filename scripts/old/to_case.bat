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

setlocal EnableDelayedExpansion

echo.
echo ###################################
echo  :to_lowercase
echo ###################################
echo.
set "str=String With Mixed Case"
echo BEFORE: str=!str!
echo :to_lowercase str
call :to_lowercase str
echo AFTER:  str=!str!
echo.
echo ###################################
echo  :to_uppercase
echo ###################################
echo.
set "str=String With Mixed Case"
echo BEFORE: str=!str!
echo :to_uppercase str
call :to_uppercase str
echo AFTER:  str=!str!
echo.

exit /b 0

:: #############################################################################
:: #############################################################################


:: call :to_lowercase STRV      (Requires: :return)
:to_lowercase
    setlocal EnableDelayedExpansion
    set "strv=%~1" & if not defined strv exit /b 1 & if not defined %strv% exit /b 0
    for %%# in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do set "%strv%=!%strv%:%%#=%%#!"
    call :return 0 %strv%

:: call :to_uppercase STRV      (Requires: :return)
:to_uppercase
    setlocal EnableDelayedExpansion
    set "strv=%~1" & if not defined strv exit /b 1 & if not defined %strv% exit /b 0
    for %%# in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do set "%strv%=!%strv%:%%#=%%#!"
    call :return 0 %strv%




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


