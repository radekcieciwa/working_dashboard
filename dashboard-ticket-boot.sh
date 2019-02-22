#!/usr/bin/env bash
#
#	Initilize a ticket with git worktree.
# 	We don't assume any issue as we don't have any submodules.
#

function usage() {
  echo "usage dashboard boot <jira ticket>"
}

if [ "$#" -ne 1 ]; then
    usage
    exit 1
fi

# FIXME: Right now we work on assumption this is always the same as ticket number
TICKET_NUMBER=$1
TICKET_DIR_NAME="$1"

echo "Booting $TICKET_NUMBER..."
git -C $SOURCE_REPO_PATH worktree add "$TICKETS_WORKSPACE_DIR/$TICKET_DIR_NAME"
if [ $? -ne 0 ]; then
  exit 1
fi

echo "Aida process..."
cd "$TICKETS_WORKSPACE_DIR/$TICKET_DIR_NAME"
pwd
./aida -ei $TICKET_NUMBER
if [ $? -ne 0 ]; then
  exit 1  # or $?
else
  echo "Successfully created: $TICKET_NUMBER"
fi
