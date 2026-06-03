#!/usr/bin/env bash
#
#	Initialize a ticket with git worktree.
#
# This is a dispatcher: it selects the configured boot strategy
# ($BOOT_SCRIPT, defaulting to default-boot.sh), runs it to create the worktree,
# then runs the optional post-boot script.
#
# The selected boot script is responsible for creating the worktree and must
# print the resolved worktree directory name (relative to CHECKOUTS_DIR) as the
# only thing on STDOUT. We forward that name on STDOUT so the caller can `cd`.
#

function usage() {
  echo "usage dashboard boot <jira ticket>" >&2
}

if [ "$#" -ne 1 ]; then
    usage
    exit 1
fi

TICKET_NUMBER=$1

DASHBOARD_DIR="${DASHBOARD_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

# Resolve the configured boot strategy. A bare name is looked up inside the
# dashboard installation; an absolute path is used as-is.
BOOT_SCRIPT="${BOOT_SCRIPT:-default-boot.sh}"
case "$BOOT_SCRIPT" in
  /*) BOOT_SCRIPT_PATH="$BOOT_SCRIPT" ;;
  *)  BOOT_SCRIPT_PATH="$DASHBOARD_DIR/$BOOT_SCRIPT" ;;
esac

if [ ! -f "$BOOT_SCRIPT_PATH" ]; then
  echo "Error: boot script not found: $BOOT_SCRIPT_PATH" >&2
  exit 1
fi

# Run the boot strategy. It creates the worktree and echoes the resolved
# directory name on STDOUT.
TICKET_DIR_NAME=$(bash "$BOOT_SCRIPT_PATH" "$TICKET_NUMBER")
if [ $? -ne 0 ] || [ -z "$TICKET_DIR_NAME" ]; then
  exit 1
fi

# Run post-boot script if configured. Its output is sent to STDERR so it does
# not pollute the directory name we forward on STDOUT.
if [ ! -z "$POST_BOOT_SCRIPT" ] && [ -f "$POST_BOOT_SCRIPT" ]; then
  cd "$CHECKOUTS_DIR/$TICKET_DIR_NAME"
  bash "$POST_BOOT_SCRIPT" "$TICKET_NUMBER" 1>&2
  if [ $? -ne 0 ]; then
    exit 1
  fi
fi

echo "Successfully created: $TICKET_NUMBER" >&2

# Forward the resolved directory name to the caller (for `cd`).
echo "$TICKET_DIR_NAME"
