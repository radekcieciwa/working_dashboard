#!/bin/sh
#
# Author Radoslaw Cieciwa <radekcieciwa@gmail.com>
#
# Entry point tool for dashboard.
#

function usage() {
  echo "Usage: $0 <[ticket; view]> <ARGS>"
}

DIR=$(dirname $0)

if [ "$1" = "ticket" ]; then
  $DIR/dashboard-ticket.sh ${@:2}
elif [ "$1" = "view" ]; then
  $DIR/dashboard-view.sh ${@:2}
else
  usage
fi
