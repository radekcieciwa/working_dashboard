#!/usr/bin/env bash
#
#	Initilize a ticket with git worktree.
# 	We don't assume any issue as we don't have any submodules.
#


function usage() {
  echo "Usage: $0 <[add; clear]>"
}

if [ "$#" -ne 1 ]; then
    usage
    exit 1
fi

COPY_NAME="tmp_working_copy"
MAIN_WORKSPACE_ROOT=/Users/radoslawcieciwa/Development/iOS/Badoo
MAIN_REPO_PATH=/Users/radoslawcieciwa/Development/iOS/Badoo/_source

if [ "$1" = "add" ]; then
  echo "Start"
  git -C $MAIN_REPO_PATH worktree add "$MAIN_WORKSPACE_ROOT/$COPY_NAME"
  echo "Done!"
elif [ "$1" = "clear" ]; then
  DIR=$(dirname $0)
  $DIR/dashboard-ticket-delete.sh $COPY_NAME
else
  usage
fi
