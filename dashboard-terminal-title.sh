#!/usr/bin/env bash
#
#	Remove a ticket from worktree
#
#

function usage() {
  echo "usage dashboard terminal-title <jira ticket>"
  echo
  echo "  -f to force delete"
}

# Change available text
set_tabtitle() {
  echo -n -e "\033]0;$1\007"
}

# Change full text
set_absolute_tabtitle() {
  printf '\e]1;%s\a' "$1"
}

getlastsegment() {
  basename "$(pwd)"
}

TICKET=`getlastsegment`
TITLE=`python3 $DASHBOARD_DIR/jira_summary.py $TICKET`
set_tabtitle "$TITLE"
echo $TITLE