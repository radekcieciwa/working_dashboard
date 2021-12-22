#!/bin/sh
#
# Author Radoslaw Cieciwa <radekcieciwa@gmail.com>
#
# Cleanup done tickets and all dervied data.
#

STATUS="In Release branch"
echo "Removing $STATUS"
$DASHBOARD_DIR/dashboard-ticket-delete-batch.sh "$STATUS"

STATUS="On Live"
echo "Removing $STATUS"
$DASHBOARD_DIR/dashboard-ticket-delete-batch.sh "$STATUS"

STATUS="Closed"
echo "Removing $STATUS"
$DASHBOARD_DIR/dashboard-ticket-delete-batch.sh "$STATUS"

STATUS="In Master"
echo "Removing $STATUS"
$DASHBOARD_DIR/dashboard-ticket-delete-batch.sh "$STATUS"

echo "Cleaning derived data"
DD="/Users/`whoami`/Library/Developer/Xcode/DerivedData"
rm -frv $DD | pv -l -s $( du -a $DD | wc -l ) > /dev/null
