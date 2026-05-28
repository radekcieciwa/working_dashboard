#!/bin/sh
#
# Author Radoslaw Cieciwa <radekcieciwa@gmail.com>
#
# Entry point tool for dashboard.
#

# Load configuration from central config manager if available
function load_config() {
  DASHBOARD_DIR="${DASHBOARD_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

  if [ -d "$DASHBOARD_DIR/venv" ]; then
    source "$DASHBOARD_DIR/venv/bin/activate" 2>/dev/null
    local VARS=$(python3 "$DASHBOARD_DIR/jira_config.py" export 2>/dev/null)
    deactivate 2>/dev/null

    if [ ! -z "$VARS" ]; then
      eval "$VARS"
    fi
  fi
}

# Load config on startup
if [ -z "$REPO_CLONE_PATH" ]; then
  load_config
fi

function query_list_of_repos_by_coma() {
  local LIST_OF_REPOS=`git -C $REPO_CLONE_PATH worktree list | tail -n +2  | awk '{ print $1 }' | sed 's#.*/##' | awk 'ORS=","' | sed 's/\(.*\),/\1 /'`
  echo $LIST_OF_REPOS
}

function query_list_of_repos() {
  local LIST_OF_REPOS=`git -C $REPO_CLONE_PATH worktree list | tail -n +2 | awk '{ print $1 }' | sed 's#.*/##'`
  echo $LIST_OF_REPOS
}

function usage() {
  echo "usage dashboard <command> [<args>]"
  echo
  echo "Most common usages"
  echo "you can run this command from any directory"
  echo
  echo "configuration"
  echo "  config current                        show current repository setup"
  echo "  config list                           list all configured repositories"
  echo "  config init <name> <clone> <tickets>  initialize configuration for a repository"
  echo "  config switch <name>                  switch the current repository"
  echo
  echo "authentication"
  echo "  token <TOKEN>                         store authentication token in keychain"
  echo "  token-verify                          verify token is valid and connection works"
  echo
  echo "jira ticket lifecycle"
  echo "  boot <TICKET>                         create worktree and run post-boot script"
  echo "  delete <TICKET>                       clean local branches and worktree"
  echo "  delete-batch [-s STATUS]              clean tickets by status (interactive if -s not provided)"
  echo
  echo "view operations"
  echo "  view                                  display list of tickets"
  echo "  open [TICKET]                         open ticket directory (interactive if no TICKET)"
  echo "  title                                 set terminal title with ticket summary"
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
  elif [ "$COMMAND" = "token-verify" ]; then
    if ! check_venv; then
      return 1
    fi
    source $DASHBOARD_DIR/venv/bin/activate
    python3 $DASHBOARD_DIR/jira_verify_token.py
    EXIT_CODE=$?
    deactivate
    return $EXIT_CODE
  elif [ "$COMMAND" = "config" ]; then
    if [ "$#" -lt 2 ]; then
      usage
      return 1
    fi
    if ! check_venv; then
      return 1
    fi
    source $DASHBOARD_DIR/venv/bin/activate
    python3 $DASHBOARD_DIR/jira_config.py ${@:2}
    EXIT_CODE=$?
    deactivate

    if [ "$EXIT_CODE" -eq 0 ] && [ "$2" = "switch" ]; then
      load_config
    fi

    return $EXIT_CODE
  elif [ "$COMMAND" = "boot" ]; then
    $DASHBOARD_DIR/dashboard-ticket-boot.sh ${@:2}
    if [ $? -eq 0 ]; then
      # FIXME: Same logic here and in the dashboard-ticket-boot.sh - needs to be unfied
      cd "$CHECKOUTS_DIR/$2"
    fi
  elif [ "$COMMAND" = "title" ]; then
    $DASHBOARD_DIR/dashboard-terminal-title.sh
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
        cd "$CHECKOUTS_DIR/$SELECTED_TICKET"
      else
        return 1
      fi
    elif [ "$#" -eq 2 ]; then
      cd "$CHECKOUTS_DIR/$2"
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
    EXIT_CODE=$?

    deactivate

    if [ $EXIT_CODE -ne 0 ]; then
      echo "Error: Failed to fetch tickets from Jira" >&2
      echo "Run with -v flag for verbose output: dashboard view -v" >&2
      return 1
    fi
  else
    usage
  fi
}
