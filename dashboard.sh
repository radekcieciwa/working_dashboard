#!/bin/sh
#
# Author Radoslaw Cieciwa <radekcieciwa@gmail.com>
#
# Dashboard for working copies
#

USER=$1
PASSWORD=$2

jsonval() {
  temp=`echo $1 | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $2`
  echo ${temp##*|}
}

check_working_copy() {
	cd $1
	CURRENT_TICKET=`git symbolic-ref HEAD | sed -e 's|^refs/heads/||' | sed -e 's|_.*||'`
	CURRENT_BRANCH=`git branch | grep \* | sed 's/* //g'`
	if [ "$CURRENT_BRANCH" = "dev" ]; then
		OUTPUT="$1|$CURRENT_BRANCH"
	else
		STATUS_JSON=`php ../working_dashboard/jira-tool.php ticket=$CURRENT_TICKET u=$USER p=$PASSWORD`
		LINK="https://jira.badoojira.com/browse/$CURRENT_TICKET"
		STATUS=`jsonval "$STATUS_JSON" status`
		TITLE=`jsonval "$STATUS_JSON" title`
		QA_EST=`jsonval "$STATUS_JSON" qa_est`
    ASSIGNEE=`jsonval "$STATUS_JSON" assignee`
		OUTPUT="$1|[$CURRENT_TICKET]|$STATUS|$ASSIGNEE|$TITLE|$QA_EST|$LINK"
	fi

	echo $OUTPUT
	cd ..
}

check_working_copy alpha
check_working_copy beta
check_working_copy delta
check_working_copy gamma
