#!/usr/bin/env bash


parent_dir="$(dirname "$(readlink -f "$0")")"
working_dir="$PWD"
project_name="$(basename "$working_dir")"
scripts_dir="scripts"


# Checks
if [[ ! -e "$working_dir/.git" ]]; then
    echo "ERROR: Script must be run from root of Git repository."
    exit 1
fi

if [[ ! -f "$working_dir/.gitconfig" ]]; then
    echo "ERROR: .gitconfig not found."
    exit 1
fi

# if [[ "$OS" =~ "Windows" ]]; then   # Git Bash, not Linux.
#     batfile="${0%.*}.bat"
#     "$batfile"      # Run the same-named .bat file
#     exit $?
# fi


# Start
echo ""
echo "Stashing local changes..."
git stash --include-untracked

echo ""
echo "Pulling latest revisions..."
git checkout main
git pull origin main
git checkout dev
git pull origin dev

echo ""
echo "Installing .gitconfig..."

git config --local include.path ../.gitconfig

if [[ $? != 0 ]]; then
    echo ERROR: Could not install .gitconfig. Failed to modify local include.path.
    exit 1
fi

echo ""
echo "Making scripts executable..."

chmod --recursive --verbose +x "$scripts_dir"


# End


exit 0
