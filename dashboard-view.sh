#!/bin/sh
#
# Author Radoslaw Cieciwa <radekcieciwa@gmail.com>
#
# Dashboard for working copies
#

# Export to subprocesses
export USER=$1
PASSWORD_ITEM=`./working_dashboard/dashboard-credentials.sh get $USER`
passwordGetRetVal=$?
if [ $passwordGetRetVal -ne 0 ]; then
    echo "Error getting password."
    echo "Try to add new one and re-run."
    ./working_dashboard/dashboard-credentials.sh add $USER
    exit $retVal
fi
export PASSWORD=$PASSWORD_ITEM

MAIN_REPO_PATH=/Users/radoslawcieciwa/Development/iOS/Badoo/_source

jsonval() {
  temp=`echo $1 | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $2`
  echo ${temp##*|}
}

check_working_copy() {
	cd $1
  USER=$2
  PASSWORD=$3
	CURRENT_TICKET=`git symbolic-ref HEAD | sed -e 's|^refs/heads/||' | sed -e 's|_.*||'`
	CURRENT_BRANCH=`git branch | grep \* | sed 's/* //g'`
	STATUS_JSON=`php ../working_dashboard/jira-tool.php ticket=$CURRENT_TICKET u=$USER p=$PASSWORD`
	LINK="https://jira.badoojira.com/browse/$CURRENT_TICKET"
	STATUS=`jsonval "$STATUS_JSON" status | cut -c1-12`
	TITLE=`jsonval "$STATUS_JSON" title | cut -c1-32`
	QA_EST=`jsonval "$STATUS_JSON" qa_est`
  ASSIGNEE=`jsonval "$STATUS_JSON" assignee | cut -c1-12`

  OUTPUT="$CURRENT_TICKET|$STATUS|$ASSIGNEE|$TITLE|$QA_EST|$LINK"

	echo $OUTPUT
	cd ..
}

# Exports to subprocesses, as each of those will be called by bash -c
export -f jsonval
export -f check_working_copy

echo "Ticket|Status|Assignee|Title|QA est.|URL"
echo "-      -|-      -|-      -|-      -|-      -|-      -"
git -C $MAIN_REPO_PATH worktree list | awk '{ print $1 }' | grep -v $MAIN_REPO_PATH | xargs -L1 bash -c 'check_working_copy $0 $USER $PASSWORD'
echo "-      -|-      -|-      -|-      -|-      -|-      -"
