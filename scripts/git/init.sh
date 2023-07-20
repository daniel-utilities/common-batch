#!/usr/bin/env bash


parent_dir="$(dirname "$(readlink -f "$0")")"
working_dir="$PWD"
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

# Start
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

echo ""
echo "Complete."


exit 0
