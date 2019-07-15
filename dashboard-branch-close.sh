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
  git diff --cached --binary > "../$PATCH"

  if [ $? -ne 0 ]; then
    exit 1
  else
    echo "Successfully created: $PATCH in parent directory."
  fi

  $DASHBOARD_DIR/dashboard-ticket-delete.sh -f $CURRENT_DIR
fi
