@echo off
setlocal

for %%Q in ("%~dp0\.") do set "parent_dir=%%~fQ"
set "working_dir=%CD%"
for /F "delims=" %%i in ("%working_dir%") do set "project_name=%%~ni"
set "scripts_dir=scripts"


rem Checks
if not exist "%working_dir%\.git" (
    echo ERROR: Script must be run from root of Git repository.
    exit /b 1
)

if not exist "%working_dir%\.gitconfig" (
    echo ERROR: .gitconfig not found.
    exit /b 1
)

rem if [[ "$OS" =~ "Windows" ]]; then   # Git Bash
rem     batfile="${0%.*}.bat"
rem     "$batfile"      # Run the same-named .bat file
rem     exit $?
rem fi


rem Start
echo. 
echo Stashing local changes...
git stash --include-untracked

echo.
echo Pulling latest revisions...
git checkout main
git pull origin main
git checkout dev
git pull origin dev

echo.
echo Installing .gitconfig...

git config --local include.path ../.gitconfig

if %ERRORLEVEL% neq 0 (
    echo ERROR: Could not install .gitconfig. Failed to modify local include.path
    exit /b 1
)

rem echo ""
rem echo "Making scripts executable..."
rem 
rem chmod --recursive --verbose +x "$scripts_dir"


rem End

endlocal
exit /b 0
