#!/usr/bin/env bash
#
# Jira boot strategy.
#
# Resolves a worktree name from the argument and adds a git worktree for it.
# The argument is handled in one of three variants:
#
#   1. bare Jira key (e.g. IAT-1234)
#        fetch the issue summary from Jira, normalize it into a slug and use
#        <ISSUE_KEY>-<slug> (e.g. IAT-1234-summary-is-long) as the worktree
#        directory and branch name.
#   2. Jira key already carrying a slug (e.g. IAT-1234-summary-is-long)
#        boot it verbatim - the descriptive name is already there, so there is
#        nothing to fetch.
#   3. unknown format (e.g. a plain branch name like my-feature)
#        boot it verbatim.
#
# CONTRACT (shared by every boot strategy):
#   - argument 1 is the ticket / identifier
#   - all human-readable output goes to STDERR
#   - the resolved worktree directory name (relative to CHECKOUTS_DIR) is the
#     ONLY thing printed to STDOUT, so the caller can `cd` into it
#

function usage() {
  echo "usage: jira-boot.sh <jira ticket | branch>" >&2
}

if [ "$#" -ne 1 ]; then
  usage
  exit 1
fi

ARGUMENT=$1

# A bare Jira key is a project key (uppercase letter followed by uppercase
# letters/digits) joined by a dash to the issue number, with NOTHING after it.
# Anchoring both ends is what distinguishes IAT-1234 (variant 1) from
# IAT-1234-summary-is-long (variant 2).
BARE_KEY_RE='^[A-Z][A-Z0-9]*-[0-9]+$'

# Locate the dashboard installation so we can reuse the venv + helpers.
DASHBOARD_DIR="${DASHBOARD_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

if [[ "$ARGUMENT" =~ $BARE_KEY_RE ]]; then
  # Variant 1: bare key -> fetch summary and build a descriptive slug.
  TICKET_NUMBER="$ARGUMENT"

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
else
  # Variant 2 & 3: key-with-slug or unknown format -> boot as is.
  TICKET_DIR_NAME="$ARGUMENT"
fi

echo "Booting $ARGUMENT (worktree: $TICKET_DIR_NAME)..." >&2
source "$DASHBOARD_DIR/boot-common.sh"
add_worktree "$CHECKOUTS_DIR/$TICKET_DIR_NAME" "$TICKET_DIR_NAME" || exit 1

# Only the resolved directory name goes to STDOUT.
echo "$TICKET_DIR_NAME"
