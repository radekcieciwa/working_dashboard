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
  echo "authentication"
  echo "  token <TOKEN>  stores authentication token in keychain"
  echo
  echo "controls the jira ticket (creates a new branch) lifecycle"
  echo "  boot    runs aida process and enters the folder"
  echo "  delete  cleans local branches and worktree copy"
  echo "  delete-batch [-s STATUS]  cleans local branches and worktree copy for tickets by status"
  echo "              interactive status selection if -s not provided"
  echo "  cleanup  cleans done tickets by status ad removes derived data"
  echo "  copy"
  echo
  echo "view operations"
  echo "  view    display list of tickets (require jira credentials and python)"
  echo "  open [TICKET]  opens a directory with the script or interactive selection if no ticket provided"
  echo "  title   get's ticket container and try to fetch summary to set to title tab"
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

function check_venv() {
  if [ ! -d "$DASHBOARD_DIR/venv" ]; then
    echo "Error: Virtual environment not found"
    echo "Please run the installation script first:"
    echo "  cd $DASHBOARD_DIR && ./install.sh"
    return 1
  fi
  return 0
}

function dashboard() {
  COMMAND=$1
  if [ "$COMMAND" = "token" ]; then
    if [ "$#" -ne 2 ]; then
        echo "Error: Token argument is required"
        echo "Usage: dashboard token <TOKEN>"
        return 1
    fi
    if ! check_venv; then
      return 1
    fi
    source $DASHBOARD_DIR/venv/bin/activate
    python3 $DASHBOARD_DIR/jira_store_token.py "$2"
    deactivate
  elif [ "$COMMAND" = "boot" ]; then
    $DASHBOARD_DIR/dashboard-ticket-boot.sh ${@:2}
    if [ $? -eq 0 ]; then
      # FIXME: Same logic here and in the dashboard-ticket-boot.sh - needs to be unfied
      cd "$TICKETS_WORKSPACE_DIR/$2"
    fi
  elif [ "$COMMAND" = "boot-random" ]; then
    $DASHBOARD_DIR/dashboard-ticket-boot-random.sh
  elif [ "$COMMAND" = "cleanup" ]; then
    $DASHBOARD_DIR/dashboard-cleanup.sh
  elif [ "$COMMAND" = "title" ]; then
    $DASHBOARD_DIR/dashboard-terminal-title.sh
  elif [ "$COMMAND" = "patch-close" ]; then
    $DASHBOARD_DIR/dashboard-branch-close.sh
    cd ..
  elif [ "$COMMAND" = "open" ]; then
    if [ "$#" -eq 1 ]; then
      # No ticket provided, use interactive selection
      if ! check_venv; then
        return 1
      fi
      source $DASHBOARD_DIR/venv/bin/activate

      SELECTED_TICKET=$(python3 $DASHBOARD_DIR/jira_open_interactive.py `query_list_of_repos_by_coma`)
      EXIT_CODE=$?

      deactivate

      if [ $EXIT_CODE -eq 0 ] && [ -n "$SELECTED_TICKET" ]; then
        cd "$TICKETS_WORKSPACE_DIR/$SELECTED_TICKET"
      else
        return 1
      fi
    elif [ "$#" -eq 2 ]; then
      cd "$TICKETS_WORKSPACE_DIR/$2"
    else
      usage
      return 1
    fi
  elif [ "$COMMAND" = "delete" ]; then
    $DASHBOARD_DIR/dashboard-ticket-delete.sh ${@:2}
  elif [ "$COMMAND" = "delete-batch" ]; then
    $DASHBOARD_DIR/dashboard-ticket-delete-batch.sh "${@:2}"
  elif [ "$COMMAND" = "view" ]; then
    if ! check_venv; then
      return 1
    fi
    source $DASHBOARD_DIR/venv/bin/activate

    python3 $DASHBOARD_DIR/jira_dashboard.py ${@:2} `query_list_of_repos_by_coma`

    deactivate
  elif [ "$COMMAND" = "copy" ]; then
    $DASHBOARD_DIR/dashboard-copy.sh ${@:2}
  else
    usage
  fi
}
