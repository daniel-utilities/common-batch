@echo off

setlocal DisableDelayedExpansion
set ^"ARGS=%*^"
setlocal EnableDelayedExpansion

::##############################################################################
set "ERRORLEVEL="
set "EDE=EnableDelayedExpansion"
set "DDE=DisableDelayedExpansion"
::##############################################################################



::##############################################################################
:: Variables containing various whitespace and control characters:
::   %TAB%   Tab character    \x09
::   !LF!    Line Feed        \x0A
::   !CR!    Carriage Return  \x0D
::   %BS%    Backspace        \x08
::   !FF!    Form Feed        \x0C
::
((for /L %%a in (1,1,70) do pause>nul) & set /p "TAB=")<"%COMSPEC%" & set "TAB=!TAB:~0,1!"
set LF=^
%# The two blank lines here are necessary. #%
%# The two blank lines here are necessary. #%
for /f %%a in ('copy /Z %COMSPEC% nul') do set "CR=%%a"
for /f "tokens=1 delims=#" %%a in ('"prompt #$H# & echo on & for %%b in (1) do rem"') do ( set "BS=%%a" & set "BS=!BS:~0,1!" )
for /f %%a in ('cls') do set "FF=%%a"
::##############################################################################



::##############################################################################
::  Variables containing various Batch reserved characters
::
::  Command sequencing (escaped by ^ and ""): & ^ | ( ) < >
set "CMD_SEQ_CHARS=@amp @vert @lpar @rpar @lt @gt @hat"
set  "@amp=&"       &:: One ampersand
set  "@hat=^"       &:: One caret (circumflex accent, hat sign). May need different quoting depending on context.
set  "@vert=|"      &:: One vertical bar
set  "@lpar=("      &:: One left parenthesis
set  "@rpar=)"      &:: One right parenthesis
set  "@lt=<"        &:: One less than sign
set  "@gt=>"        &:: One greater than sign

::  Echo control (escaped by enclosing command in ""): @
set "ECHO_CTRL_CHARS=@at"
set  "@at=@"        &:: One at symbol

::  Argument delim. (escaped by enclosing in ""): , ; = (whitespace)
set "ARG_DELIM_CHARS=@comma @semi @equals @sp @tab"
set  "@comma=,"     &:: One comma
set  "@semi=;"      &:: One semicolon
set  "@equals=="    &:: One equals symbol
set  "@sp= "        &:: One space
set  "@tab=%TAB%"   &:: One tabulation

::  Environment variables (escaped by %): %
set "ENVVAR_CHARS=@percnt"
set  "@percnt=%%"   &:: One percent sign

::  Delayed-expansion environment variables (escaped by ^): !
set "DELAYED_ENVVAR_CHARS=@excl"
set  "@excl=^!"     &:: One exclamation mark

::  Wildcards: * ?
set "WILDCARD_CHARS=@ast @quest"
set  "@ast=*"       &:: One asterisk
set  "@quest=?"     &:: One question mark

::  Misc (used by some internal commands): [ ] { } = ' + ` ~ :
set "MISC_CMD_CHARS=@lbrack @rbrack @lcub @rcub @apos @quot @plus @grave @tilde @colon"
set  "@lbrack=["    &:: One left bracket
set  "@rbrack=]"    &:: One right bracket
set  "@lcub={"      &:: One left curly bracket
set  "@rcub=}"      &:: One right curly bracket
set  "@apos='"      &:: One single quote (apostrophe)
set ^"@quot=""      &:: One double quote
set  "@plus=+"      &:: One plus
set  "@grave=`"     &:: One backquote (grave accent)
set  "@tilde=~"     &:: One tilde
set  "@colon=:"     &:: One colon

::  Other whitespace & control characters:
set "NEWLN_CHARS=@lf @cr"
set "MISC_CTRL_CHARS=@bs @ff"
set  "@lf=!LF!"     &:: One line feed
set  "@cr=!CR!"     &:: One carriage return
set  "@bs=!BS!"     &:: One backspace
set  "@ff=!FF!"     &:: One form feed

::  Filenames CAN contain characters: & ( ) ^ @ , ; % ! [ ] { } = ' + ` ~
::  Filenames CANNOT contain characters: \ / : * ? " < > |
set "UNUSUAL_FILENAME_CHARS=@amp @lpar @rpar @hat @at @comma @semi @percnt @excl @lbrack @rbrack @lcub @rcub @equals @apos @plus @grave @tilde"

::##############################################################################
::  Misc Test Strings
::
set "SIMPLE_STRINGS=" & for /L %%i in (1,1,23) do set "SIMPLE_STRINGS=!SIMPLE_STRINGS! str_simple_%%i"
set "2percnt=ERROR:PERCNT"
set "2excl=ERROR:EXCL"
set "str_simple_1=abcdefghijklmnopqrstuvwxyz"
set "str_simple_2=ABCDEFGHIJKLMNOPQRSTUVWXYZ"
set "str_simple_3=0123456789"
set "str_simple_4=!@quot!1quote"
set "str_simple_5=!@quot!2quote!@quot!"
set "str_simple_6=!@percnt!1percnt"
set "str_simple_7=!@percnt!2percnt!@percnt!"
set "str_simple_8=!@quot!1quote!@percnt!2percnt!@percnt!"
set "str_simple_9=!@excl!1excl"
set "str_simple_10=!@excl!2excl!@excl!"
set "str_simple_11=!@quot!1quote!@excl!2excl!@excl!"
set "str_simple_12=!@quot!!@excl!string"
set "str_simple_13=!@hat!1hat"
set "str_simple_14=!@hat!!@hat!2hat"
set "str_simple_15=!@hat!!@hat!!@hat!3hat"
set "str_simple_16=!@hat!1hat!@excl!1excl"
set "str_simple_17=!@hat!!@hat!2hat!@excl!1excl"
set "str_simple_18=!@hat!!@hat!!@hat!3hat!@excl!1excl"
set "str_simple_19=!@sp!leadingspace"
set "str_simple_20=trailingspace!@sp!"
set "str_simple_21=!@amp!!@vert!!@lpar!!@rpar!!@lt!!@gt!!@hat!leadingcmd_seq_chars"
set "str_simple_22=trailingcmd_seq_chars!@amp!!@vert!!@lpar!!@rpar!!@lt!!@gt!!@hat!"
set "str_simple_23="

set "MULTI_STRINGS=" & for /L %%i in (1,1,6) do set "MULTI_STRINGS=!MULTI_STRINGS! str_multi_%%i"
set "str_multi_1=line1!@lf!"
set "str_multi_2=line1!@lf!line2"
set "str_multi_3=line1!@lf!line2!@lf!"
set "str_multi_4=!@sp!leadingspace!@lf!trailingspace!@sp!"
set "str_multi_5=!@amp!!@vert!!@lpar!!@rpar!!@lt!!@gt!!@hat!leadingcmd_seq_chars!@lf!trailingcmd_seq_chars!@amp!!@vert!!@lpar!!@rpar!!@lt!!@gt!!@hat!"
set "str_multi_6=!@lf!"

::##############################################################################
::  Test framework options
::
set "exit.EXIT_HOOK=on_exit"
set "HIDE_SUCCESSFUL_TESTS=n"
set "PAUSE_ON_FAILED_TEST=n"
set "EXIT_ON_FAILED_TEST=y"

set ^"TEST_GROUPS=^
    simple_strings ^
    multiline_strings ^
    unusual_filename_chars ^
    cmd_seq_chars ^
    echo_ctrl_chars ^
    arg_delim_chars ^
    envvar_chars ^
    delayed_envvar_chars ^
    wildcard_chars ^
    misc_cmd_chars ^
    newln_chars ^
    misc_ctrl_chars ^
"

::##############################################################################
if defined ARGS goto :is_helper_script
goto :is_main_script

::##############################################################################
:is_helper_script   Script called with args; run function directly.
if not "%HIDE_SUCCESSFUL_TESTS%"=="y" echo Exiting with: !ARGS!
call :test.execute !ARGS!
echo ERROR: Failed to return from helper script.
exit /b 99

::##############################################################################
:is_main_script     Script called without args; run tests
set /A "NUM_TESTS=0"
set /A "NUM_SUCCESSFUL=0"
for %%G in (%TEST_GROUPS%) do (
    echo.
    echo ##################################################
    echo Test group: %~n0.%%G, DDE/EDE destination scope
    echo ##################################################
    echo.
    for %%V in (!%%G!) do ( rem indiv tests
        for %%F in (@DDE @EDE) do (
            for %%T in (@DDE @EDE) do (
                set /A "NUM_TESTS+=1"
                set /A "CHECKCODE=NUM_TESTS%%3"
                call :test.begin !CHECKCODE! %%F %%T %%V str_simple_1 && (
                    set /a "NUM_SUCCESSFUL+=1"
                ) || (
                    if "%PAUSE_ON_FAILED_TEST%"=="y" pause
                    if "%EXIT_ON_FAILED_TEST%"=="y" exit /b 1
                )
            )
        )
    )
)

echo.
echo ##################################################
echo Completed %NUM_SUCCESSFUL%/%NUM_TESTS% tests successfully.
echo ##################################################
echo.
if %NUM_SUCCESSFUL% EQU %NUM_TESTS% ( exit /b 1 ) else ( exit /b 0 )


::##############################################################################
::##############################################################################

::  call :return [ERRORLEVEL] [VARNAME] [VARNAME=localvarname] ...      (Requires: LF, CR)
::      Ends the caller's scope (function or script) and copies one or more variables to the caller's parent scope.
::
::  call :exit [ERRORLEVEL] [VARNAME] [VARNAME=localvarname] ...        (Requires: :return, LF, CR)
::      Calls %exit.EXIT_HOOK% (if defined), then exits this script.
::      Returns one or more variables to the parent script.
::
:return [ERRORLEVEL] [VARNAME] [VARNAME=localvarname] ...
    setlocal EnableDelayedExpansion & set "return.err=%ERRORLEVEL%"
    set "return.DDE.setcmd=(call )" & set "return.EDE.setcmd=(call )"
    set "return.args=%*" & if not defined return.args goto :return.switch_context
    for %%L in ("!LF!") do for %%R in ("!CR!") do (
        for /f "tokens=1* delims==" %%a in ("!return.args: =%%~L!") do (
            set "return.var=" & set "return.DDE=" & set "return.EDE="
            for /f "tokens=1 delims=-0123456789" %%# in ("%%~a") do ( rem Arg is VARNAME or VARNAME=PASSBYREFERENCE
                set "return.var=%%~a"
                if "%%~b"=="" ( set "return.DDE=!%%~a!" ) else ( set "return.DDE=!%%~b!" )
                if defined return.DDE ( rem Escape special characters and append to setcmd
                    set "return.DDE=!return.DDE:%%=%%3!"
                    set "return.DDE=!return.DDE:"=%%4!"
                    set "return.DDE=!return.DDE:%%~L=%%~1!"
                    set "return.DDE=!return.DDE:%%~R=%%2!"
                    set "return.EDE=!return.DDE:^=^^^^!"
                    call :return.EDE.escape_exclamations
                )
                set "return.DDE.setcmd=!return.DDE.setcmd!&set "!return.var!=!return.DDE!"^!"
                set "return.EDE.setcmd=!return.EDE.setcmd!&set "!return.var!=!return.EDE!"^!"
            )
            if not defined return.var set /A "return.err=%%~a"  & rem Arg is an integer; set errorlevel
        )
    )
    goto :return.switch_context
:return.EDE.escape_exclamations
    set "return.EDE=%return.EDE:!=^^^!%" !
    exit /b
:return.switch_context
    if not defined return.switch_context.cmd set "return.switch_context.cmd=(goto) 2>nul"
    for %%1 in ("!LF!") do for /f "tokens=1-3" %%2 in (^"!CR! %% "") do (
        (goto) 2>nul
        %return.switch_context.cmd%
        if "^!^" EQU "^!" (%return.EDE.setcmd%) else %return.DDE.setcmd%
        if %return.err% EQU 0 (call ) else if %return.err% equ 1 (call) else cmd /c exit %return.err%
    )

:exit [ERRORLEVEL] [VARNAME] [VARNAME=localvarname] ...
    setlocal DisableDelayedExpansion & set "return.err=%ERRORLEVEL%"
    if defined exit.EXIT_HOOK call :%exit.EXIT_HOOK%
    set "return.switch_context.cmd=call :exit.end_call_stack & (goto) 2>nul"
    call :return %return.err% %*
:exit.end_call_stack
    ( (goto) & (goto) & (
        setlocal DisableDelayedExpansion
        call set "caller=%%~0"
        setlocal EnableDelayedExpansion
        if "!caller:~0,1!"==":" call :exit.end_call_stack
        endlocal & endlocal
    ) ) 2>nul

::##############################################################################
::##############################################################################

:test.begin
    ::# SCOPE: "BASE" (strN is undefined)
    setlocal EnableDelayedExpansion & set SCOPE=BASE:EDE
    for /F "tokens=1,2,3,*" %%a in ("%*") do (
        set /A "CHECKCODE=%%~a"
        set "FROM=%%~b"
        set "TO=%%~c"
        set "TESTVARS=%%~d"
    )

    set "varlist="
    set "num_vars=0" & for %%v in (%TESTVARS%) do (
        set /A "num_vars+=1"
        set "original!num_vars!=!%%v!"  & rem Original value to compare against
        set "val!num_vars!="            & rem Values returned by function
        set "varlist=!varlist! val!num_vars!=original!num_vars!"
    )

    ::# SCOPE: "TO" (strN = originalN, if :exit successful)
    ::#
    ::# BASE --> TO          setlocal EDE|DDE, define originalN
    ::#          |           call SCRIPT ERRORLEVEL val1=original1 ...
    ::#          +--> FROM   setlocal EDE|DDE
    ::#                |     call :exit ERRORLEVEL val1=original1 ...
    ::#          TO <--+     
    ::#
    setlocal !%TO%! & set SCOPE=TO:%TO%
    call "%~f0" %CHECKCODE% %VARLIST%
    set /A "exitcode=%ERRORLEVEL%"

    ::# TEST RESULTS
    if "%TO%"=="EDE" if not "!!"=="" goto :__test_bad_scope_switch
    if "%TO%"=="DDE" if "!!"=="" goto :__test_bad_scope_switch
    if not "%SCOPE%"=="TO:%TO%" goto :__test_bad_scope_switch
    if %exitcode% NEQ %checkcode% goto :__test_bad_exitcode
    setlocal %@EDE% & set "err=0"
    for /L %%i in (1,1,%num_vars%) do if not "!val%%i!"=="!original%%i!" set "err=1"
    if %err% EQU 1 goto :__test_unsuccessful
    goto :__test_successful

:test.execute
    ::# SCOPE: "FROM" (strN = originalN)
    setlocal !%FROM%! & set SCOPE=FROM:%FROM%
    call :exit %*
    (goto) 2>nul & set SCOPE=FROM:%FROM% & (call) & rem Should not get to this line!

:on_exit
    if not "%HIDE_SUCCESSFUL_TESTS%"=="y" (
        echo -- Running exit hook --
    )
    exit /b 0

:__test_bad_scope_switch
    echo ERROR: Test %NUM_TESTS% returned to scope %SCOPE%, expected TO:%TO%.
    goto :__test_unsuccessful
:__test_bad_exitcode
    echo ERROR: Test %NUM_TESTS% returned EXITCODE=%exitcode%, expected %checkcode%.
    goto :__test_unsuccessful
:__test_unsuccessful
    echo ERROR: Test %NUM_TESTS% failed.
    call :__test.print
    exit /b 1
:__test_successful
    if not "%HIDE_SUCCESSFUL_TESTS%"=="y" call :__test.print
    exit /b 0

:__test.print
    setlocal EnableDelayedExpansion
    echo ######## TEST !NUM_TESTS!: !CHECKCODE! !TESTVARS! ^(!FROM!--^>!TO!^) ########
        echo  ERRORLEVEL
        echo    Original: ERRORLEVEL=[!CHECKCODE!]
        echo    Returned: ERRORLEVEL=[!exitcode!]
    for /L %%i in (1,1,%num_vars%) do (
        echo  TESTVAR[%%i]
        echo    Original: str%%i=[!original%%i!]
        echo    Returned: str%%i=[!val%%i!]
    )
    echo.
    goto :EOF
