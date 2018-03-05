#!/bin/sh
#
# Author Radoslaw Cieciwa <radekcieciwa@gmail.com>
#
# Supplementary tool for dashboard.
#

USER=$1
PASSWORD=$2

jsonval() {
  temp=`echo $1 | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $2`
  echo ${temp##*|}
}

update_if_dev() {
	cd $1
	CURRENT_BRANCH=`git branch | grep \* | sed 's/* //g'`
	if [ "$CURRENT_BRANCH" = "dev" ]; then
		git pull
    git submodule update
    echo "$1: [dev] pulled"
	else
		CURRENT_TICKET=`git symbolic-ref HEAD | sed -e 's|^refs/heads/||' | sed -e 's|_.*||'`
		STATUS_JSON=`php ../working_dashboard/jira-tool.php ticket=$CURRENT_TICKET u=$USER p=$PASSWORD`
		LINK="https://jira.badoojira.com/browse/$CURRENT_TICKET"
		STATUS=`jsonval "$STATUS_JSON" status`

		if [ "$STATUS" = "In Dev" ]; then
			../working_dashboard/clear_git.sh
		else
	    echo "$1: [$CURRENT_TICKET] skipping"
		fi
	fi

	cd ..
}

update_if_dev alpha
update_if_dev beta
update_if_dev delta
update_if_dev gamma
