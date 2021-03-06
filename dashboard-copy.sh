#!/usr/bin/env bash
#
#	Initilize a ticket with git worktree.
# 	We don't assume any issue as we don't have any submodules.
#

function usage() {
  echo "usage dashboard copy <command>"
  echo
  echo "Use this command for debug purposes, not real development."
  echo
  echo "  add     add a tmp working copy, reset current if already exists"
  echo "  clear   remove tmp_working_copy"
  exit 1
}

COPY_NAME="tmp_working_copy"
export REVIEW_DIRECTORY_NAME="REVIEW"

function remove_workree() {
  if [ $# -ne 2 ]; then
    echo "Wrong usage try: ${FUNCNAME[0]} <DIRECTORY_ROOT> <WORKTREE>"
    return 1
  fi

  git -C "$1/$2" reset --hard
  git -C "$1/$2" clean -fdx

  $DASHBOARD_DIR/dashboard-ticket-delete.sh $2
  if [ -d "$1/$2" ]; then
    rm -r $2
  fi
}

export -f remove_workree

function qcheckout() {
	if [ $# -ne 1 ]; then
		echo "Wrong usage try: ${FUNCNAME[0]} <START_OF_BRANCH_NAME>"
		return 1
	fi

	START_OF_BRANCH_NAME=$1
	echo "Looking for: $START_OF_BRANCH_NAME ... in $SOURCE_REPO_PATH"

	REMOTE=`git -C $SOURCE_REPO_PATH branch -a | grep $1`
	FOUND_LINES=`git -C $SOURCE_REPO_PATH branch -a | grep $1 | wc -l | sed -e 's/^[[:space:]]*//'`

	if [ $FOUND_LINES -ne 1 ]; then
		echo "ERROR: Found $FOUND_LINES branches with this signature"
		return 1
	fi

	LOCAL="$START_OF_BRANCH_NAME${REMOTE#*$START_OF_BRANCH_NAME}"
	echo "Executing: git checkout -b $LOCAL $REMOTE"
  git -C $SOURCE_REPO_PATH worktree add --checkout "$TICKETS_WORKSPACE_DIR/$REVIEW_DIRECTORY_NAME/$1" $REMOTE
}

COPY="$TICKETS_WORKSPACE_DIR/$COPY_NAME"
if [ "$1" = "add" ]; then
  if [ -d $COPY ]; then
    read -p "Directory already exists. Clear it? [Yy]" -n 1 -r -s </dev/tty
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo
      git -C $COPY reset --hard
      git -C $COPY clean -fdx
      exit 0
    else
      exit 1
    fi
  fi
  echo "Adding tmp_working_copy..."
  git -C $SOURCE_REPO_PATH worktree add $COPY
  echo "Done"
elif [ "$1" = "clear" ]; then
  if [ ! -d $COPY ]; then
    echo "Warning: Not found any existing copy!"
    exit 0
  fi

  remove_workree $TICKETS_WORKSPACE_DIR $COPY_NAME
else
  echo "$1"
  usage
fi
