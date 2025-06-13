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

cls
setlocal EnableDelayedExpansion
echo.
echo ###################################
echo  :contains
echo ###################################
echo.
echo :contains    "string with 20 chars" "with"
call :contains    "string with 20 chars" "with" && echo TRUE || echo FALSE
echo.
echo :contains    "string with 20 chars" "WITH"
call :contains    "string with 20 chars" "WITH" && echo TRUE || echo FALSE
echo.
echo :contains    "string with 20 chars" "diff"
call :contains    "string with 20 chars" "diff" && echo TRUE || echo FALSE
echo.
echo :contains /i "string with 20 chars" "with"  ^(case insensitive^)
call :contains /i "string with 20 chars" "with" && echo TRUE || echo FALSE
echo.
echo :contains /i "string with 20 chars" "WITH"  ^(case insensitive^)
call :contains /i "string with 20 chars" "WITH" && echo TRUE || echo FALSE
echo.
echo :contains /i "string with 20 chars" "diff"  ^(case insensitive^)
call :contains /i "string with 20 chars" "diff" && echo TRUE || echo FALSE
echo.
echo :contains    "string with 20 chars" ""  ^(all strings contain the empty string^)
call :contains    "string with 20 chars" "" && echo TRUE || echo FALSE
echo.
echo :contains    "" "string"  ^(empty string does not contain anything but the empty string^)
call :contains    "" "string" && echo TRUE || echo FALSE
echo.
echo ###################################
echo  :startswith
echo ###################################
echo.
echo :startswith    "string with 20 chars" "string"
call :startswith    "string with 20 chars" "string" && echo TRUE || echo FALSE
echo.
echo :startswith    "string with 20 chars" "STRING"
call :startswith    "string with 20 chars" "STRING" && echo TRUE || echo FALSE
echo.
echo :startswith    "string with 20 chars" "with"
call :startswith    "string with 20 chars" "with" && echo TRUE || echo FALSE
echo.
echo :startswith /i "string with 20 chars" "string"  ^(case insensitive^)
call :startswith /i "string with 20 chars" "string" && echo TRUE || echo FALSE
echo.
echo :startswith /i "string with 20 chars" "STRING"  ^(case insensitive^)
call :startswith /i "string with 20 chars" "STRING" && echo TRUE || echo FALSE
echo.
echo :startswith /i "string with 20 chars" "with"  ^(case insensitive^)
call :startswith /i "string with 20 chars" "with" && echo TRUE || echo FALSE
echo.
echo ###################################
echo  :endswith
echo ###################################
echo.
echo :endswith    "string with 20 chars" "chars"
call :endswith    "string with 20 chars" "chars" && echo TRUE || echo FALSE
echo.
echo :endswith    "string with 20 chars" "CHARS"
call :endswith    "string with 20 chars" "CHARS" && echo TRUE || echo FALSE
echo.
echo :endswith    "string with 20 chars" "with"
call :endswith    "string with 20 chars" "with" && echo TRUE || echo FALSE
echo.
echo :endswith /i "string with 20 chars" "chars"  ^(case insensitive^)
call :endswith /i "string with 20 chars" "chars" && echo TRUE || echo FALSE
echo.
echo :endswith /i "string with 20 chars" "CHARS"  ^(case insensitive^)
call :endswith /i "string with 20 chars" "CHARS" && echo TRUE || echo FALSE
echo.
echo :endswith /i "string with 20 chars" "with"  ^(case insensitive^)
call :endswith /i "string with 20 chars" "with" && echo TRUE || echo FALSE
echo.
exit /b 0


:: #############################################################################
:: #############################################################################

rem A=contains, case sensitive
rem B=contains, case insensitive
rem C=not contains
rem U=contains or not contains

rem  B          str1  != %str1:str2=%       <-- conB
rem ~B          str1  == %str1:str2=%
rem   ~A i  B   str1  != %str1:str2=str2%
rem ~(~A i  B)  str1  == %str1:str2=str2%   <-- conA
rem    A u ~B   str1  == %str1:str2=str2%
rem  B          str1 i!= %str1:str2=%       <-- /i conB (i! is not allowed)
rem ~(~B i  B)  str1 i== %str1:str2=str2%
rem  U          str1 i== %str1:str2=str2%   <-- /i conA

rem A<B, C=~B, U=BuC
rem ~A = BuC-A
rem  A = ~(BuC-A)
rem  A = ~Bi~(C-A)
rem  A = ~Ci~(B-A)
rem  A =  Bi~(B-A)
rem  A =  Bi~(Bi~A)   <--
rem ~A = ~Bu (Bi~A)
rem  A =  Bi (~BuA)
rem ~A = CuBi~A
rem A = ~(CuBi~A)


:: call :contains   [/i]  STR1|"str1"  STR2|"str2"
:: call :startswith [/i]  STR1|"str1"  STR2|"str2"
:: call :endswith   [/i]  STR1|"str1"  STR2|"str2"
::   Returns %ERRORCODE%==0 if str1 contains str2, and returns 1 otherwise.
:contains
    setlocal DisableDelayedExpansion & set "__dir__=" & goto __contains
:startswith
    setlocal DisableDelayedExpansion & set "__dir__=<" & goto __contains
:endswith
    setlocal DisableDelayedExpansion & set "__dir__=>" & goto __contains
:__contains
    if "%~1"=="/i" ( set "i=/i" & shift )
    call :dereference __str2__=%%%%2 || exit /b 0 & rem All strings start with empty string ""
    call :dereference __str1__=%%%%1 || exit /b 1 & rem Empty string "" does not start with anything except ""
    if "%__dir__%"=="" (         rem contains
        call set "conA=%%__str1__:%__str2__%=%__str2__%%%"
        call set "conB=%%__str1__:%__str2__%=%%"
    ) else if "%__dir__%"=="<" ( rem startswith
        call set "conA=%__str2__%%%__str1__:*%__str2__%=%%"
        set "conB="
    ) else (                     rem endswith
        setlocal EnableDelayedExpansion & set "tmp=#!__str2__!" & set "len=0"
        ( for %%N in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
            if not "!tmp:~%%N,1!"=="" ( set "tmp=!tmp:~%%N!" & set /A "len+=%%N" )
        ) ) & for %%L in (!len!) do endlocal & call set "conA=%%__str1__:~0,-%%L%%%__str2__%"
        set "conB="
    )
    if %i% "%__str1__%"=="%conA%" if not "%__str1__%"=="%conB%" exit /b 0
    exit /b 1



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


