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


::##################################### 2_RAW
set ^"@TEST.EMBED2_RAW=(^^^^^^^

^

^^^

^

echo line3 ^^^^^^^

^

^^^

^

echo line4 ^^^^^^^

^

^^^

^

^^^^^^^

^

^^^

^

)"

::##################################### 1_RAW
set ^"@TEST.EMBED1_RAW=(^^^

^

echo line2 ^^^

^

%@TEST.EMBED2_RAW% ^^^

^

echo line5 ^^^

^

^^^

^

)"

::##################################### 0_RAW
set ^"@TEST.EMBED0_RAW=(^

echo line1 ^

%@TEST.EMBED1_RAW% ^

echo line6 ^

^

)"




::##################################### 2
set ^"@TEST.EMBED2=(%###EOL%
echo line3 %###EOL%
echo line4 %###EOL%
%###EOL%
)"

::##################################### 1
set ^"@TEST.EMBED1=(%##EOL%
echo line2 %##EOL%
%@TEST.EMBED2% %##EOL%
echo line5 %##EOL%
%##EOL%
)"


::##################################### 0
set ^"@TEST.EMBED0=(%#EOL%
echo line1 %#EOL%
%@TEST.EMBED1% %#EOL%
echo line6 %#EOL%
%#EOL%
)"


setlocal EnableDelayedExpansion
echo ############################################
echo.
echo LF:
echo [!LF!]
echo.
echo #LF:
echo [!#LF!]
echo.
echo #EOL:
echo [!#EOL!]
echo.
echo ##LF:
echo [!##LF!]
echo.
echo ##EOL:
echo [!##EOL!]
echo.
echo ###LF:
echo [!###LF!]
echo.
echo ###EOL:
echo [!###EOL!]
echo.
echo ############################################
echo ##########  TEST EMBED_RAW   ###############
echo.
echo @TEST.EMBED0_RAW:
echo [!@TEST.EMBED0_RAW!]
echo.
%@TEST.EMBED0_RAW%
echo.
echo ############################################
echo ############  TEST EMBED   #################
echo.
echo @TEST.EMBED0:
echo [!@TEST.EMBED0!]
echo.
%@TEST.EMBED0%
echo.

exit /b 0
