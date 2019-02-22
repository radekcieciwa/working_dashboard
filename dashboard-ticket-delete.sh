#!/usr/bin/env bash
#
#	Remove a ticket from worktree
#
#

function usage() {
  echo "usage dashboard delete <jira ticket>"
}

if [ "$#" -ne 1 ]; then
    usage
    exit 1
fi

WORKING_COPY=$1
FORCE_CLEANUP=0

echo "Start"
echo "Removing $WORKING_COPY..."

if [ "$FORCE_CLEANUP" = "1" ]; then
  rm -rf $WORKING_COPY
  git -C $SOURCE_REPO_PATH worktree prune
fi

git -C $SOURCE_REPO_PATH worktree remove $WORKING_COPY

git -C $SOURCE_REPO_PATH branch | grep $WORKING_COPY | while read -r branch ; do
  if [ "$FORCE_CLEANUP" = "1" ]; then
    echo "Force removing $branch branch ..."
    git -C $SOURCE_REPO_PATH reset --hard
    git -C $SOURCE_REPO_PATH clean -fdx # to remove all untracked files
    git -C $SOURCE_REPO_PATH branch --force -D $branch
    echo "OK"
  else
    echo "Removing $branch branch ..."
    git -C $SOURCE_REPO_PATH branch -d $branch
    echo "OK"
  fi
done

if [ $? -ne 0 ]; then
  echo "$WORKING_COPY cleaning completed with error $?"
  exit 1
else
  echo "$WORKING_COPY cleaning done!"
fi
