@echo off
setlocal DisableDelayedExpansion
set "ERRORLEVEL="
set "cmd=%~1"
set "iter=%~2"
if not defined cmd (
    set "iter=100000"
    set "cmd=setlocal enabledelayedexpansion & endlocal"
)

call :bench_function "" cmd %%iter%%

exit /b %ERRORLEVEL%


:: call :bench_command CMDV ITER DURATION_MS|""
::   Runs a command for ITER iterations, and reports the total time elapsed.
::     FUNC             Variable name containing a command to run.
::                      If command returns any ERRORLEVEL NEQ 0, the function returns immediately.
::     ITER             Integer, number of iterations.
::     DURATION_MS|""   Variable name in which to store the test duration (in milliseconds).
::                      If not provided, echos the results to stdout.
::
:bench_command
    setlocal DisableDelayedExpansion
    set "_cmdv=%~2" & if not defined _cmdv exit /b 1
    set "_iter=%~3" & if not defined _iter set "_iter=1"
    set "_retv=%~1"
    call set "_cmd=%%%_cmdv%%%" & if not defined _cmd exit /b 1

    rem Calculate the time to run an empty loop with %_iter% iterations
    echo.
    echo Initializing...
    set "_starttime=%TIME%"
    for /L %%i in (1,1,%_iter%) do @(
        rem
    )>nul || (
        call set "_exitcode=%%ERRORLEVEL%%"
        call echo Command iteration %%i returned ERRORLEVEL=%%_exitcode%%. 1>&2
        call exit /b %%_exitcode%%
    )
    set "_endtime=%TIME%"

    set /A "_starttime=(1%_starttime:~0,2%-100)*360000 + (1%_starttime:~3,2%-100)*6000 + (1%_starttime:~6,2%-100)*100 + (1%_starttime:~9,2%-100)"
    set /A "_endtime=(1%_endtime:~0,2%-100)*360000 + (1%_endtime:~3,2%-100)*6000 + (1%_endtime:~6,2%-100)*100 + (1%_endtime:~9,2%-100)"
    set /A "_loop_expand_ms=(_endtime-_starttime)*10"
    echo Empty loop duration=%_loop_expand_ms%ms

    echo.
    echo Timing %_iter% iterations of command: "%_cmd%"
    echo.

    set "_starttime=%TIME%"
    for /L %%i in (1,1,%_iter%) do @(
        %_cmd%
    )>nul || (
        call set "_exitcode=%%ERRORLEVEL%%"
        call echo Command iteration %%i returned ERRORLEVEL=%%_exitcode%%. 1>&2
        call exit /b %%_exitcode%%
    )
    set "_endtime=%TIME%"

    set /A "_starttime=(1%_starttime:~0,2%-100)*360000 + (1%_starttime:~3,2%-100)*6000 + (1%_starttime:~6,2%-100)*100 + (1%_starttime:~9,2%-100)"
    set /A "_endtime=(1%_endtime:~0,2%-100)*360000 + (1%_endtime:~3,2%-100)*6000 + (1%_endtime:~6,2%-100)*100 + (1%_endtime:~9,2%-100)"
    set /A "_duration_ms=(_endtime-_starttime)*10-_loop_expand_ms"
    set /A "_indiv_ms=_duration_ms/_iter"
    set /A "_indiv_us=(_duration_ms*1000/_iter)-(_indiv_ms*1000)"

    (goto) 2>nul & (
        if defined _retv (
            set "%_retv%=%_duration_ms%"
        ) else (
            echo.
            echo Completed %_iter% iterations in %_duration_ms%ms ^(approx. %_indiv_ms%.%_indiv_us%ms each^).
            echo.
        )
    ) & (call )
