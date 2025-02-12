@echo off
setlocal DisableDelayedExpansion

for %%Q in ("%~dp0\.") do set "parent_dir=%%~fQ"
set "working_dir=%CD%"
for /F "delims=" %%i in ("%working_dir%") do set "project_name=%%~ni"
set "scripts_dir=%parent_dir%"


:: Checks
if not exist "%working_dir%\.git" (
    echo ERROR: Script must be run from root of Git repository.
    exit /b 1
)

if not exist "%working_dir%\.gitconfig" (
    echo ERROR: .gitconfig not found.
    exit /b 1
)

:: if [[ "$OS" =~ "Windows" ]]; then   # Git Bash
::     batfile="${0%.*}.bat"
::     "$batfile"      # Run the same-named .bat file
::     exit $?
:: fi


:: Start
echo.
echo Installing .gitconfig...

git config --local include.path ../.gitconfig

if %ERRORLEVEL% neq 0 (
    echo ERROR: Could not install .gitconfig. Failed to modify local include.path
    exit /b 1
)

:: echo ""
:: echo "Making scripts executable..."
::
:: chmod --recursive --verbose u+x,g+x "$scripts_dir"


:: End

endlocal
exit /b 0
