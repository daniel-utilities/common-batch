@echo off & goto :.%1 1>nul 2>nul || call man.bat "%~f0" "Usage"
::==============================================================================
::.Usage:
::   decay.bat /test{N} [var]
::
:: For studying patterns in how special characters "decay" during
::   sequential %%-expansions.
::
:: Percent (early) expansion occurs when:
::  - Expanding a named variable:          %var%
::  - Expanding a FOR-loop metavariable:    %%A
::
:: Certain special characters are mangled or removed during %%-expansion.
:: We wish to escape these strings such that they "decay" into their original value.
::
:: Unfortunately, the "decay product" of a %%-expansion depends on several factors:
::  1. State of DisableDelayedExpansion (D) or EnableDelayedExpansion(E)
::  2. Inside or outside a code block ()
::  3. Inside or outside double-quotes ""
::  4. Presence of other special characters ("!")
::
:: A general escaping procedure must at least take into account the sequence of
::   D/E expansions the variable will undergo.
::


::==============================================================================
:./test1 [var]
::
:: Strings which decay to a single Linefeed (LF) character after a sequence
::   of %%-expansions in Unquoted DisableDelayedExpansion (uD) or
::   Unquoted EnableDelayedExpansion (uE) contexts.
::
:: Each string of carets (^) is proceeded by !LF!!LF!.
::
:: Assumes:
::  - All %% expansion happens inside escaped doublequotes ^"^"
::  - All %% expansion happens inside a code block ()
::  - %% in EnableDelayedExpansion is proceeded by an unpaired "!".
::
::    For uD:  ( set ^"val=%val%^"  )
::    For uE:  ( set ^"val=%val%^"! )
::
:: Decay Sequence      # caret (^)      # carets (2^N-1)
::______________________________________________________
:: LF.uD                           1                   1
::   LF.uD.uD                  3   1               2   1
::     LF.uD.uD.uD     7   1   3   1       3   1   2   1
::     LF.uD.uD.uE    15   1   3   1       4   1   2   1
::   LF.uD.uE                  7   1               3   1
::     LF.uD.uE.uD    15   1   7   1       4   1   3   1
::     LF.uD.uE.uE    31   1   7   1       5   1   3   1
:: LF.uE                           3                   2
::   LF.uE.uD                  7   3               3   2
::     LF.uE.uD.uD    15   3   7   3       4   2   3   2
::     LF.uE.uD.uE    31   3   7   3       5   2   3   2
::   LF.uE.uE                 15   3               4   2
::     LF.uE.uE.uD    31   3  15   3       5   2   4   2
::     LF.uE.uE.uE    63   3  15   3       6   2   4   2
::
setlocal DisableDelayedExpansion

set ^"LF=^
%= EMPTY LINE =%
^"

setlocal EnableDelayedExpansion

set "LF.uD=^^!LF!!LF!"!
::          1
    set "LF.uD.uD=^^^^^^!LF!!LF!^^!LF!!LF!"!
    ::             3             1
        set "LF.uD.uD.uD=^^^^^^^^^^^^^^!LF!!LF!^^!LF!!LF!^^^^^^!LF!!LF!^^!LF!!LF!"!
        ::                7                     1         3             1
        set "LF.uD.uD.uE=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^!LF!!LF!^^^^^^!LF!!LF!^^!LF!!LF!"!
        ::               15                                     1         3             1
    set "LF.uD.uE=^^^^^^^^^^^^^^!LF!!LF!^^!LF!!LF!"!
    ::             7                     1
        set "LF.uD.uE.uD=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^!LF!!LF!^^^^^^^^^^^^^^!LF!!LF!^^!LF!!LF!"!
        ::               15                                     1         7                     1
        set "LF.uD.uE.uE=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^!LF!!LF!^^^^^^^^^^^^^^!LF!!LF!^^!LF!!LF!"!
        ::               31                                                                     1         7                     1
set "LF.uE=^^^^^^!LF!!LF!"!
::          3
    set "LF.uE.uD=^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!"!
    ::             7                     3
        set "LF.uE.uD.uD=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!"!
        ::               15                                     3             7                     3
        set "LF.uE.uD.uE=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!"!
        ::               31                                                                     3             7                     3
    set "LF.uE.uE=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!"!
    ::            15                                     3
        set "LF.uE.uE.uD=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!"!
        ::               31                                                                     3            15                                     3
        set "LF.uE.uE.uE=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!"!
        ::               63                                                                                                                                     3            15                                     3


set "var=%~2" & if not defined var set "var=LF.uE.uE.uE"
call :expand %var%
exit /b 0


::==============================================================================
:./test2 [var]
::
:: Strings which decay to a single Linefeed (LF) character after a sequence
::   of %%-expansions in Quoted DisableDelayedExpansion (qD) or
::   Quoted EnableDelayedExpansion (qE) contexts.
::
:: Quotes are desirable because they remove the need to escape most special
::   characters, and reduce the number of carets required overall.
::
:: However, linefeed characters cannot be inserted directly into a quoted string;
::   they can only be included during for-loop metavariable expansion (%%L) or
::   !!-expansion (if EnableDelayedExpansion is active).
::
:: Each string of carets (^) is proceeded by !qLF!!qLF!.
::
:: Assumes:
::  - All %% expansion happens inside doublequotes ""
::  - All %% expansion happens inside a code block ()
::  - %% in EnableDelayedExpansion is proceeded by an unpaired "!".
::  - For-loop Metavariable %%L is available and contains quoted "!LF!".
::
::    For qD:  for %%L in (^"%LF.uD%^") do ( set "val=%val%"  )
::    For qE:  for %%L in (^"%LF.uE%^") do ( set "val=%val%"! )
::
:: Decay Sequence      # caret (^)      # carets (2^N-1)
::______________________________________________________
:: LF.qD
::   LF.qD.qD
::     LF.qD.qD.qD
::     LF.qD.qD.qE
::   LF.qD.qE
::     LF.qD.qE.qD
::     LF.qD.qE.qE
:: LF.qE
::   LF.qE.qD
::     LF.qE.qD.qD
::     LF.qE.qD.qE
::   LF.qE.qE
::     LF.qE.qE.qD
::     LF.qE.qE.qE
::
setlocal DisableDelayedExpansion

set ^"LF=^
%= EMPTY LINE =%
^"
set "qLF=%%~L"

setlocal EnableDelayedExpansion
set "LF.uD=^^!LF!!LF!"!
set "LF.uD.uD=^^^^^^!LF!!LF!^^!LF!!LF!"!
set "LF.uD.uD.uD=^^^^^^^^^^^^^^!LF!!LF!^^!LF!!LF!^^^^^^!LF!!LF!^^!LF!!LF!"!
set "LF.uD.uD.uE=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^!LF!!LF!^^^^^^!LF!!LF!^^!LF!!LF!"!
set "LF.uD.uE=^^^^^^^^^^^^^^!LF!!LF!^^!LF!!LF!"!
set "LF.uD.uE.uD=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^!LF!!LF!^^^^^^^^^^^^^^!LF!!LF!^^!LF!!LF!"!
set "LF.uD.uE.uE=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^!LF!!LF!^^^^^^^^^^^^^^!LF!!LF!^^!LF!!LF!"!
set "LF.uE=^^^^^^!LF!!LF!"!
set "LF.uE.uD=^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!"!
set "LF.uE.uD.uD=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!"!
set "LF.uE.uD.uE=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!"!
set "LF.uE.uE=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!"!
set "LF.uE.uE.uD=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!"!
set "LF.uE.uE.uE=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!"!

set "LF.qD=%%~L"!
::          0
    set "LF.qD.qD=%%L"!
    ::             3
        set "LF.qD.qD.qD=^^^^^^^^^^^^^^!LF!!LF!^^!LF!!LF!^^^^^^!LF!!LF!^^!LF!!LF!"!
        ::                7                     1         3             1
        set "LF.qD.qD.qE=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^!LF!!LF!^^^^^^!LF!!LF!^^!LF!!LF!"!
        ::               15                                     1         3             1
    set "LF.qD.qE=^^^^^^^^^^^^^^!LF!!LF!^^!LF!!LF!"!
    ::             7                     1
        set "LF.qD.qE.qD=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^!LF!!LF!^^^^^^^^^^^^^^!LF!!LF!^^!LF!!LF!"!
        ::               15                                     1         7                     1
        set "LF.qD.qE.qE=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^!LF!!LF!^^^^^^^^^^^^^^!LF!!LF!^^!LF!!LF!"!
        ::               31                                                                     1         7                     1
set "LF.qE=^^^^^^!LF!!LF!"!
::          3
    set "LF.qE.qD=^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!"!
    ::             7                     3
        set "LF.qE.qD.qD=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!"!
        ::               15                                     3             7                     3
        set "LF.qE.qD.qE=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!"!
        ::               31                                                                     3             7                     3
    set "LF.qE.qE=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!"!
    ::            15                                     3
        set "LF.qE.qE.qD=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!"!
        ::               31                                                                     3            15                                     3
        set "LF.qE.qE.qE=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!"!
        ::               63                                                                                                                                     3            15                                     3


set "var=%~2" & if not defined var set "var=LF.qD.qD"
call :expand %var%
exit /b 0


::==============================================================================
:./test3 [var]
::
:: Strings which decay to a single closeparen ")" character after a sequence
::   of %%-expansions in Unquoted DisableDelayedExpansion (uD) or
::   Unquoted EnableDelayedExpansion (uE) contexts.
::
:: Each ")" is preceeded by a number of carets "^" such that the ")" is remains
::   escaped until the end of the expansion sequence.
::
:: Due to the escaped doublequotes ^"^", certain special characters including
::   ! ( ) & | < > ; = [ ] : ~ @ ^ * must be escaped.
::
:: Assumes:
::  - All %% expansion happens inside escaped doublequotes ^"^"
::  - All %% expansion happens inside a code block ()
::  - %% in EnableDelayedExpansion is proceeded by an unpaired "!".
::
::    For uD:  ( set ^"val=%val%^"  )
::    For uE:  ( set ^"val=%val%^"! )
::
:: Decay Sequence    # caret (^)       # carets (2^N-1)
::______________________________________________________
:: STR.uD                1                   1
::   STR.uD.uD           3                   2
::     STR.uD.uD.uD      7                   3
::     STR.uD.uD.uE     15                   4
::   STR.uD.uE           7                   3
::     STR.uD.uE.uD     15                   4
::     STR.uD.uE.uE     31                   5
:: STR.uE                3                   2
::   STR.uE.uD           7                   3
::     STR.uE.uD.uD     15                   4
::     STR.uE.uD.uE     31                   5
::   STR.uE.uE          15                   4
::     STR.uE.uE.uD     31                   5
::     STR.uE.uE.uE     63                   6
::

setlocal DisableDelayedExpansion
set "ESC=^"
set "STR=)" %= Breaks the expansion if not properly escaped =%

setlocal EnableDelayedExpansion

set "ESC.uD=^^"!
::          1
    set "ESC.uD.uD=^^^^^^"!
    ::            3
        set "ESC.uD.uD.uD=^^^^^^^^^^^^^^"!
        ::              7
        set "ESC.uD.uD.uE=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"!
        ::             15
    set "ESC.uD.uE=^^^^^^^^^^^^^^"!
    ::            7
        set "ESC.uD.uE.uD=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"!
        ::             15
        set "ESC.uD.uE.uE=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"!
        ::             31
set "ESC.uE=^^^^^^"!
::          3
    set "ESC.uE.uD=^^^^^^^^^^^^^^"!
    ::            7
        set "ESC.uE.uD.uD=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"!
        ::             15
        set "ESC.uE.uD.uE=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"!
        ::             31
    set "ESC.uE.uE=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"!
    ::           15
        set "ESC.uE.uE.uD=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"!
        ::             31
        set "ESC.uE.uE.uE=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"!
        ::             63


set "STR.uD=!ESC.uD!!STR!"
    set "STR.uD.uD=!ESC.uD.uD!!STR!"
        set "STR.uD.uD.uD=!ESC.uD.uD.uD!!STR!"
        set "STR.uD.uD.uE=!ESC.uD.uD.uE!!STR!"
    set "STR.uD.uE=!ESC.uD.uE!!STR!"
        set "STR.uD.uE.uD=!ESC.uD.uE.uD!!STR!"
        set "STR.uD.uE.uE=!ESC.uD.uE.uE!!STR!"
set "STR.uE=!ESC.uE!!STR!"
    set "STR.uE.uD=!ESC.uE.uD!!STR!"
        set "STR.uE.uD.uD=!ESC.uE.uD.uD!!STR!"
        set "STR.uE.uD.uE=!ESC.uE.uD.uE!!STR!"
    set "STR.uE.uE=!ESC.uE.uE!!STR!"
        set "STR.uE.uE.uD=!ESC.uE.uE.uD!!STR!"
        set "STR.uE.uE.uE=!ESC.uE.uE.uE!!STR!"

set "var=%~2" & if not defined var set "var=STR.uE.uE.uE"
call :expand %var%
exit /b 0


::==============================================================================
:./test4 [var]
::
:: Strings which decay to a single exclamation "!" character after a sequence
::   of %%-expansions in Quoted DisableDelayedExpansion (qD) or
::   Quoted EnableDelayedExpansion (qE) contexts.
::
:: Each "!" is preceeded by a number of carets "^" such that the "!" remains
::   escaped until the end of the expansion sequence.
:: Improperly escaped "!" are consumed if EnableDelayedExpansion (E) is active.
::
:: Assumes:
::  - All %% expansion happens inside doublequotes ""
::  - All %% expansion happens inside a code block ()
::  - %% in EnableDelayedExpansion is proceeded by an unpaired "!".
::  - For-loop Metavariable %%L is available and contains quoted "!LF!".
::
::    For qD:  for %%L in (^"%LF.uD%^") do ( set "val=%val%"  )
::    For qE:  for %%L in (^"%LF.uE%^") do ( set "val=%val%"! )
::
:: Decay Sequence    # caret (^)       # carets (2^N-1)
::______________________________________________________
:: STR.qD                 0                   0
::   STR.qD.qD            0                   0
::     STR.qD.qD.qD       0                   0
::     STR.qD.qD.qE       1                   1
::   STR.qD.qE            1                   1
::     STR.qD.qE.qD       1                   1
::     STR.qD.qE.qE       3                   2
:: STR.qE                 1                   1
::   STR.qE.qD            1                   1
::     STR.qE.qD.qD       1                   1
::     STR.qE.qD.qE       3                   2
::   STR.qE.qE            3                   2
::     STR.qE.qE.qD       3                   2
::     STR.qE.qE.qE       7                   3
::

setlocal DisableDelayedExpansion
set "ESC=^"
set "STR=!" %= Vanishes during E pct expansion if not properly escaped, even in quotes =%

setlocal EnableDelayedExpansion

set "ESC.uD=^^"!
set "ESC.uD.uD=^^^^^^"!
set "ESC.uD.uD.uD=^^^^^^^^^^^^^^"!
set "ESC.uD.uD.uE=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"!
set "ESC.uD.uE=^^^^^^^^^^^^^^"!
set "ESC.uD.uE.uD=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"!
set "ESC.uD.uE.uE=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"!
set "ESC.uE=^^^^^^"!
set "ESC.uE.uD=^^^^^^^^^^^^^^"!
set "ESC.uE.uD.uD=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"!
set "ESC.uE.uD.uE=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"!
set "ESC.uE.uE=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"!
set "ESC.uE.uE.uD=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"!
set "ESC.uE.uE.uE=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"!

set "ESC.qD="!
::          0
    set "ESC.qD.qD="!
    ::            0
        set "ESC.qD.qD.qD="!
        ::              0
        set "ESC.qD.qD.qE=^^"!
        ::              1
    set "ESC.qD.qE=^^"!
    ::            1
        set "ESC.qD.qE.qD=^^"!
        ::              1
        set "ESC.qD.qE.qE=^^^^^^"!
        ::              3
set "ESC.qE=^^"!
::          1
    set "ESC.qE.qD=^^"!
    ::            1
        set "ESC.qE.qD.qD=^^"!
        ::              1
        set "ESC.qE.qD.qE=^^^^^^"!
        ::              3
    set "ESC.qE.qE=^^^^^^"!
    ::            3
        set "ESC.qE.qE.qD=^^^^^^"!
        ::              3
        set "ESC.qE.qE.qE=^^^^^^^^^^^^^^"!
        ::              7


set "STR.qD=!ESC.qD!!STR!"
    set "STR.qD.qD=!ESC.qD.qD!!STR!"
        set "STR.qD.qD.qD=!ESC.qD.qD.qD!!STR!"
        set "STR.qD.qD.qE=!ESC.qD.qD.qE!!STR!"
    set "STR.qD.qE=!ESC.qD.qE!!STR!"
        set "STR.qD.qE.qD=!ESC.qD.qE.qD!!STR!"
        set "STR.qD.qE.qE=!ESC.qD.qE.qE!!STR!"
set "STR.qE=!ESC.qE!!STR!"
    set "STR.qE.qD=!ESC.qE.qD!!STR!"
        set "STR.qE.qD.qD=!ESC.qE.qD.qD!!STR!"
        set "STR.qE.qD.qE=!ESC.qE.qD.qE!!STR!"
    set "STR.qE.qE=!ESC.qE.qE!!STR!"
        set "STR.qE.qE.qD=!ESC.qE.qE.qD!!STR!"
        set "STR.qE.qE.qE=!ESC.qE.qE.qE!!STR!"

set "var=%~2" & if not defined var set "var=STR.qE.qD.qE"
call :expand %var%
exit /b 0


::==============================================================================
:./test5 [var]
::

setlocal DisableDelayedExpansion
set ^"LF=^
%= EMPTY LINE =%
^"
set "ESC=^"

setlocal EnableDelayedExpansion

set "LF.D=^^!LF!!LF!"!
set "LF.D.D=^^^^^^!LF!!LF!^^!LF!!LF!"!
set "LF.D.E=^^^^^^^^^^^^^^!LF!!LF!^^!LF!!LF!"!
set "LF.E=^^^^^^!LF!!LF!"!
set "LF.E.D=^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!"!
set "LF.E.E=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!"!
set "ESC.D=^^"!
set "ESC.D.D=^^^^^^"!
set "ESC.D.E=^^^^^^^^^^^^^^"!
set "ESC.E=^^^^^^"!
set "ESC.E.D=^^^^^^^^^^^^^^"!
set "ESC.E.E=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"!

set "STR.D.D=!ESC.D.D!(line1!ESC.D.D!)!LF.FD!!ESC.D.D!(line2!ESC.D.D!)!LF.FD!!ESC.D.D!(line3!ESC.D.D!)"
set "STR.E.E=!ESC.E.E!(line1!ESC.E.E!)!LF.FE!!ESC.E.E!(line2!ESC.E.E!)!LF.FE!!ESC.E.E!(line3!ESC.E.E!)"

set "var=%~2" & if not defined var set "var=STR.D.D"
call :loop %var%
exit /b 0



::==============================================================================
:./test6 [var]
::
setlocal DisableDelayedExpansion
set ^"LF=^
%= EMPTY LINE =%
^"
set "ESC=^"
((for /L %%a in (1,1,70) do pause>nul) & set /p "TAB=")<"%COMSPEC%"
set "TAB=%TAB:~0,1%"

setlocal EnableDelayedExpansion

set "LF.D=^^!LF!!LF!"!
set "LF.D.D=^^^^^^!LF!!LF!^^!LF!!LF!"!
set "LF.D.E=^^^^^^^^^^^^^^!LF!!LF!^^!LF!!LF!"!
set "LF.E=^^^^^^!LF!!LF!"!
set "LF.E.D=^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!"!
set "LF.E.E=^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^!LF!!LF!^^^^^^!LF!!LF!"!
set "ESC.qD="!
set "ESC.qD.qD="!
set "ESC.qD.qD.qD="!
set "ESC.qD.qD.qE=^^"!
set "ESC.qD.qE=^^"!
set "ESC.qD.qE.qD=^^"!
set "ESC.qD.qE.qE=^^^^^^"!
set "ESC.qE=^^"!
set "ESC.qE.qD=^^"!
set "ESC.qE.qD.qD=^^"!
set "ESC.qE.qD.qE=^^^^^^"!
set "ESC.qE.qE=^^^^^^"!
set "ESC.qE.qE.qD=^^^^^^"!
set "ESC.qE.qE.qE=^^^^^^^^^^^^^^"!

set ^"STR=!LF!a=^^^^^^^!var^^^!  a=" ^^^^""b""^^^^ "!LF!" a=b "!LF!!LF!a=!LF!"!

call :printvar STR
call :args.split STR STR "^^"
call :printvar STR
for /F delims^=^ eol^= %%T in ("!STR!") do (
    set "tok=%%T"!
    call :printvar tok
)

exit /b 0



:args.split input_var output_var [extra_escape]
::
::
::
    if "!!"=="" (   %= Returns to E context =%
        setlocal EnableDelayedExpansion
        set "return.LF=!LF!"!
        set "return.PCT=%%"!
        set "return.CRT=%~3^^^^"!
        set "return.EXC=%~3^^^!"!
    ) else (        %= Returns to D context =%
        setlocal EnableDelayedExpansion
        set "return.LF=!LF!"!
        set "return.PCT=%%"!
        set "return.CRT=%~3^^"!
        set "return.EXC=%~3^!"!
    )
    set "str=!%~1!"
    set "outv=%~2" & if not defined outv set "outv=%~1"
    if not defined str (goto) 2>nul & set "%outv%=" & (call )
    set ^"str=!str:%LF.D%= !"
    set "str=!str:%%=%%2!"
    set "str=!str:^=%%3!"
    set "n4=%%4" & set "str=%str:!=!n4!%"
    set "return=" & set "numq=0"
    for /F delims^=^ eol^= %%T in (^"^"!str:"="%LF.D%"!"^") do (
        set /A "numq=(numq+1) %% 2"
        set "tok=%%~T"!
        if !numq!==1 ( if defined tok (
                    set ^"tok=!tok: =%%~1!"      %= Outside quotes, split whitespace into LF =%
                    set ^"tok=!tok:%TAB%=%%~1!"
        ) ) else set ^"tok="!tok!"^"            %= Inside quotes, put inside quotes =%
        set "return=!return!!tok!"
    )
    for %%1 in ("!return.LF!") do for /F "tokens=1-3" %%2 in ("!return.PCT! !return.CRT! !return.EXC!") do (goto) 2>nul & (
        set "%outv%=%return%"
    ) & (call )


:==========================================================================================

:loop var
    setlocal EnableDelayedExpansion
    set "var=%~1" & if not defined var exit /b 1
    set "val=!%var%!"

    cls & echo(
    echo(====================
    echo(    %var%
    echo(====================
    call :printvar val

    for /F "tokens=1* delims=." %%A in ("%var%") do ( %= Set D/E for the loop subject and body separately =%
        if "%%A"=="D" ( if "!!"==""     setlocal DisableDelayedExpansion
        ) else          if not "!!"=="" setlocal EnableDelayedExpansion

        for %%L in (^"%LF.D%^") do for /F delims^=^ eol^= %%T in ("%val%"!) do (  %= Print each line =%

            if "%%B"=="D" ( if "!!"==""     setlocal DisableDelayedExpansion
            ) else          if not "!!"=="" setlocal EnableDelayedExpansion

            set "line=%%T"!

            call :printvar line
        )
    )
    exit /b 0



:printvar var
    setlocal EnableDelayedExpansion
    set "var=%~1"
    echo(%var%=[!%var%!]!LF!
    endlocal
    exit /b 0

:printvarvar var
    setlocal EnableDelayedExpansion
    set "var=!%~1!"
    echo(%var%=[!%var%!]!LF!
    endlocal
    exit /b 0

:expand var
    setlocal EnableDelayedExpansion
    set "var=%~1" & if not defined var exit /b 1

    cls & echo(

    for %%M in (%var:.= %) do call :expand.%%M 2>nul && (
        echo(====================
        echo(    %%M expansion
        echo(====================
        call :printvar val
        echo(Compare to^:
        call :printvarvar compare_to
    ) || (
        set "val=!%var%!"
        set "final_product=%%M"
        set "decay_sequence=%%M"
        echo(====================
        echo(    %var%
        echo(====================
        call :printvar val
    )

    exit /b 0

:expand.uD
    setlocal EnableDelayedExpansion
    set "decay_sequence=!decay_sequence!.uD"
    set "compare_to=!final_product!!var:%decay_sequence%=!"
    (goto) 2>nul & (
        setlocal DisableDelayedExpansion
        set "decay_sequence=%decay_sequence%"
        set "compare_to=%compare_to%"
        set ^"val=%val%^"
    ) & (call )

:expand.uE
    setlocal EnableDelayedExpansion
    set "decay_sequence=!decay_sequence!.uE"
    set "compare_to=!final_product!!var:%decay_sequence%=!"
    (goto) 2>nul & (
        setlocal EnableDelayedExpansion
        set "decay_sequence=%decay_sequence%"
        set "compare_to=%compare_to%"
        set ^"val=%val%^"!
    ) & (call )

:expand.qD
    setlocal EnableDelayedExpansion
    set "decay_sequence=!decay_sequence!.qD"
    set "compare_to=!final_product!!var:%decay_sequence%=!"
    (goto) 2>nul & (
        setlocal DisableDelayedExpansion
        set "decay_sequence=%decay_sequence%"
        set "compare_to=%compare_to%"
        for %%L in (^"%LF.uD%^") do set "val=%val%"
    ) & (call )

:expand.qE
    setlocal EnableDelayedExpansion
    set "decay_sequence=!decay_sequence!.qE"
    set "compare_to=!final_product!!var:%decay_sequence%=!"
    (goto) 2>nul & (
        setlocal EnableDelayedExpansion
        set "decay_sequence=%decay_sequence%"
        set "compare_to=%compare_to%"
        for %%L in (^"%LF.uE%^") do set "val=%val%"!
    ) & (call )