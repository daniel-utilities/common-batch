@(  echo off
    setlocal DisableDelayedExpansion
    set ^"ARGS=%*^"
    set /A "PARENT_ERRORLEVEL=%ERRORLEVEL%" 2>nul
    set "ERRORLEVEL="
    setlocal EnableDelayedExpansion
    call :init_specialchars
    call :init_macros
    call :init_reservedchars
)

::##############################################################################
::  Test Options
::
set "HIDE_SUCCESSFUL_TESTS=n"
set "PAUSE_ON_FAILED_TEST=n"
set "EXIT_ON_FAILED_TEST=y"

::##############################################################################
::  Test Groups
::      A Test Group is a space-separated list of Test Case variables.
::
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
set "SIMPLE_STRINGS=" & rem Defined in later section
set "MULTILINE_STRINGS=" & rem Defined in later section
set "UNUSUAL_FILENAME_CHARS=@amp @lpar @rpar @hat @at @comma @semi @percnt @excl @lbrack @rbrack @lcub @rcub @equals @apos @plus @grave @tilde"
set "CMD_SEQ_CHARS=@amp @vert @lpar @rpar @lt @gt @hat"
set "ECHO_CTRL_CHARS=@at"
set "ARG_DELIM_CHARS=@comma @semi @equals @sp @tab"
set "ENVVAR_CHARS=@percnt"
set "DELAYED_ENVVAR_CHARS=@excl"
set "WILDCARD_CHARS=@ast @quest"
set "MISC_CMD_CHARS=@lbrack @rbrack @lcub @rcub @apos @quot @plus @grave @tilde @colon"
set "NEWLN_CHARS=@lf @cr"
set "MISC_CTRL_CHARS=@bs @ff"

::##############################################################################
::  Test Group: Simple Strings
::
set "SIMPLE_STRINGS=" & for /L %%i in (0,1,22) do set "SIMPLE_STRINGS=!SIMPLE_STRINGS! str_simple_%%i"
set "2percnt=ERROR:PERCNT"
set "2excl=ERROR:EXCL"
set "str_simple_0="
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

::##############################################################################
::  Test Group: Multiline Strings
::
set "MULTILINE_STRINGS=" & for /L %%i in (0,1,5) do set "MULTILINE_STRINGS=!MULTILINE_STRINGS! str_multi_%%i"
set "str_multi_0=!@lf!"
set "str_multi_1=line1!@lf!"
set "str_multi_2=line1!@lf!line2"
set "str_multi_3=line1!@lf!line2!@lf!"
set "str_multi_4=!@sp!leadingspace!@lf!trailingspace!@sp!"
set "str_multi_5=!@amp!!@vert!!@lpar!!@rpar!!@lt!!@gt!!@hat!leadingcmd_seq_chars!@lf!trailingcmd_seq_chars!@amp!!@vert!!@lpar!!@rpar!!@lt!!@gt!!@hat!"


::##############################################################################
:start
if defined ARGS goto :is_helper_script
goto :is_main_script

::##############################################################################
:is_helper_script   Script called with args; pass args directly to function.
if not "%HIDE_SUCCESSFUL_TESTS%"=="y" echo Returning: !ARGS!
call :return !ARGS!
echo ERROR: Failed to return from helper script.
exit /b 99

::##############################################################################
:is_main_script     Script called without args; run tests in %TEST_GROUPS%
set /A "NUM_TESTS=0"
set /A "NUM_SUCCESSFUL=0"
for %%G in (%TEST_GROUPS%) do (
    echo.
    echo ##################################################
    echo Test group: %~n0.%%G, DDE/EDE to DDE/EDE
    echo ##################################################
    echo.
    for %%V in (!%%G!) do ( rem indiv tests
        for %%F in (@DDE @EDE) do (
            for %%T in (@DDE @EDE) do (
                set /A "NUM_TESTS+=1"
                set /A "CHECKCODE=NUM_TESTS%%3"
                call :test.new !CHECKCODE! %%F %%T %%V str_simple_1 && (
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
::   Ends the caller's scope (function or script) and copys one or more variables to the caller's parent scope.
::   Params:
::       ERRORLEVEL: Integer. 0 (success), >= 1 (failure)
::                  If not specified, returns the current ERRORLEVEL of the caller's scope.
::       VARNAME:   Name of variable to create in the caller's environment.
::                  Its value is copied from the local environment.
::       return.switch_context.cmd
::                  Command to run in the caller's context.
::                  Defaults to "(goto) 2>nul" (exit from function but continue to end of () code block)
::                  
:return [ERRORLEVEL] [VARNAME] [VARNAME=localvarname] ...
    setlocal EnableDelayedExpansion & set "return.err=%ERRORLEVEL%"
    set "return.DDE.setcmd=(call )" & set "return.EDE.setcmd=(call )"
    set "return.args=%*" & if not defined return.args goto :return.switch_context
    for %%L in ("!LF!") do for %%R in ("!CR!") do (
        for /F "tokens=1* delims==" %%a in ("!return.args: =%%~L!") do (
            set "return.var=" & set "return.DDE=" & set "return.EDE="
            for /F "tokens=1 delims=-0123456789" %%# in ("%%~a") do ( rem Arg is VARNAME or VARNAME=PASSBYREFERENCE
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
    for %%1 in ("!LF!") do for /F "tokens=1-3" %%2 in (^"!CR! %% "") do (
        (goto) 2>nul
        %return.switch_context.cmd%
        if "^!^" EQU "^!" (%return.EDE.setcmd%) else %return.DDE.setcmd%
        if %return.err% EQU 0 (call ) else if %return.err% equ 1 (call) else cmd /c exit %return.err%
    )

::##############################################################################
::##############################################################################

:test.new
    setlocal %@DDE% & for /F "tokens=1,2,3,*" %%a in ("%*") do (
        set /A "CHECKCODE=%%~a" & rem Function must set this errorlevel upon return
        set "FROM=%%~b"         & rem @DDE or @EDE
        set "TO=%%~c"           & rem @DDE or @EDE
        set "TESTVARS=%%~d"     & rem Variables to send to function
    )

    %@ENUM.NEW% TEST.SUCCESS ^
                TEST.FAILURE ^
                TEST.BAD_CONTEXT_SWITCH ^
                TEST.BAD_ERRORLEVEL

    set "test.err.[%TEST.SUCCESS%]="
    set "test.err.[%TEST.FAILURE%]=ERROR: Test !NUM_TESTS! failed."
    set "test.err.[%TEST.BAD_CONTEXT_SWITCH%]=ERROR: Test !NUM_TESTS! returned to scope !SCOPE!, expected TO:!TO!."
    set "test.err.[%TEST.BAD_ERRORLEVEL%]=ERROR: Test !NUM_TESTS! returned EXITCODE=!test.exitcode!, expected !CHECKCODE!."
        
    :: SCOPE: "BASE" (strN is undefined)
    setlocal %@EDE% & set SCOPE=BASE:EDE
    set "varlist="  & rem List of variables carried from FROM to TO
    set "num_vars=0" & for %%v in (%TESTVARS%) do (
        set /A "num_vars+=1"
        set "original!num_vars!=!%%v!"  & rem Original value to compare against
        set "val!num_vars!="            & rem Values carried from FROM to TO
        set "varlist=!varlist! val!num_vars!"
    )

    :: SCOPE: "TO" (strN = originalN, if :return successful)
    ::
    :: BASE --> TO          setlocal EDE|DDE, define originalN
    ::          |           call :__test.execute
    ::          +--> FROM   setlocal EDE|DDE, set valN=originalN
    ::                |                                   
    ::          TO <--+     call :return valN
    ::
    setlocal !%TO%! & set SCOPE=TO:%TO%
    call :test.execute
    set /A "test.exitcode=%ERRORLEVEL%"

    call :test.eval && (
        if not "%HIDE_SUCCESSFUL_TESTS%"=="y" call :test.print
        %@RETURN_SUCCESS%
    ) || (
        call :test.print
        %@RETURN_FAILURE%
    )

:test.execute
    :: SCOPE: "FROM" (strN = originalN)
    setlocal %@EDE% & set SCOPE=FROM:INTERMEDIATE
    for /L %%i in (1,1,%num_vars%) do set "val%%i=!original%%i!"
    setlocal !%FROM%! & set SCOPE=FROM:%FROM%
    call :return %CHECKCODE% %varlist%
    (goto) 2>nul & set SCOPE=FROM:%FROM% & (call) & rem Should not get to this line!

:test.eval
    if "!!"=="" ( setlocal %@DDE% & set "test.exp=@EDE" ) else ( setlocal %@DDE% & set "test.exp=@DDE" )

    if not "%TO%"=="%test.exp%" exit /b %test.err.BAD_CONTEXT_SWITCH%
    if not "%SCOPE%"=="TO:%TO%" exit /b %test.err.BAD_CONTEXT_SWITCH%
    if %test.exitcode% NEQ %checkcode% exit /b %test.err.BAD_ERRORLEVEL%
    setlocal %@EDE%
    for /L %%i in (1,1,%num_vars%) do if not "!val%%i!"=="!original%%i!" exit /b %test.err.FAILURE%
    exit /b 0

:test.print
    setlocal EnableDelayedExpansion & set /A "test.errortype=%ERRORLEVEL%"
    
    echo ######## TEST !NUM_TESTS!: !CHECKCODE! !TESTVARS! ^(!FROM!--^>!TO!^) ########
        echo  ERRORLEVEL
        echo    Original: ERRORLEVEL=[!CHECKCODE!]
        echo    Returned: ERRORLEVEL=[!test.exitcode!]
    for /L %%i in (1,1,%num_vars%) do (
        echo  TESTVAR[%%i]
        echo    Original: str%%i=[!original%%i!]
        echo    Returned: str%%i=[!val%%i!]
    )
    echo.
    %@RETURN_SUCCESS%


::##############################################################################
:init_specialchars
:: Defines variables (in the current scope) containing various special characters:
::   !LF!    Line Feed        0x0A  (10)    EDE (!-expansion)
::   %TAB%   Tab character    0x09  ( 9)    DDE or EDE
::   !CR!    Carriage Return  0x0D  (14)    EDE
::   %BS%    Backspace        0x08  ( 8)    DDE or EDE
::   !FF!    Form Feed        0x0C  (13)    EDE
::------------------------------------------------------------------------------
    set LF=^
%= This empty line is necessary =%
%= This empty line is necessary =%
    ((for /L %%a in (1,1,70) do pause>nul) & set /p "TAB=")<"%COMSPEC%"
    set "TAB=%TAB:~0,1%"
    for /f %%a in ('copy /Z %COMSPEC% nul') do set "CR=%%a"
    for /f "tokens=1 delims=#" %%a in ('"prompt #$H# & echo on & for %%b in (1) do rem"') do set "BS=%%a"
    set "BS=%BS:~0,1%"
    for /f %%a in ('cls') do set "FF=%%a"
    exit /b
:: END: :init_specialchars
::##############################################################################


::##############################################################################
:init_macros            
::  Requires:
::      DisableDelayedExpansion
::      :init_specialchars
::  Defines macros (in the current scope).
::  Macros are blocks of code stored in a variable, which execute on-demand
::    when %-expanded. Macros typically require DisableDelayedExpansion
::    during definition, and EnableDelayedExpansion during runtime.
::  Use a macro like:
::      %@MACRO_NAME% args
::------------------------------------------------------------------------------
    if "!!"=="" ( echo ERROR: %0 requires DisableDelayedExpansion. & exit /b 1 )
    if not defined LF call :init_specialchars

    set "@EDE=EnableDelayedExpansion"
    set "@DDE=DisableDelayedExpansion"
    ::  %#LF%   Substitutes a single linefeed after one %-expansion
    ::  %##LF%  Substitutes a single linefeed after two %-expansions
    set ^"#LF=^^^%LF%%LF%^%LF%%LF%^^"
    set ^"##LF=^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^^^^^^"
::------------------------------------------------------------------------------

:: @RETURN_SUCCESS
set "@RETURN_SUCCESS=exit /b 0"

:: @RETURN_FAILURE
set "@RETURN_FAILURE=exit /b 1"





::------------------------------------------------------------------------------
    exit /b
:: END: :init_macros
::##############################################################################


::##############################################################################
:init_reservedchars
::  Requires:
::      EnableDelayedExpansion
::      :init_specialchars
::  Defines variables (in the current scope) containing Batch-reserved characters:
::      Command sequencing (escaped by ^ and ""):               & ^ | ( ) < >
::      Echo control (escaped by enclosing command in ""):      @
::      Argument delim. (escaped by enclosing in ""):           , ; = (whitespace)
::      Environment variables (escaped by %):                   %
::      Delayed-expansion environment variables (escaped by ^): !
::      Wildcards:                                              * ?
::      Misc (used by some internal commands):                  [ ] { } = ' + ` ~ :
::      Other whitespace & control characters:                  LF, CR, BS, FF
::      Filenames CAN contain characters:                       & ( ) ^ @ , ; % ! [ ] { } = ' + ` ~
::      Filenames CANNOT contain characters:                    \ / : * ? " < > |
::------------------------------------------------------------------------------

    if not "!!"=="" ( echo ERROR: %0 requires EnableDelayedExpansion. & exit /b 1 )
    if not defined LF call :init_specialchars

::------------------------------------------------------------------------------
::  Command sequencing (escaped by ^ and ""): & ^ | ( ) < >
    set  "@amp=&"       &:: One ampersand
    set  "@hat=^"       &:: One caret (circumflex accent, hat sign). May need different quoting depending on context.
    set  "@vert=|"      &:: One vertical bar
    set  "@lpar=("      &:: One left parenthesis
    set  "@rpar=)"      &:: One right parenthesis
    set  "@lt=<"        &:: One less than sign
    set  "@gt=>"        &:: One greater than sign

::------------------------------------------------------------------------------
::  Echo control (escaped by enclosing command in ""): @
    set  "@at=@"        &:: One at symbol

::------------------------------------------------------------------------------
::  Argument delims (escaped by enclosing in ""):  , ; = (whitespace)
    set  "@comma=,"     &:: One comma
    set  "@semi=;"      &:: One semicolon
    set  "@equals=="    &:: One equals symbol
    set  "@sp= "        &:: One space
    set  "@tab=%TAB%"   &:: One tabulation

::------------------------------------------------------------------------------
::  Environment variables (escaped by %): %
    set  "@percnt=%%"   &:: One percent sign

::------------------------------------------------------------------------------
::  Delayed-expansion environment variables (escaped by ^): !
    set  "@excl=^!"     &:: One exclamation mark

::------------------------------------------------------------------------------
::  Wildcards: * ?
    set  "@ast=*"       &:: One asterisk
    set  "@quest=?"     &:: One question mark

::------------------------------------------------------------------------------
::  Misc (used by some internal commands): [ ] { } = ' + ` ~ :
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

::------------------------------------------------------------------------------
::  Other whitespace & control characters: linefeed, carriage return, backspace, form feed
    set  "@lf=!LF!"     &:: One line feed (new line)
    set  "@cr=!CR!"     &:: One carriage return (move cursor to beginning of line)
    set  "@bs=!BS!"     &:: One backspace
    set  "@ff=!FF!"     &:: One form feed (page break)

::------------------------------------------------------------------------------
    exit /b
:: END: :init_macros
::##############################################################################
