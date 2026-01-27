#!/usr/local/bin/python3
# DEPENDENCIES:
# simple-term-menu: pip install simple-term-menu

import sys
from simple_term_menu import TerminalMenu
from jira_dashboard_common import get_ticket_list
from config import setup_vprint

setup_vprint(False)

if len(sys.argv) < 2:
    print("Usage: jira_select_status_interactive.py <ticket_list_by_comma>")
    sys.exit(1)

tickets_by_comma = sys.argv[1]

try:
    # Fetch tickets from JIRA
    results = get_ticket_list(tickets_by_comma, "")

    if not results:
        print("No tickets found")
        sys.exit(1)

    # Extract unique statuses from tickets
    statuses = {}
    for issue in results:
        status = str(issue.fields.status)
        if status not in statuses:
            statuses[status] = 0
        statuses[status] += 1

    # Sort statuses by count (descending) then alphabetically
    sorted_statuses = sorted(statuses.items(), key=lambda x: (-x[1], x[0]))

    if not sorted_statuses:
        print("No statuses found")
        sys.exit(1)

    # Prepare menu options
    menu_items = []
    status_names = []

    for status, count in sorted_statuses:
        menu_item = f"{status:<30} ({count} ticket{'s' if count != 1 else ''})"
        menu_items.append(menu_item)
        status_names.append(status)

    # Create and show interactive menu
    terminal_menu = TerminalMenu(
        menu_items,
        title="Select a status to delete tickets (↑/↓ arrows, Enter to select, q to quit):",
        multi_select=False,
        show_search_hint=True
    )

    menu_entry_index = terminal_menu.show()

    if menu_entry_index is None:
        # User quit the menu
        sys.exit(1)

    # Output the selected status
    print(status_names[menu_entry_index])
    sys.exit(0)

except KeyboardInterrupt:
    print("\nCancelled")
    sys.exit(1)
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
