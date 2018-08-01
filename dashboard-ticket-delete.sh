#!/usr/bin/env bash
#
#	Remove a ticket from worktree
#
#

function usage() {
  echo "Usage: $0 <WORKING_COPY>"
}

if [ "$#" -ne 1 ]; then
    usage
    exit 1
fi

WORKING_COPY=$1
MAIN_REPO_PATH=/Users/radoslawcieciwa/Development/iOS/Badoo/_source
FORCE_CLEANUP=0

echo "Start"
echo "Removing $WORKING_COPY ..."

git -C $MAIN_REPO_PATH worktree remove $WORKING_COPY

git -C $MAIN_REPO_PATH branch | grep $WORKING_COPY | while read -r branch ; do
  if [ "$FORCE_CLEANUP" = "1" ]; then
    echo "Force removing $branch branch ..."
    git -C $MAIN_REPO_PATH reset --hard
    git -C $MAIN_REPO_PATH clean -fdx # to remove all untracked files
    git -C $MAIN_REPO_PATH branch -d $branch -f
    echo "OK"
  else
    echo "Removing $branch branch ..."
    git -C $MAIN_REPO_PATH branch -d $branch
    echo "OK"
  fi
done

echo "Done!"
