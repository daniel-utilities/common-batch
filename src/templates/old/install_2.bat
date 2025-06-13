@call :batchinit & rem /throw.ERROR_HOOK=on_error_do_exit /exit.EXIT_HOOK=on_exit_do_nothing
:: -----------------------------------------------------------------------------
:: System_Install_TYPE_NAME.bat
:: -----------------------------------------------------------------------------
setlocal DisableDelayedExpansion
::call :require_elevated_privilege
:: -----------------------------------------------------------------------------
:start
set "SEARCH_PATHS=%SEARCH_PATHS%;%BATCH_WORKDIR%;%BATCH_DIR%;%WINDIR%\Setup\Files"
:: set "SCRATCH_DIR=%TEMP%\%BATCH_FILENAME: =_%_scratch"
set "SCRATCH_DIR=%BATCH_WORKDIR%\scratch"
set "LOGFILE=%SCRATCH_DIR%\install.log"
echo.
echo Starting: %BATCH_FILENAME%
echo   Current Dir:
echo     %BATCH_WORKDIR%
echo   Args: %BATCH_ARGS[#]%
setlocal EnableDelayedExpansion
for /l %%i in (1,1,%BATCH_ARGS[#]%) do echo     [%%i]=!BATCH_ARGS[%%i]!
endlocal
echo   Search Paths:
setlocal DisableDelayedExpansion
:: set "SKIP_EMPTY_TOKENS=true"
call :foreach "" SEARCH_PATHS ";"
endlocal
echo.
:: -----------------------------------------------------------------------------

:: Create temporary workspace
call :init_scratch_dir SCRATCH_DIR || call :throw "Failed to initialize temporary directory."

:: Search for archive; extract to new folder in scratch dir
set "ARCHIVE_FILENAME=archive.zip"
set "EXTRACT_DIR=%SCRATCH_DIR%"
call :find_resource ARCHIVE_FILE ARCHIVE_FILENAME SEARCH_PATHS || call :throw "File not found: %ARCHIVE_FILENAME%"
::call :extract ARCHIVE_FILE EXTRACT_DIR || call :throw "Extraction failed."
goto :end

:: Search for installer (if applicable); run from INSTALLER_WORKDIR and apply TRANSFORM (if applicable)
set "INSTALLER_FILENAME=setup.msi"
:: set "TRANSFORM_FILENAME=customizations.mst"
set "INSTALLER_DIR=%EXTRACT_DIR%"
if exist "%WINDIR%\Setup\Files\%INSTALLER_FILENAME%" set "INSTALLER_DIR=%WINDIR%\Setup\Files"
if exist "%BATCH_DIR%\%INSTALLER_FILENAME%"   set "INSTALLER_DIR=%BATCH_DIR%"
if "%INSTALLER_DIR%" == "" call :throw "File not found: %INSTALLER_FILENAME%"
set "INSTALLER=%INSTALLER_DIR%\%INSTALLER_FILENAME%"
set "TRANSFORM=%INSTALLER_DIR%\%TRANSFORM_FILENAME%"

set "INSTALLER_WORKDIR=%INSTALLER_DIR%"

set "TARGET_DIR=%PROGRAMFILES%\Example Program"

goto :systemchecks





echo.
cd /d "%INSTALLER_WORKDIR%" >nul 2>&1 || call :throw "Directory does not exist: %INSTALLER_WORKDIR%"
:: if "%TRANSFORM_FILENAME%" EQU "" ( echo Installing %INSTALLER_FILENAME% ... )
:: if "%TRANSFORM_FILENAME%" NEQ "" ( echo Installing %INSTALLER_FILENAME% with modifications from %TRANSFORM_FILENAME% ... )
:: if not exist "%TRANSFORM%" ( call :throw "File does not exist: %TRANSFORM%" )
if not exist "%INSTALLER%" ( call :throw "File does not exist: %INSTALLER%" )

:: Install
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

:: Exit
call :cleanup_scratch_dir SCRATCH_DIR
call :exit 0 & rem Optional: Append list of variables to return.
goto :EOF



:: -----------------------------------------------------------------------------
:: CALLBACKS
:: -----------------------------------------------------------------------------

:: call :on_help
:: Default help callback handler. Called by:  call :parse_args
::   Change by setting: argparse.HELP_HOOK
:on_help
    setlocal DisableDelayedExpansion
    echo.
    echo Usage:
    echo %BATCH_FILENAME% /?
    echo   Shows this help text.
    echo.
    set "exit.EXIT_HOOK="
    call :exit 0


:: call :on_error_do_exit
:: Default error callback handler. Called by:  call :throw
::   Change by setting: throw.ERROR_HOOK
:on_error_do_exit
    setlocal DisableDelayedExpansion
    call :exit 1

:: call :on_error_do_nothing
:on_error_do_nothing
    setlocal DisableDelayedExpansion
    call :return 1


:: call :on_exit_do_nothing
:: Default exit callback handler. Called by:  call :exit
::   Change by setting: exit.EXIT_HOOK
:on_exit_do_nothing
    setlocal DisableDelayedExpansion
    echo. & echo Exiting: %BATCH_FILENAME% & echo.
    cd /d "%BATCH_WORKDIR%" >nul 2>&1
    if not defined BATCH_UNATTENDED pause
    call :return 0


:: -----------------------------------------------------------------------------
:: UTILITIES
:: -----------------------------------------------------------------------------

:: call :init_scratch_dir SCRATCH_DIR|"scratch\dir"
:init_scratch_dir
    setlocal EnableDelayedExpansion
    set "throw.ERROR_HOOK=" & rem Let the caller handle errors.
    call :dereference __scratchdir__=%%%%1 || call :return 1
    call :cleanup_scratch_dir "!__scratchdir__!"
    mkdir "!__scratchdir__!" >nul 2>&1 || (
        call :throw "Failed to create directory: '!__scratchdir__!'."
        call :return 1
    )
    call :return 0

:: call :cleanup_scratch_dir SCRATCH_DIR|"scratch\dir"
:cleanup_scratch_dir
    setlocal EnableDelayedExpansion
    set "throw.ERROR_HOOK=" & rem Let the caller handle errors.
    call :dereference __scratchdir__=%%%%1 || call :return 1
    if exist "!__scratchdir__!\" (
        rmdir /s /q "!__scratchdir__!" >nul 2>&1 || (
            call :throw "Failed to remove directory: '!__scratchdir__!'."
            call :return 1
        )
    )
    call :return 0


:: call :find_resource PATHV FILENAMEV|"filename" SEARCH_PATHS|"searchpath1:searchpath2:..."
:find_resource
    setlocal DisableDelayedExpansion
    set "throw.ERROR_HOOK=" & rem Let the caller handle errors.
    call :dereference __retpathvar__=%%%%1 || call :return 1
    call :dereference __filename__=%%%%2 || call :return 1
    call :dereference __searchpaths__=%%%%3 || set "__searchpaths__=%BATCH_WORKDIR%"
    echo HERE
    call :foreach "" __searchpaths__ ":"
    call :return 0


:: call :extract FILE|"file" DIR|"dir" [ARGS|"args"]
::   Extracting .exe and .msi files:
::     https://stackoverflow.com/a/24987512/10001931
::     https://stackoverflow.com/a/51941558/10001931
::   "setup.exe" /a
::   "setup.exe" /s /extract_all
::   "setup.exe" /s /extract_all:"%EXTRACT_DIR%"
::   "setup.exe" /stage_only
::   "setup.exe" /extract "%EXTRACT_DIR%"
::   "setup.exe" /x
::   "setup.exe" /x "%EXTRACT_DIR%"
::   "setup.exe" /s /x /b"%EXTRACT_DIR%" /v"/qn"
:extract
    setlocal EnableDelayedExpansion
    set "throw.ERROR_HOOK=" & rem Let the caller handle errors.
    call :dereference __archivefile__=%%%%1 || call :return 1
    call :dereference __extractdir__=%%%%2 || call :return 1
    call :dereference __exeargs__=%%%%3
    if not exist "!__archivefile__!" (
        call :throw "File not found: '!__archivefile__!'"
        call :return 1
    )
    if not exist "!__extractdir__!\" (
        mkdir "!__extractdir__!" >nul 2>&1 || (
            call :throw "Failed to create directory: '!__extractdir__!'"
            call :return 1
        )
    )

    echo Extracting "%~nx1" to "!__extractdir__!"...

    :: MSI files
    call :endswith /i __archivefile__ ".msi" && (
        start "" /wait msiexec.exe /a /qn "!__archivefile__!" TARGETDIR="!__extractdir__!" !__exeargs__!
        call :return !ERRORLEVEL!
    )

    :: EXE files
    call :endswith /i __archivefile__ ".exe" && (
        pushd "!__extractdir__!"
        start "" /wait "!__archivefile__!" !__exeargs__!
        set "ERRORLEVEL=!ERRORLEVEL!"
        popd
        call :return !ERRORLEVEL!
    )

    :: Other archives
    set "SEVENZIP=7z.exe"
    where /q "!SEVENZIP!" || (
        call :throw "Could not find required tool: !SEVENZIP!"
        call :return 1
    )
    "!SEVENZIP!" x -o"!__extractdir__!" -y "!__archivefile__!" !__exeargs__!
    call :return !ERRORLEVEL!


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


:: call :trim STRV ["chars"]        (Requires: :return)
:: call :trim_front STRV ["chars"]
:: call :trim_back STRV ["chars"]
:trim
    setlocal EnableDelayedExpansion
    set "front=" & set "back=" & goto :__trim
:trim_front
    setlocal EnableDelayedExpansion
    set "front=" & set "back=len+1" & goto :__trim
:trim_back
    setlocal EnableDelayedExpansion
    set "front=0" & set "back=" & goto :__trim
:__trim
    set "var=%~1" & if not defined var exit /b 1
    set "chars=%~2" & if not defined chars set "chars= "
    echo chars=!chars!
    ( set "_s=!%var%!" & set "len=0" & for %%N in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
        if not "!_s:~%%N,1!"=="" ( set /a "len+=%%N" & set "_s=!_s:~%%N!" )
    ) ) & rem len = Number of characters in val - 1.
    if defined front set /A "front=%front%"
    if defined back  set /A "back=%back%"
    ( for /L %%i in (0,1,%len%) do if not defined front (
        call set "subset=%%chars:!%var%:~%%i,1!=%%"
        if "!subset!"=="!chars!" set "front=%%i"
    ) ) & if not defined front set /A "front=len+1"
    ( for /L %%i in (%len%,-1,%front%) do if not defined back (
        call set "subset=%%chars:!%var%:~%%i,1!=%%"
        if "!subset!"=="!chars!" set "back=%%i"
    ) ) & if not defined back set /A "back=front-1"
    set /A "len=back-front+1"
    set "%var%=!%var%:~%front%,%len%!"
    call :return 0 %var%


:: call :foreach  OUTV|"outv list"  LSTV|"list"  SEPV|"sep"  [CMDV|"cmd"]   (Requires: :return, :pushv_popv, :dereference, :escape_for_pct_expansion)
::   Splits a list into tokens using a SEP string, then runs command CMD on each token.
:foreach
    setlocal DisableDelayedExpansion & set "_localdepth=0"
    set "_num=0"
    set "_out=%~1"
    call :dereference _lst=%%%%2 || call :return %_out%
    call :dereference _sep=%%%%3
    call :dereference _cmd=%%%%4 || set "_cmd=echo(%%t"
    setlocal EnableDelayedExpansion & set /A "_localdepth+=1"
    set _lst
    set _sep
    echo "%sep%"
    if defined _sep for %%L in (^"^

^") do set "_lst="!_lst:%_sep%="%%~L"!"" & rem The formatting of the above two lines are critical. DO NOT REMOVE
    for /F "tokens=* delims=" %%t in (^"!_lst!^") do (
        setlocal EnableDelayedExpansion & set /A "_localdepth+=1"
        for /L %%z in (!_localdepth!,-1,1) do endlocal & rem Run outer loop in foreach's base context
        if "%%t"=="""" ( rem Empty token; do not change
            if /i not "%SKIP_EMPTY_TOKENS%"=="true" (
                set /A "_num+=1" & set "_tok=%%~t" & set "_utok=%%~t"
                %_cmd%
            )
        ) else ( rem Nonempty token; unquote once
            for /F "tokens=* delims=" %%t in ("%%~t") do (
                set /A "_num+=1" & set "_tok=%%t" & set "_utok=%%~t"
                %_cmd%
            )
        )
    )
    call :return %_out%


:: -----------------------------------------------------------------------------
:: FRAMEWORK (DO NOT EDIT)
:: -----------------------------------------------------------------------------

:: @call :batchinit
:batchinit
    @(goto) 2>nul & (
        setlocal DisableDelayedExpansion
        set  BATCH_STARTTIME=%TIME%
        echo off
        set  ERRORLEVEL=
        set ^"LF=^

^" 2>nul & rem The formatting of the above two lines are critical. DO NOT MODIFY
        ((for /L %%P in (1,1,70) do pause>nul)&set /p "TAB=")<"%COMSPEC%" & call set "TAB=%%TAB:~0,1%%"
        set "BATCH_FILENAME=%~nx0"
        set "BATCH_FILE=%~f0"
        set "BATCH_DIR=%~dp0" & call set "BATCH_DIR=%%BATCH_DIR:~0,-1%%"
        set "BATCH_WORKDIR=%CD%"
        set "exit.EXIT_HOOK=on_exit_do_nothing"
        set "throw.ERROR_HOOK=on_error_do_exit"
        set "argparse.HELP_HOOK=on_help"
        echo %CMDCMDLINE%|find /i """%~f0""">nul || set "BATCH_UNATTENDED=y"
        call set "BATCH_ARGS=%* %%*"
        call :parse_args BATCH_ARGS
    )

:: call :require_elevated_privilege
::   Checks the script is running with Administrator (elevated) privilege, else exits with an error.
:require_elevated_privilege
    setlocal DisableDelayedExpansion
    net file >nul 2>&1 || (
        set "exit.EXIT_HOOK="
        call :throw "Script '%BATCH_FILE%' must be run with Administrator [elevated] privilege."
        call :exit 1
    )
    call :return 0

:: call :require_nonelevated_privilege
::   Checks the script is running with User (nonelevated) privilege, else exits with an error.
:require_nonelevated_privilege
    setlocal DisableDelayedExpansion
    net file >nul 2>&1 && (
        set "exit.EXIT_HOOK="
        call :throw "Script '%BATCH_FILE%' must be run with User [nonelevated] privilege."
        call :exit 1
    )
    call :return 0

:: call :parse_args ARGSV           (Requires: :return, :pushv_popv, :dereference, :escape_for_pct_expansion)
:parse_args
    setlocal EnableDelayedExpansion
    set "__argsv__=%1" & if defined __argsv__ ( set "__args__=!%1!" ) else ( exit /b 1 )
    call :escape_for_pct_expansion __args__ EDE
    call :escape_for_pct_expansion __args__ EDE & rem string will be %-expanded twice
    set "BATCH_ARGS=" & set "BATCH_ARGS[#]=0" & set "__outv__=           BATCH_ARGS BATCH_ARGS[#]"
    set "BATCH_PRGS=" & set "BATCH_PRGS[#]=0" & set "__outv__=%__outv__% BATCH_PRGS BATCH_PRGS[#]"
    set "BATCH_FLGS=" & set "BATCH_FLGS[#]=0" & set "__outv__=%__outv__% BATCH_FLGS BATCH_FLGS[#]"
    set "__tok__=" & for %%L in (^"^

^") do for /F "tokens=* delims=" %%t in ("!__args__: =%%~L !") do (
        set "__tok__=!__tok__!%%t" & set "__arg__= !__tok__:""""="!"
        set "__n=-1" & for /F "tokens=* delims=" %%n in (^"!__arg__:^"^=^"^%%~L!^ ^") do set /A "__n+=1"
        set /a "__m=__n%%2" & if !__m! EQU 0 ( set "__tok__=" & rem Arg is incomplete if it contains an odd number of " quotes
            for /F "tokens=* delims= " %%a in ("!__arg__!") do (
                for /F "tokens=* delims=/ " %%b in ("!__arg__!") do (
                    for /F "tokens=1,* delims=/= " %%c in ("!__arg__!") do (  rem Arg is incomplete if only whitespace, =, /
                        set "__arg__=%%a" & set "__prg__=%%b" & set "__flg__=%%c" & set "__val__=%%d"
                        set "__ref__="& set "__name__=" & set "__value__="
                        if defined __arg__ (
                            set /A "BATCH_ARGS[#]+=1"
                            set "BATCH_ARGS[!BATCH_ARGS[#]!]=!__arg__!"
                            set "BATCH_ARGS=!BATCH_ARGS! !__arg__!"
                            if "!__arg__!"=="!__prg__!" ( set /A "BATCH_PRGS[#]+=1" & rem Positional arg
                                set "__ref__="
                                set "__name__=BATCH_PRGS[!BATCH_PRGS[#]!]"
                                set "__value__=!__prg__!"
                                set "BATCH_PRGS=!BATCH_PRGS! !__value__!"
                            ) else if "!__flg__!"=="?" (
                                if defined argparse.HELP_HOOK call :%argparse.HELP_HOOK%
                            ) else ( set /A "BATCH_FLGS[#]+=1" & rem Flag arg
                                set "__ref__=BATCH_FLGS[!BATCH_FLGS[#]!]"
                                set "__name__=!__flg__!"
                                set "__value__=!__val__!"
                                set "BATCH_FLGS=!BATCH_FLGS! !__name__!"
                            )
                            if defined __value__ if "!__value__:~0,1!"==^""" set "__value__=!__value__:~1,-1!"
                            if defined __value__ set "__value__=!__value__:""="!"
                            if defined __name__ set "!__name__!=!__value__!"
                            if defined __ref__ set "!__ref__!=!__name__!"
                            set "__outv__=!__outv__! BATCH_ARGS[!BATCH_ARGS[#]!] !__ref__! !__name__!"
    )   )   )   )   )   )
    call :return 0 %__outv__%

:: call :throw ["error message"]
::  Prints an error message, then calls throw.ERROR_HOOK.
:throw
    (goto) 2>nul & (
        setlocal DisableDelayedExpansion
        call echo   --[ %%~0 ]-- 1>&2
        if "%~1"=="" ( echo ERROR: A critical error has occurred. 1>&2
        ) else (       echo ERROR: %~1 1>&2 )
        if defined throw.ERROR_HOOK call :%throw.ERROR_HOOK%
        endlocal
    ) & (call)

:: call :exit [ERRORLEVEL] [VAR1] [VAR2] ...          (Requires: :pushv_popv, :dereference, :escape_for_pct_expansion)
::  Exits this script, returning one or more variables to the parent script.
:exit
    setlocal DisableDelayedExpansion & set "_exitcode_=%ERRORLEVEL%" & set "_doscriptexit_=& (goto) 2>nul"
:exit_call_stack
    if not "%_doscriptexit_%"=="& (goto) 2>nul" setlocal DisableDelayedExpansion & "_exitcode=%ERRORLEVEL%" & set "_doscriptexit_="
    if defined exit.EXIT_HOOK call :%exit.EXIT_HOOK%
    set "_copyvars_=" & for /F "tokens=* delims=-0123456789 " %%a in ("%*") do set "_copyvars_=%%a"
    if not "%_copyvars_%"=="%*" set "_exitcode_=%1"
    set "_switchcmd_=call :__exit_call_stack_helper %_doscriptexit_%"
    call :pushv_popv _switchcmd_ _copyvars_ & if "%_exitcode_%"=="0" (call ) else (call)
    echo ERROR: Failed to :exit 2>nul & exit /b 99
:__exit_call_stack_helper
    ( (goto) & (goto) & ( setlocal EnableDelayedExpansion
        call set "caller=%%~0" & if "!caller:~0,1!"==":" call :__exit_call_stack_helper
    endlocal ) ) >nul 2>nul

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
