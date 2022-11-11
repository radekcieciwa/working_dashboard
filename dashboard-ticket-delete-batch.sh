#!/usr/bin/env bash
#
#	Remove a ticket from worktree
#
#

# TODO: This can be more improved with proving summary of the ticket (title)

function printUsage() {
  echo "Usage: $(basename \$0) [-n] [-f] [-F] [-s STATUS]" >&2
  echo
  echo "-s required, represents jira ticket status"
  echo "-n optional, for dry run"
  echo "-f optional, to skip asking for confirmation" 
  echo "-F optional, to skip if force is required"
}

while getopts 'nfFs:' OPTION; do
  case "$OPTION" in
    n)
      echo "INFO> Using dry run mode"
      IS_DRY_RUN="1"
      ;;
    f)
      echo "INFO> Using skip mode"
      SKIP="1"
      ;;
    F)
      echo "INFO> Using force skip mode"
      SKIP_FORCE="1"
      ;;
    s)
      STATUS="$OPTARG"
      ;;
    ?)
      printUsage
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

if [ -z "$STATUS" ]; then
  printUsage
  exit 1
fi

export SKIP
export SKIP_FORCE
export IS_DRY_RUN

function ask_and_remove() {
  # Need to add </dev/tty, as normal stdin don't work for subprocess function, ref.: https://stackoverflow.com/questions/30018756/bash-reading-users-y-n-answer-does-not-work-read-command-inside-while-loop-read
  # prompt source: https://stackoverflow.com/questions/1885525/how-do-i-prompt-a-user-for-confirmation-in-bash-script

  if [ -z "$SKIP" ]; then
    read -p "Do you want to delete $1 [Yy]? " -n 1 -r -s </dev/tty
    echo ""
    SHOULD_PROCEED=$REPLY
  else
    SHOULD_PROCEED="Y"
  fi

  if [[ $SHOULD_PROCEED =~ ^[Yy]$ ]]; then
    if [ -z "$IS_DRY_RUN" ]; then
      $DASHBOARD_DIR/dashboard-ticket-delete.sh $1
      retVal=$?
    else 
      echo "Would remove $1"
      retVal=0
    fi

    if [ $retVal -ne 0 ]; then
      if [ -z "$SKIP_FORCE" ]; then
        read -p "ERROR! Shall we try FORCE delete $1 [Yy]? " -n 1 -r -s </dev/tty
        echo ""
        SHOULD_PROCEED_FORCE=$REPLY
      else 
        SHOULD_PROCEED_FORCE="Y"
      fi 

      if [[ $SHOULD_PROCEED_FORCE =~ ^[Yy]$ ]]; then
        if [ -z "$IS_DRY_RUN" ]; then
          $DASHBOARD_DIR/dashboard-ticket-delete.sh -f $1
          exit $?
        else 
          echo "Would remove with force $1"
          exit 0
        fi
      fi
    fi
    exit $retVal
  else
    echo
    echo "Skipping $1"
  fi
}

echo "INFO> Working with status: $STATUS"
source $DASHBOARD_DIR/dashboard.sh
LIST_OF_REPOS=`query_list_of_repos_by_coma`
TICKET_LIST=`python $DASHBOARD_DIR/jira_dashboard_tickets_by_status.py "$LIST_OF_REPOS" \""${STATUS}"\"`
export -f ask_and_remove
echo $TICKET_LIST | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | xargs -L1 bash -c 'ask_and_remove $0'
