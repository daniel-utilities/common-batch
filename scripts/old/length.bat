@echo off
setlocal DisableDelayedExpansion
set "ERRORLEVEL="
((for /L %%P in (1,1,70) do pause>nul)&set /p "TAB=")<"%COMSPEC%" & call set "TAB=%%TAB:~0,1%%"
set ^"LF=^

^"
set "EXC=ERROR:EXC"
set "PCT=ERROR:PCT"
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
set "str=string with 20 chars"
echo STR="!str!"
call :length len str
echo LEN=!len!
echo.
set "str="
echo STR="!str!"
call :length len str
echo LEN=!len!
echo.
exit /b 0


:: #############################################################################
:: #############################################################################

:: call :length LENV STRV
:: Based on: https://ss64.org/viewtopic.php?f=2&t=17
:length
    setlocal EnableDelayedExpansion
    set "lenv=%~1" & if not defined lenv exit /b 1
    set "strv=%~2" & if not defined strv exit /b 1
    set "tmp=#!%strv%!" & set "len=0"
    for %%N in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
        if not "!tmp:~%%N,1!"=="" (
            set /A "len+=%%N"
            set "tmp=!tmp:~%%N!"
        )
    )
    (goto) 2>nul & set "%lenv%=%len%" 2>nul & (call )


:: #############################################################################
:: #############################################################################
