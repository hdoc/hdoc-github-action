#!/bin/sh

COMPILE_COMMANDS_PATH="$1"
API_KEY="$2"

echo "::debug::PWD = $PWD"
echo "::debug::COMPILE_COMMANDS_PATH = $COMPILE_COMMANDS_PATH"
echo "::debug::GITHUB_WORKSPACE = $GITHUB_WORKSPACE"

# $GITHUB_REPOSITORY is owner/projectname, and we only need projectname so
# we strip away the owner part.
REPO_NAME=$(echo $GITHUB_REPOSITORY | cut -d "/" -f 2)
echo "::debug::REPO_NAME = $REPO_NAME"

# If the string "/__w/" is present in compile commands (as part of a path of
# one of the compile commands in the JSON) then we can assume that the
# previous step of the action was done in a container-based GitHub action with
# a custom image.
# As a result, we have to rewrite all of the paths in the compile commands
# to not use the /__w path prefix and instead use /github/workspace as a path
# prefix so that hdoc can find the paths of the C++ files it analyzes.
# Why this is required:
# Unfortunately GitHub Actions doesn't persist workdir between steps of the
# same job so we have to resort to hacks like this. Furthermore, it doesn't
# even tell you what the previous path was so you have to do sketchy heuristics.
ORIGINAL_WORKDIR=""
if grep -Fq -m 1 "/__w/" "$COMPILE_COMMANDS_PATH"; then
    ORIGINAL_WORKDIR="/__w/$REPO_NAME/$REPO_NAME"
else
    ORIGINAL_WORKDIR="/home/runner/work/$REPO_NAME/$REPO_NAME"
fi
echo "::debug::ORIGINAL_WORKDIR = $ORIGINAL_WORKDIR"

sed -i "s+$ORIGINAL_WORKDIR+$GITHUB_WORKSPACE+g" "$COMPILE_COMMANDS_PATH"

HDOC_PROJECT_API_KEY="$API_KEY" hdoc --verbose
