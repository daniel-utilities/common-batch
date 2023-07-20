@echo off
setlocal

for %%Q in ("%~dp0\.") do set "parent_dir=%%~fQ"
set "working_dir=%CD%"
set "scripts_dir=scripts"

:: Checks
if not exist "%working_dir%\.git" (
    echo ERROR: Script must be run from root of Git repository.
    exit /b 1
)

if not exist "%working_dir%\.gitconfig" (
    echo ERROR: .gitconfig not found.
    exit /b 1
)

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
:: chmod --recursive --verbose +x "$scripts_dir"

echo.
echo Complete.

endlocal
exit /b 0
