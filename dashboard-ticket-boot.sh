#!/usr/bin/env bash
#
#	Initilize a ticket with git worktree.
# 	We don't assume any issue as we don't have any submodules.
#

TICKET_NUMBER=$1
TICKET_DIR_NAME="$1"
MAIN_WORKSPACE_ROOT=/Users/radoslawcieciwa/Development/iOS/Badoo
MAIN_REPO_PATH=/Users/radoslawcieciwa/Development/iOS/Badoo/_source

echo "Start"
git -C $MAIN_REPO_PATH worktree add "$MAIN_WORKSPACE_ROOT/$TICKET_DIR_NAME"
cd "$MAIN_WORKSPACE_ROOT/$TICKET_DIR_NAME"
pwd
echo "Booting ticket ..."
./aida -ei $TICKET_NUMBER
echo "Done!"
