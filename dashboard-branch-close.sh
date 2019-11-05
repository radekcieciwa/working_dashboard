#!/usr/bin/env bash
#
# Author: radekcieciwa@gmail.com
#

CURRENT_DIR=`basename "$PWD"`

read -p "This script will remove $CURRENT_DIR. Do you want to continue $1 [Yy]? " -n 1 -r -s </dev/tty
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  PATCH="patch_$CURRENT_DIR.diff"
  git add .
  if git diff-index --quiet HEAD --; then
    echo "No changes discovered in this branch. No patch file created."
  else
    git diff --cached --binary > "../$PATCH"
    if [ $? -ne 0 ]; then
      exit 1
    else
      echo "Successfully created: $PATCH in parent directory."
    fi
  fi

  $DASHBOARD_DIR/dashboard-ticket-delete.sh -f $CURRENT_DIR
fi
