#!/bin/sh
#
# Author Radoslaw Cieciwa <radekcieciwa@gmail.com>
#
# Entry point tool for dashboard.
#

export TICKETS_WORKSPACE_DIR="$BADOO_REPO_DIR"
export SOURCE_REPO_PATH="$BADOO_REPO_SRC"

function query_list_of_repos_by_coma() {
  local LIST_OF_REPOS=`git -C $SOURCE_REPO_PATH worktree list | tail -n +2  | awk '{ print $1 }' | sed 's#.*/##' | awk 'ORS=","' | sed 's/\(.*\),/\1 /'`
  echo $LIST_OF_REPOS
}

function query_list_of_repos() {
  local LIST_OF_REPOS=`git -C $SOURCE_REPO_PATH worktree list | tail -n +2 | awk '{ print $1 }' | sed 's#.*/##'`
  echo $LIST_OF_REPOS
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
  echo "  delete-batch  cleans local branches and worktree copy for tickets by status"
  echo "  cleanup  cleans done tickets by status ad removes derived data"
  echo "  copy"
  echo
  echo "view operations"
  echo "  view    display list of tickets (require jira credentials and python)"
  echo "  open    opens a directory with the script"
  echo
  echo "working helper (experimental)"
  echo "  boot-random   creates a random branch where you can play around"
  echo "  patch-close   creates a patch from all changes in top directory of branch and removes that branch"
  echo
  echo "review helper - IN PROGRESS"
  echo "  review"
  echo ""
  echo "check out imporant branches - IN PROGRESS"
  echo "  release pass a train release version"
}

function dashboard() {
  COMMAND=$1
  if [ "$COMMAND" = "boot" ]; then
    $DASHBOARD_DIR/dashboard-ticket-boot.sh ${@:2}
    if [ $? -eq 0 ]; then
      # FIXME: Same logic here and in the dashboard-ticket-boot.sh - needs to be unfied
      cd "$TICKETS_WORKSPACE_DIR/$2"
    fi
  elif [ "$COMMAND" = "boot-random" ]; then
    $DASHBOARD_DIR/dashboard-ticket-boot-random.sh
  elif [ "$COMMAND" = "cleanup" ]; then
    $DASHBOARD_DIR/dashboard-cleanup.sh
  elif [ "$COMMAND" = "patch-close" ]; then
    $DASHBOARD_DIR/dashboard-branch-close.sh
    cd ..
  elif [ "$COMMAND" = "open" ]; then
    if [ "$#" -ne 2 ]; then
        usage
        return 1
    fi
    cd "$TICKETS_WORKSPACE_DIR/$2"
  elif [ "$COMMAND" = "delete" ]; then
    $DASHBOARD_DIR/dashboard-ticket-delete.sh ${@:2}
  elif [ "$COMMAND" = "delete-batch" ]; then
    $DASHBOARD_DIR/dashboard-ticket-delete-batch.sh "${@:2}"
  elif [ "$COMMAND" = "view" ]; then
    python $DASHBOARD_DIR/jira_dashboard.py ${@:2} `query_list_of_repos_by_coma`
  elif [ "$COMMAND" = "copy" ]; then
    $DASHBOARD_DIR/dashboard-copy.sh ${@:2}
  else
    usage
  fi
}
