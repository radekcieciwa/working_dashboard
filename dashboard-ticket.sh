#!/bin/sh
#
# Author Radoslaw Cieciwa <radekcieciwa@gmail.com>
#
# Entry point tool for dashboard.
#

function usage() {
  echo "Usage: $0 <[boot; delete]> <JIRA_TICKET_REF>"
}

DIR=$(dirname $0)

if [ "$1" = "boot" ]; then
  $DIR/dashboard-ticket-boot.sh ${@:2}
elif [ "$1" = "delete" ]; then
  $DIR/dashboard-ticket-delete.sh ${@:2}
else
  usage
fi
