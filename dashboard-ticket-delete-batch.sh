#!/usr/bin/env bash
#
#	Remove a ticket from worktree
#
#

# NOT USEFULL!

function usage() {
  echo "Usage: $0 <Statuses to remove>"
}

if [ "$#" -ne 1 ]; then
    usage
    exit 1
fi

function ask_and_remove() {
  # Need to add </dev/tty, as normal stdin don't work for subprocess function, ref.: https://stackoverflow.com/questions/30018756/bash-reading-users-y-n-answer-does-not-work-read-command-inside-while-loop-read
  # prompt source: https://stackoverflow.com/questions/1885525/how-do-i-prompt-a-user-for-confirmation-in-bash-script
  read -p "Do you want to delete $1 [Yy]? " -n 1 -r -s </dev/tty
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo
    $DASHBOARD_DIR/dashboard-ticket-delete.sh $1
    retVal=$?
    if [ $retVal -ne 0 ]; then
      read -p "ERROR! Shall we try FORCE delete $1 [Yy]? " -n 1 -r -s </dev/tty
      if [[ $REPLY =~ ^[Yy]$ ]]
      then
        $DASHBOARD_DIR/dashboard-ticket-delete.sh -f $1
        exit $?
      fi
    fi
    exit $retVal
  else
    echo
    echo "Skipping $1"
  fi
}

echo "Start"
source $DASHBOARD_DIR/dashboard.sh
LIST_OF_REPOS=`query_list_of_repos_by_coma`
TICKET_LIST=`python $DASHBOARD_DIR/jira_dashboard_tickets_by_status.py "$LIST_OF_REPOS" \""${@:1}"\"`

export -f ask_and_remove
echo $TICKET_LIST | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | xargs -L1 bash -c 'ask_and_remove $0'
