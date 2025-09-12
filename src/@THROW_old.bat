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

::----------------------------------------------------------------------------::
:: @THROW                                                                     ::
::   Macros for error handling                                                ::
::----------------------------------------------------------------------------::

:: @THROW
set ^"@THROW=for %%# in (1 2) do if %%#==2 ( %#EOL%
for /f "tokens=1,2,* delims=[]= " %%A in ("!@array.args!") do ( %#EOL%
%========================================================================% %#EOL%
%= SECTION  Process Macro Args                                          =% %#EOL%
%=   token A  array name                                                =% %#EOL%
%=   token B  initial size                                              =% %#EOL%
%=   token C  list of values (REF variable or literal value)            =% %#EOL%
%=                                                                      =% %#EOL%
%========================================================================% %#EOL%
) %#EOL%
%========================================================================% %#EOL%
%= SECTION  Cleanup Locals                                              =% %#EOL%
set "@array.args=" %#EOL%
%========================================================================% %#EOL%
) else set @array.args="

:: call :throw ["error message"]
::  Prints an error message, then calls throw.ERROR_HOOK.
:throw
    (goto) 2>nul & (
        setlocal DisableDelayedExpansion
        call echo   --[ %%~0 ]-- 1>&2
        if "%~1"=="" ( echo ERROR: A critical error has occurred. 1>&2
        ) else (       echo ERROR: %~1 1>&2 )
        if defined @THROW.ERROR_HOOK call :%@THROW.ERROR_HOOK%
        endlocal
    ) & (call)


echo.
echo Throwing error...
set "@THROW.ERROR_HOOK=on_error_do_nothing"
%@THROW% "Calling error hook %THROW.ERROR_HOOK%"
echo.



echo.
echo Throwing error...
set "@THROW.ERROR_HOOK=on_error_do_exit"
%@THROW% "Calling error hook %@THROW.ERROR_HOOK%"
echo.


echo TEST ERROR: Did not exit successfully.
exit /b 1


:: call :on_error_do_exit
:: Default error callback handler. Called by:  call :throw
::   Change by setting: throw.ERROR_HOOK
:on_error_do_exit
    setlocal disabledelayedexpansion
    call :exit 1

:: call :on_error_do_nothing
:on_error_do_nothing
    setlocal disabledelayedexpansion
    call :return 1
