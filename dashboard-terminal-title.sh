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

# Check if venv exists
if [ ! -d "$DASHBOARD_DIR/venv" ]; then
  echo "Error: Virtual environment not found"
  echo "Please run the installation script first:"
  echo "  cd $DASHBOARD_DIR && ./install.sh"
  exit 1
fi

TICKET=`getlastsegment`
source $DASHBOARD_DIR/venv/bin/activate
TITLE=`python3 $DASHBOARD_DIR/jira_summary.py $TICKET`
deactivate
set_tabtitle "$TITLE"
echo $TITLE