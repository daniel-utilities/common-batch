@echo off
setlocal DisableDelayedExpansion

call "%~dp0..\lib\@ARG.bat" /import

cls
echo(
set @
echo(

exit /b 0