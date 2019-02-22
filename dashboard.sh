#!/bin/sh
#
# Author Radoslaw Cieciwa <radekcieciwa@gmail.com>
#
# Entry point tool for dashboard.
#

export TICKETS_WORKSPACE_DIR="$BADOO_REPO_DIR"
export SOURCE_REPO_PATH="$BADOO_REPO_DIR/_source"

function query_LIST_OF_REPOS() {
  LIST_OF_REPOS=`git -C $SOURCE_REPO_PATH worktree list | awk '{ print $1 }' | grep -v $SOURCE_REPO_PATH | grep -v "tmp_working_copy" | cut -d '/' -f 7 | awk 'ORS=","' | sed 's/\(.*\),/\1 /'`
}

function usage() {
  echo "usage dashboard <command> [<args>]"
  echo
  echo "Most common usages"
  echo "you can run this command from any directory"
  echo
  echo "controls the jira ticket (creates a new branch) lifecycle"
  echo "  boot    runs aida process and enters the folder"
  echo "  delete  cleans local branches and worktree copy"
  echo "  copy"
  echo
  echo "display list of tickets (require jira credentials and python)"
  echo "  view    runs a python script to display current statuses"
  echo
  echo "review helper"
  echo "  review  TBD - Not yet ready"
}

function dashboard() {
  COMMAND=$1
  if [ "$COMMAND" = "boot" ]; then
    $DASHBOARD_DIR/dashboard-ticket-boot.sh ${@:2}
    if [ $? -eq 0 ]; then
      # FIXME: Same logic here and in the dashboard-ticket-boot.sh - needs to be unfied
      cd "$TICKETS_WORKSPACE_DIR/$2"
    fi
  elif [ "$COMMAND" = "delete" ]; then
    $DASHBOARD_DIR/dashboard-ticket-delete.sh ${@:2}
  elif [ "$COMMAND" = "view" ]; then
    query_LIST_OF_REPOS
    python $DASHBOARD_DIR/jira_dashboard.py $LIST_OF_REPOS
  elif [ "$COMMAND" = "copy" ]; then
    $DASHBOARD_DIR/dashboard-copy.sh ${@:2}
  else
    usage
  fi
}
