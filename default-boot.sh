#!/usr/bin/env bash
#
# Default boot strategy.
#
# Adds a git worktree for the given argument, using the argument verbatim as
# both the worktree directory name and (implicitly) the branch name. This is
# the original dashboard boot behaviour.
#
# CONTRACT (shared by every boot strategy):
#   - argument 1 is the branch name
#   - all human-readable output goes to STDERR
#   - the resolved worktree directory name (relative to CHECKOUTS_DIR) is the
#     ONLY thing printed to STDOUT, so the caller can `cd` into it
#

function usage() {
  echo "usage: default-boot.sh <branch>" >&2
}

if [ "$#" -ne 1 ]; then
  usage
  exit 1
fi

BRANCH=$1
BRANCH_DIR_NAME="$BRANCH"

echo "Booting branch $BRANCH..." >&2
git -C "$REPO_CLONE_PATH" worktree add "$CHECKOUTS_DIR/$BRANCH_DIR_NAME" 1>&2
if [ $? -ne 0 ]; then
  exit 1
fi

# Only the resolved directory name goes to STDOUT.
echo "$BRANCH_DIR_NAME"
