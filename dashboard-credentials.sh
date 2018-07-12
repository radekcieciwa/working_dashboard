#!/bin/sh
#
# Author Radoslaw Cieciwa <radekcieciwa@gmail.com>
#
# Dashboard for working copies
#

function usage() {
  echo "Usage: $0 <[add; remove; get]> <USER>"
}

read_password() {
  # -a account [required]
  # -s service [required]
  # -w specify password by user
  security add-generic-password -a $USER -s dashboard -w
}

remove_password() {
  security delete-generic-password -a $USER -s dashboard
}

get_password() {
  # -a account [required]
  # -s service [required]
  # -w dispay only password (-g to display additionals)
  security find-generic-password -a $USER -s dashboard -w
}

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
    usage
else
  ACTION=$1
  PASSWORD=$2
  if [ "$ACTION" = "add" ]; then
    read_password
  elif [ "$ACTION" = "remove" ]; then
    remove_password
  elif [ "$ACTION" = "get" ]; then
    get_password
  else
    echo "Illegal command argument"
    usage
  fi
fi
