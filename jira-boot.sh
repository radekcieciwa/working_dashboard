#!/usr/bin/env bash
#
# Jira boot strategy.
#
# Resolves a descriptive worktree name from the Jira issue summary and adds a
# git worktree for it. Given the issue key (e.g. IAT-1234) it:
#
#   1. fetches the issue summary from Jira
#   2. normalizes it into a slug, swapping all whitespace for "-"
#   3. uses  <ISSUE_KEY>-<slug>  (e.g. IAT-1234-summary-is-long) as both the
#      worktree directory and branch name
#
# CONTRACT (shared by every boot strategy):
#   - argument 1 is the ticket / identifier
#   - all human-readable output goes to STDERR
#   - the resolved worktree directory name (relative to CHECKOUTS_DIR) is the
#     ONLY thing printed to STDOUT, so the caller can `cd` into it
#

function usage() {
  echo "usage: jira-boot.sh <jira ticket>" >&2
}

if [ "$#" -ne 1 ]; then
  usage
  exit 1
fi

TICKET_NUMBER=$1

# Locate the dashboard installation so we can reuse the venv + helpers.
DASHBOARD_DIR="${DASHBOARD_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

if [ ! -d "$DASHBOARD_DIR/venv" ]; then
  echo "Error: Virtual environment not found at $DASHBOARD_DIR/venv" >&2
  echo "Please run the installation script first: cd $DASHBOARD_DIR && ./install.sh" >&2
  exit 1
fi

# Fetch the Jira summary for the ticket.
source "$DASHBOARD_DIR/venv/bin/activate"
SUMMARY=$(python3 "$DASHBOARD_DIR/jira_summary.py" "$TICKET_NUMBER")
deactivate

if [ -z "$SUMMARY" ]; then
  echo "Error: Could not fetch summary for $TICKET_NUMBER" >&2
  exit 1
fi

# Normalize the summary into a slug:
#   - swap every run of whitespace for a single "-"
#   - drop characters that are unsafe in git refs / directory names
#   - collapse repeated "-" and trim leading/trailing "-"
SLUG=$(echo "$SUMMARY" \
  | tr -s '[:space:]' '-' \
  | sed -E 's/[^a-zA-Z0-9._-]//g; s/-+/-/g; s/^-+//; s/-+$//')

if [ -z "$SLUG" ]; then
  echo "Error: Summary produced an empty name for $TICKET_NUMBER" >&2
  exit 1
fi

TICKET_DIR_NAME="$TICKET_NUMBER-$SLUG"

echo "Booting $TICKET_NUMBER (worktree: $TICKET_DIR_NAME)..." >&2
git -C "$REPO_CLONE_PATH" worktree add "$CHECKOUTS_DIR/$TICKET_DIR_NAME" 1>&2
if [ $? -ne 0 ]; then
  exit 1
fi

# Only the resolved directory name goes to STDOUT.
echo "$TICKET_DIR_NAME"
