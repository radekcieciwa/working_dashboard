#!/usr/bin/env bash
#
# Shared helpers for boot strategies.
#
# Sourced by the boot scripts (default-boot.sh, jira-boot.sh). Relies on
# $REPO_CLONE_PATH being set by the caller.
#

# add_worktree <path> [<branch>]
#
# Adds a git worktree at <path>. The branch name defaults to the basename of
# <path>. Resolution order is chosen so an existing branch is REUSED rather than
# a divergent new local branch being forked off HEAD:
#
#   1. local branch <branch> exists   -> check it out
#   2. remote branch <branch> exists  -> check out a local tracking branch
#   3. otherwise                      -> create a new branch off HEAD
#
# We `fetch` (not `pull`) first: pull would only update the main clone's
# currently checked-out branch, whereas a fetch refreshes the remote-tracking
# refs we need to detect and base the worktree on, without touching any
# checkout. The fetch is best-effort - if it fails (offline, etc.) we fall back
# to whatever refs we already have.
function add_worktree() {
  local path="$1"
  local branch="${2:-$(basename "$path")}"

  # Prefer 'origin'; otherwise fall back to the first configured remote.
  local remote
  remote=$(git -C "$REPO_CLONE_PATH" remote | grep -x origin \
    || git -C "$REPO_CLONE_PATH" remote | head -n1)

  if [ -n "$remote" ]; then
    git -C "$REPO_CLONE_PATH" fetch --quiet "$remote" 1>&2 \
      || echo "Warning: fetch from '$remote' failed; using local refs." >&2
  fi

  if git -C "$REPO_CLONE_PATH" show-ref --verify --quiet "refs/heads/$branch"; then
    echo "Branch '$branch' exists locally; checking it out." >&2
    git -C "$REPO_CLONE_PATH" worktree add "$path" "$branch" 1>&2
  elif [ -n "$remote" ] \
    && git -C "$REPO_CLONE_PATH" show-ref --verify --quiet "refs/remotes/$remote/$branch"; then
    echo "Branch '$branch' exists on '$remote'; checking out a tracking branch." >&2
    git -C "$REPO_CLONE_PATH" worktree add --track -b "$branch" "$path" "$remote/$branch" 1>&2
  else
    echo "Branch '$branch' is new; creating it off HEAD." >&2
    git -C "$REPO_CLONE_PATH" worktree add -b "$branch" "$path" 1>&2
  fi
}
