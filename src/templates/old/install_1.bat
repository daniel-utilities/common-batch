@call :batchinit on_exit_do_cleanup on_error_do_exit on_help
call :require_elevated_privilege
:: -----------------------------------------------------------------------------
echo.
echo Starting: %BATCH_FILENAME%
echo   Current Dir:
echo     %BATCH_WORKDIR%
echo   Args: 
for /l %%i in (1,1,%BATCH_NARGS%) do ( 
    echo     %%i: !BATCH_ARGS[%%i]!
)
echo.
:: -----------------------------------------------------------------------------

:: Create temporary directory
call :create_scratch_dir SCRATCH_DIR
set "LOGFILE=%SCRATCH_DIR%\install.log"

:: Search for archive; extract to new folder in scratch dir
:: set "ARCHIVE_FILENAME=archive.zip"
:: if exist "%WINDIR%\Setup\Files\%ARCHIVE_FILENAME%" set "ARCHIVE_DIR=%WINDIR%\Setup\Files"
:: if exist "%BATCH_DIR%\%ARCHIVE_FILENAME%"   set "ARCHIVE_DIR=%BATCH_DIR%"
:: if "%ARCHIVE_DIR%"=="" ( call :throw "File not found: %ARCHIVE_FILENAME%" )
:: set "ARCHIVE=%ARCHIVE_DIR%\%ARCHIVE_FILENAME%"
:: set "EXTRACT_DIR=%SCRATCH_DIR%\%ARCHIVE_FILENAME%"

:: Search for installer (if applicable); run from INSTALLER_WORKDIR and apply TRANSFORM (if applicable)
set "INSTALLER_FILENAME=setup.msi"
set "TRANSFORM_FILENAME=customizations.mst"
set "INSTALLER_DIR=%EXTRACT_DIR%"
:: if exist "%WINDIR%\Setup\Files\%INSTALLER_FILENAME%" set "INSTALLER_DIR=%WINDIR%\Setup\Files"
:: if exist "%BATCH_DIR%\%INSTALLER_FILENAME%"   set "INSTALLER_DIR=%BATCH_DIR%"
:: if "%INSTALLER_DIR%" == "" call :throw "File not found: %INSTALLER_FILENAME%"
set "INSTALLER=%INSTALLER_DIR%\%INSTALLER_FILENAME%"
set "TRANSFORM=%INSTALLER_DIR%\%TRANSFORM_FILENAME%"

set "INSTALLER_WORKDIR=%INSTALLER_DIR%"

set "TARGET_DIR=%PROGRAMFILES%\Example Program"

goto :systemchecks


:: -----------------------------------------------------------------------------
:systemchecks
:: -----------------------------------------------------------------------------
:: set "SEVENZIP=7z.exe"
:: where.exe /q "%SEVENZIP%" || call :throw "Could not find required tool: %SEVENZIP%"
goto :extract


:: -----------------------------------------------------------------------------
:extract
:: -----------------------------------------------------------------------------
:: echo. & echo Extracting "%ARCHIVE_FILENAME%"...
:: if not exist "%ARCHIVE%" ( call :throw "File does not exist: %ARCHIVE%" )
:: mkdir "%EXTRACT_DIR%" >nul 2>&1

:: Extracting .exe and .msi files:
::   https://stackoverflow.com/a/24987512/10001931
::   https://stackoverflow.com/a/51941558/10001931

:: "%SEVENZIP%" x -o"%EXTRACT_DIR%" -y "%ARCHIVE%"
:: start "" /wait msiexec.exe /a "setup.msi" TARGETDIR="%EXTRACT_DIR%" /qn
:: "setup.exe" /a
:: "setup.exe" /s /extract_all
:: "setup.exe" /s /extract_all:"%EXTRACT_DIR%"
:: "setup.exe" /stage_only
:: "setup.exe" /extract "%EXTRACT_DIR%"
:: "setup.exe" /x
:: "setup.exe" /x "%EXTRACT_DIR%"
:: "setup.exe" /s /x /b"%EXTRACT_DIR%" /v"/qn"

:: if %ERRORLEVEL% NEQ 0 ( call :throw "Failed to extract %ARCHIVE%" )
goto :install


:: -----------------------------------------------------------------------------
:install
:: -----------------------------------------------------------------------------
echo.
cd /d "%INSTALLER_WORKDIR%" >nul 2>&1 || call :throw "Directory does not exist: %INSTALLER_WORKDIR%"
:: if "%TRANSFORM_FILENAME%" EQU "" ( echo Installing %INSTALLER_FILENAME% ... )
:: if "%TRANSFORM_FILENAME%" NEQ "" ( echo Installing %INSTALLER_FILENAME% with modifications from %TRANSFORM_FILENAME% ... )
:: if not exist "%TRANSFORM%" ( call :throw "File does not exist: %TRANSFORM%" )
if not exist "%INSTALLER%" ( call :throw "File does not exist: %INSTALLER%" )

:: Reference:
::   MSIEXEC:       https://www.advancedinstaller.com/user-guide/msiexec.html
::   INSTALLSHIELD: https://www.itninja.com/static/090770319967727eb89b428d77dcac07.pdf

:: start "" /wait msiexec.exe /i "setup.msi" /qn /norestart INSTALLDIR="%TARGET_DIR%" /log "%LOGFILE%" TRANSFORMS="customization.mst"
:: "setup.exe" /s /SMS /w /v"/qn /norestart INSTALLDIR=\"%TARGET_DIR%\"" /f1"setup.iss" /f2"%LOGFILE%"
:: dpinst.exe /S /SE /SW /SA /C /PATH "C:\path\to\driver.ini"
:: certutil.exe -addstore "TrustedPublisher" "C:\path\to\certificate.cer"
:: pnputil.exe /add-driver "C:\path\to\drivers\*.inf" /install

if %ERRORLEVEL% NEQ 0 call :throw "%INSTALLER_FILENAME% returned %ERRORLEVEL%"
type "%LOGFILE%" 2>nul
goto :end


:: -----------------------------------------------------------------------------
:end
:: -----------------------------------------------------------------------------
call :exit 0
goto :EOF


:: -----------------------------------------------------------------------------
:: CALLBACKS
:: -----------------------------------------------------------------------------

:on_exit_do_cleanup
    setlocal enabledelayedexpansion
    cd /d "%BATCH_WORKDIR%" >nul 2>&1
    if exist "%SCRATCH_DIR%" ( rmdir /s /q "%SCRATCH_DIR%" >nul 2>&1 )
    echo. & echo Exiting: %BATCH_FILENAME% & echo.
    call :return 0


:on_help
    setlocal enabledelayedexpansion
    echo.
    echo Usage:
    echo %BATCH_FILENAME% /?
    echo   Shows this help text.
    echo.
    set "exit.EXIT_HOOK="
    call :exit 0



:: -----------------------------------------------------------------------------
:: UTILITIES
:: -----------------------------------------------------------------------------


:: call :create_scratch_dir SCRATCH_DIR_VAR
:create_scratch_dir
    setlocal enabledelayedexpansion
    set exit.EXIT_HOOK=on_exit_do_nothing
    set "scratch_dir=%TEMP%\%BATCH_FILENAME: =_%_scratch"
    if exist "%scratch_dir%\" call :throw "Scratch directory already exists: '%scratch_dir%'. It may be in use by another program."
    mkdir "%scratch_dir%" >nul 2>&1 || call :throw "Could not create temporary directory: '%scratch_dir%'."
    call :return %ERRORLEVEL% %~1="%scratch_dir%"


:: -----------------------------------------------------------------------------
:: FRAMEWORK (DO NOT EDIT)
:: -----------------------------------------------------------------------------

:: @call :batchinit
:batchinit
    @(goto) 2>nul & (
        setlocal enabledelayedexpansion
        set  BATCH_STARTTIME=%TIME%
        echo off
        set  ERRORLEVEL=
        if "%~1"=="" ( set "exit.EXIT_HOOK=on_exit_do_nothing" ) else ( set "exit.EXIT_HOOK=%~1" )
        if "%~2"=="" ( set "throw.ERROR_HOOK=on_error_do_exit" ) else ( set "throw.ERROR_HOOK=%~2" )
        if "%~3"=="" ( set "argparse.HELP_HOOK=on_help_default" ) else ( set "argparse.HELP_HOOK=%~3" )
        set "BATCH_WORKDIR=%CD%"
        set "BATCH_FILE=%~f0"
        set "BATCH_FILENAME=%~nx0"
        set "BATCH_DIR=%~dp0" & set "BATCH_DIR=!BATCH_DIR:~0,-1!"
        call set "BATCH_ARGS=%%*"
        call :parse_args "!BATCH_ARGS:"=""!"
    )


:: call :return [ERRORLEVEL [VARNAME="VALUE"]]
::  Exits the caller's context (function or script).
::  Params:
::      ERRORLEVEL: 0 (success) or 1 (failure)
::      VARNAME:    Name of variable to create in the caller's environment.
::      VALUE:      Value to copy into VARNAME.
:return
    (goto) 2>nul & (goto) 2>nul & (
        set "%2=%~3" 2>nul
        if "%~1"=="0" (call ) else (call)
    )


:: call :exit [ERRORLEVEL [VARNAME="VALUE"]]
::  Calls exit.EXIT_HOOK, then exits the current batch script's call stack.
::  Params:
::      ERRORLEVEL: 0 (success) or 1 (failure)
::      VARNAME:    Name of variable to create in the caller's environment.
::      VALUE:      Value to copy into VARNAME.
:exit
    set "args=%*"
    if not "%exit.EXIT_HOOK%"=="" ( call :%exit.EXIT_HOOK% )
    :__exit_helper
    (goto) 2>nul & (
        setlocal enabledelayedexpansion    
        call set "caller=%%~0"
        if "!caller:~0,1!"==":" (
            set "args=%args%"
            goto :__exit_helper
        )
        call :return %args%
    )


:: call :throw ["error message"]
::  Prints an error message, then calls throw.ERROR_HOOK.
:throw
    (goto) 2>nul & (
        setlocal enabledelayedexpansion
        call set "caller=%%~0"
        echo   --[ !caller! ]-- 1>&2
        if "%~1"=="" ( echo ERROR: A critical error has occurred. 1>&2
        ) else (       echo ERROR: %~1 1>&2 )
        if not "%throw.ERROR_HOOK%"=="" ( call :%throw.ERROR_HOOK% )
    )


:: set "BATCH_ARGS=%*" & call :parse_args "!BATCH_ARGS:"=""!"
:parse_args
    set "args=%~1 " & rem Extra space in quotes is necessary
    set "part="
    set ^"LF=^

^" & rem Linefeed const. The formatting of the above two lines are critical. DO NOT REMOVE!
    set BATCH_NARGS=0
    set BATCH_FLG_NARGS=0
    set BATCH_POS_NARGS=0
    for %%L in ("!LF!") do for /f "tokens=* delims=" %%t in ("!args: =%%~L %%~L!") do (
        rem echo Part=[!part!]
        call :__consume_arg "!part!" && set "part=" || set "part=!part!%%t"
    )
    set "arg=" & set "args=" & set "n=" & set "val="
    exit /b 0

    :__consume_arg rem Attempt to store the arg value into a variable. Fails if arg is incomplete.
        set "arg=" & for /f "tokens=*" %%a in ("%~1") do ( set "arg=%%a" )
        call :__is_arg_complete "%arg%" || exit /b 1
        set /a "BATCH_NARGS+=1"
        set "BATCH_ARGS[%BATCH_NARGS%]=%arg:""="%"
        rem echo   Consumed: [%arg:""="%]
        for /f "tokens=* delims=/-" %%a in ("%arg%") do (
            if "%%a"=="%arg%" (
                set /a "BATCH_POS_NARGS+=1" & rem Positional arg
                set "val=%%a" & call :__trim_val !val:""="!
                set "BATCH_POS_ARGS[!BATCH_POS_NARGS!]=!val!"
            ) else (
                for /f "tokens=1,* delims==" %%b in ("%%a") do (
                    if "%%b"=="?" (
                        if not "%argparse.HELP_HOOK%"=="" ( call :%argparse.HELP_HOOK% )
                    ) else (
                        set /a "BATCH_FLG_NARGS+=1" & rem Flag arg
                        set "BATCH_FLG_ARGS[!BATCH_FLG_NARGS!]=%%b"
                        set "val=%%c" & call :__trim_val !val:""="!
                        set "%%b=!val!"
                    )
                )
            )
        )
        exit /b 0
    
    :__trim_val
        set "val=%~1" & exit /b 0

    :__is_arg_complete rem Arg is incomplete if empty or contains an odd number of quotation marks. Expects " is escaped as "".
        setlocal enabledelayedexpansion
        set "arg=%~1" & ( if "!arg!"=="" exit /b 1 )
        set n=0 & set "tmp=%arg:""=" & set /a "n+=1" & set "tmp=%" & set /a "n=n%%2" & exit /b !n!


:: call :require_elevated_privilege
::   Checks the script is running with Administrator (elevated) privilege, else exits with an error.
:require_elevated_privilege
    setlocal enabledelayedexpansion
    net file >nul 2>&1 || (
        set "exit.EXIT_HOOK="
        call :throw "Script '%~nx0' must be run with Administrator [elevated] privilege."
        call :exits 1
    )
    call :return 0


:: call :require_nonelevated_privilege
::   Checks the script is running with User (nonelevated) privilege, else exits with an error.
:require_nonelevated_privilege
    setlocal enabledelayedexpansion
    net file >nul 2>&1 && (
        set "exit.EXIT_HOOK="
        call :throw "Script '%~nx0' must be run with User [nonelevated] privilege."
        call :exit 1
    )
    call :return 0


:: Default help callback handler. Called by:  call :parse_args
::   Change by setting: argparse.HELP_HOOK
:on_help_default
    setlocal enabledelayedexpansion
    echo.
    echo Usage:
    echo %BATCH_FILENAME% /?
    echo   Shows this help text.
    echo.
    set "exit.EXIT_HOOK="
    call :exit 0


:: Default error callback handler. Called by:  call :throw
::   Change by setting: exit.EXIT_HOOK
:on_error_do_exit
    setlocal enabledelayedexpansion
    call :exit 1

:on_error_do_nothing
    setlocal enabledelayedexpansion
    call :return 1


:: Default exit callback handler. Called by:  call :exit
::   Change by setting: exit.EXIT_HOOK
:on_exit_do_nothing
    setlocal enabledelayedexpansion
    cd /d "%BATCH_WORKDIR%" >nul 2>&1
    call :return 0
