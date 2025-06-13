::.Usage:
::  <basename>
::
@echo off & goto :.%1 1>nul 2>nul || cmd /d /c man.bat "%~f0" "Usage"
exit /b 0

:.
::########################################################
setlocal DisableDelayedExpansion
set ^"LF=^
%= EMPTY LINE =%
^"
set    ^"#LF=^^^%LF%%LF%^%LF%%LF%^"
set   ^"#EOL=^^^%LF%%LF%^"          %= User provides the missing LF when expanding this at the end of a macro line =%

set "EDE=EnableDelayedExpansion"
set "DDE=DisableDelayedExpansion"

set ^"@PRINT_SCOPE=( %#EOL%
    if "!!"=="" ( setlocal %EDE% ^& set "scopes.setlocal_type=EDE"%#EOL%
    ) else        setlocal %EDE% ^& set "scopes.setlocal_type=DDE"%#EOL%
    cls %#EOL%
    echo(%#EOL%
    echo(Call Stack: [ --^^^> !scopes.callstack! ]%#EOL%
    echo(  Setlocal depth: !scopes.depth!%#EOL%
    echo(  Expansion mode: !scopes.setlocal_type!%#EOL%
    set scopes.user 1^>nul 2^>nul%#EOL%
    if !ERRORLEVEL! NEQ 1 (%#EOL%
        echo(  User Variables: %#EOL%
        for /F "tokens=3* delims=." %%V in ('set scopes.user.') do (%#EOL%
        echo(    %%V%#EOL%
        )%#EOL%
    )%#EOL%
    echo(%#EOL%
    endlocal%#EOL%
)"

set ^"@PROMPT_USER=( %#EOL%
    echo(Choose a command:%#EOL%
    echo(  1:  setlocal DisableDelayedExpansion%#EOL%
    echo(  2:  setlocal EnableDelayedExpansion%#EOL%
    echo(  3:  endlocal%#EOL%
    echo(  4:  call :function1%#EOL%
    echo(  5:  call :function2%#EOL%
    echo(  6:  exit /b%#EOL%
    echo(  7:  goto :EOF%#EOL%
    echo(  8:  ^^(goto^^) 2^^^>nul%#EOL%
    echo(  9:  Set user variable%#EOL%
    setlocal %EDE% %#EOL%
    choice /C 123456789 /N /M ">>>> "%#EOL%
    for %%N in (!ERRORLEVEL!) do (endlocal %#EOL%
             if %%N==1 ( set "cmd=setlocal %DDE% & set /A scopes.depth+=1"%#EOL%
      ) else if %%N==2 ( set "cmd=setlocal %EDE% & set /A scopes.depth+=1"%#EOL%
      ) else if %%N==3 ( set "cmd=setlocal %EDE% & (if !scopes.depth! GTR 0 endlocal) & endlocal"%#EOL%
      ) else if %%N==4 ( set "cmd=call :function1"%#EOL%
      ) else if %%N==5 ( set "cmd=call :function2"%#EOL%
      ) else if %%N==6 ( set "cmd=call set "scopes.callstack=%%scopes.callstack:* --^^^> =%%" & exit /b"%#EOL%
      ) else if %%N==7 ( set "cmd=call set "scopes.callstack=%%scopes.callstack:* --^^^> =%%" & goto :EOF"%#EOL%
      ) else if %%N==8 ( set "cmd=call set "scopes.callstack=%%scopes.callstack:* --^^^> =%%" & (goto) 2>nul"%#EOL%
      ) else if %%N==9 ( set "cmd=set /p "scopes.var=Enter variable name: " & call set /p "scopes.user.%%scopes.var%%=%%scopes.var%%=""%#EOL%
      ) else ( set "cmd=call " )%#EOL%
    )%#EOL%
)"


:__main
set "scopes.callstack=%~nx0"
set "scopes.depth=0"
:__main_loop
    %@PRINT_SCOPE%
    %@PROMPT_USER%
    (%cmd%)
goto :__main_loop


:function1
call set "scopes.callstack=%0 --> %%scopes.callstack%%"!
:__function1_loop
    %@PRINT_SCOPE%
    %@PROMPT_USER%
    (%cmd%)
goto :__function1_loop


:function2
call set "scopes.callstack=%0 --> %%scopes.callstack%%"!
:__function2_loop
    %@PRINT_SCOPE%
    %@PROMPT_USER%
    (%cmd%)
goto :__function2_loop
