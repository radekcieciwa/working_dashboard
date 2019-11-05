#!/usr/bin/env bash
#
#	Initilize a ticket with git worktree.
# 	We don't assume any issue as we don't have any submodules.
#

function usage() {
  echo "usage dashboard patch-boot"
}

if [ "$#" -ne 0 ]; then
    usage
    exit 1
fi

# FIXME: Right now we work on assumption this is always the same as ticket number
TICKET_DIR_NAME="branch_$RANDOM"

echo "Booting $TICKET_DIR_NAME..."
git -C $SOURCE_REPO_PATH worktree add "$TICKETS_WORKSPACE_DIR/$TICKET_DIR_NAME"
if [ $? -ne 0 ]; then
  exit 1
else
  echo "cd $TICKETS_WORKSPACE_DIR/$TICKET_DIR_NAME" | pbcopy
  echo "Successfully created and copied to pasteboard: $TICKET_DIR_NAME"
fi
