#!/usr/local/bin/python3
# DEPENDENCIES:
# simple-term-menu: pip install simple-term-menu

import sys
from simple_term_menu import TerminalMenu
from jira_dashboard_common import get_ticket_list, worktree_names_by_key
from config import setup_vprint

setup_vprint(False)

if len(sys.argv) < 2:
    print("Usage: jira_open_interactive.py <ticket_list_by_comma>")
    sys.exit(1)

tickets_by_comma = sys.argv[1]

try:
    # Fetch tickets from JIRA
    results = get_ticket_list(tickets_by_comma, "ORDER BY updated DESC")

    if not results:
        print("No tickets found")
        sys.exit(1)

    # Map each Jira key back to its worktree directory name, so we open the
    # directory on disk (e.g. IAT-1234-summary-is-long) rather than the bare key.
    names_by_key = worktree_names_by_key(tickets_by_comma)

    # Prepare menu options
    menu_items = []
    worktree_names = []

    for issue in results:
        status = str(issue.fields.status)[:15].ljust(15)
        assignee = str(issue.fields.assignee)[:20].ljust(20)
        summary = issue.fields.summary[:60]
        menu_item = f"{issue.key:<12} {status} {assignee} {summary}"
        menu_items.append(menu_item)
        worktree_names.append(names_by_key.get(issue.key, issue.key))

    # Create and show interactive menu
    terminal_menu = TerminalMenu(
        menu_items,
        title="Select a ticket to open (↑/↓ arrows, Enter to select, q to quit):"
    )

    menu_entry_index = terminal_menu.show()

    if menu_entry_index is None:
        # User quit the menu
        sys.exit(1)

    # Output the selected worktree directory name
    print(worktree_names[menu_entry_index])
    sys.exit(0)

except KeyboardInterrupt:
    print("\nCancelled")
    sys.exit(1)
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
