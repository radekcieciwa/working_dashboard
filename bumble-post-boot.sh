#!/usr/bin/env bash
#
# Post-boot script for bumble repository
# Runs custom initialization after worktree checkout
#

TICKET_NUMBER=$1

if [ -z "$TICKET_NUMBER" ]; then
  echo "Error: TICKET_NUMBER not provided"
  exit 1
fi

echo "Running bumble post-boot process..."
pwd
./aida -ei $TICKET_NUMBER

if [ $? -ne 0 ]; then
  echo "Error: Post-boot process failed for $TICKET_NUMBER"
  exit 1
else
  echo "Post-boot process completed for $TICKET_NUMBER"
fi
