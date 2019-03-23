#!/usr/bin/env bash
#
#	Remove a ticket from worktree
#
#

function usage() {
  echo "usage dashboard delete <jira ticket>"
  echo
  echo "  -f to force delete"
}

function delete_worktree_checkout() {
  if [ "$FORCE_CLEANUP" = "1" ]; then
    rm -rf $1
    git -C $SOURCE_REPO_PATH worktree prune
    git -C $SOURCE_REPO_PATH worktree remove --force $1
  else
    git -C $SOURCE_REPO_PATH worktree remove $1
  fi
}

function delete_branch() {
  if [ "$FORCE_CLEANUP" = "1" ]; then
    git -C $SOURCE_REPO_PATH branch --force -D $1
  else
    git -C $SOURCE_REPO_PATH branch -d $1
  fi
}

TICKET=$1
FORCE_CLEANUP=0

while getopts f OPTION
do
    case ${OPTION} in
        f)  FORCE_CLEANUP=1
            ;;
    esac
done

TICKET=${@:$OPTIND:1}

if [ -z "$TICKET" ]; then
    usage
    exit 1
fi

echo "Deleting $TICKET ..."

if [ "$FORCE_CLEANUP" = "1" ]; then
  echo "Warning - using force flag"
fi

delete_worktree_checkout $TICKET

git -C $SOURCE_REPO_PATH branch | grep $TICKET | while read -r branch ; do
  delete_branch $branch
done

if [ $? -ne 0 ]; then
  echo "$TICKET Finished with error $?"
  exit 1
else
  echo "$TICKET Done"
fi
