#!/usr/bin/env bash
#
#	Initilize a ticket with git worktree.
# 	We don't assume any issue as we don't have any submodules.
#


function usage() {
  echo "Usage: $0 [add; clear; review]"
  exit 1
}

function usage_review() {
  echo "Usage: $0 review <ticket>"
  exit 1
}

COPY_NAME="tmp_working_copy"
export REVIEW_DIRECTORY_NAME="REVIEW"
export MAIN_WORKSPACE_ROOT=/Users/radoslawcieciwa/Development/iOS/Badoo
MAIN_REPO_PATH=/Users/radoslawcieciwa/Development/iOS/Badoo/_source
export DIR=$(dirname $0)

function remove_wortree() {
  if [ $# -ne 2 ]; then
    echo "Wrong usage try: ${FUNCNAME[0]} <DIRECTORY_ROOT> <WORKTREE>"
    return 1
  fi

  git -C "$1/$2" reset --hard
  git -C "$1/$2" clean -fdx

  $DIR/dashboard-ticket-delete.sh $2
  if [ -d "$1/$2" ]; then
    rm -r $2
  fi
}

export -f remove_wortree

function qcheckout() {
	if [ $# -ne 1 ]; then
		echo "Wrong usage try: ${FUNCNAME[0]} <START_OF_BRANCH_NAME>"
		return 1
	fi

	START_OF_BRANCH_NAME=$1
	echo "Looking for: $START_OF_BRANCH_NAME ... in $MAIN_REPO_PATH"

	REMOTE=`git -C $MAIN_REPO_PATH branch -a | grep $1`
	FOUND_LINES=`git -C $MAIN_REPO_PATH branch -a | grep $1 | wc -l | sed -e 's/^[[:space:]]*//'`

	if [ $FOUND_LINES -ne 1 ]; then
		echo "ERROR: Found $FOUND_LINES branches with this signature"
		return 1
	fi

	LOCAL="$START_OF_BRANCH_NAME${REMOTE#*$START_OF_BRANCH_NAME}"
	echo "Executing: git checkout -b $LOCAL $REMOTE"
  git -C $MAIN_REPO_PATH worktree add --checkout "$MAIN_WORKSPACE_ROOT/$REVIEW_DIRECTORY_NAME/$1" $REMOTE
}

if [ "$1" = "add" ]; then
  if [ -d "$MAIN_WORKSPACE_ROOT/$COPY_NAME" ]; then
    echo "Directory already exists. Clear it before adding new one."
    exit 1
  fi
  echo "Start"
  git -C $MAIN_REPO_PATH worktree add "$MAIN_WORKSPACE_ROOT/$COPY_NAME"
  echo "Done!"
elif [ "$1" = "clear" ]; then
  if [ ! -d "$MAIN_WORKSPACE_ROOT/$COPY_NAME" ]; then
    echo "Copy already cleared."
    exit 0
  fi

  remove_wortree $MAIN_WORKSPACE_ROOT $COPY_NAME
elif [ "$1" = "review" ]; then
  if [ "$#" -eq 2 ]; then
    qcheckout $2
  else
    echo "Clearing all reviews ..."
    ls -1 $MAIN_WORKSPACE_ROOT/$REVIEW_DIRECTORY_NAME | xargs -L1 bash -c 'remove_wortree "$MAIN_WORKSPACE_ROOT/$REVIEW_DIRECTORY_NAME" $0'
  fi
else
  echo "$1"
  usage
fi
