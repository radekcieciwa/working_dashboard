#!/bin/sh
#
# Author Radoslaw Cieciwa <radekcieciwa@gmail.com>
#
# Dashboard for working copies
#

USER=$1
PASSWORD=$2

check_working_copy() {
	cd $1
	CURRENT_TICKET=`git symbolic-ref HEAD | sed -e 's|^refs/heads/||' | sed -e 's|_.*||'`
	CURRENT_BRANCH=`git branch | grep \* | sed 's/* //g'`
	if [ "$CURRENT_BRANCH" = "dev" ]; then
		OUTPUT="$1|$CURRENT_BRANCH"
	else
		STATUS=`php ../working_dashboard/jira-tool.php ticket=$CURRENT_TICKET u=$USER p=$PASSWORD`
		LINK="https://jira.badoojira.com/browse/$CURRENT_TICKET"
		OUTPUT="$1|[$CURRENT_TICKET]|$STATUS|$LINK"
	fi

	echo $OUTPUT
	# printf $OUTPUT | column -t -s'|'
	# echo $OUTPUT | column -t -s'|'
	cd ..
}

check_working_copy alpha
check_working_copy beta
check_working_copy delta
check_working_copy gamma
check_working_copy Source
