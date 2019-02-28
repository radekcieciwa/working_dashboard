#!/usr/local/bin/python

import keyring
import getpass
import argparse
from jira import JIRA

# Arguments
parser = argparse.ArgumentParser()
parser.add_argument("-v", "--verbose", action="store_true")
parser.add_argument("-f", "--format", type=int, default=0, help="printed format of tickets, 0 - default, 1 - CSV")
parser.add_argument("tickets", help="ticket list separated by coma, eg. IOS-123,IOS-456")
args = parser.parse_args()
format_index = args.format

# Config
# Initialize config before other scripts
import dashboard_config
dashboard_config.init(args.verbose)

# Main
from jira_dashboard_common import *

RESULTS = get_ticket_list(args.tickets)

FORMATS = [
    u'{0:2}.\t{1:10.8}\t{2:12.10}\t{3:20.18}\t{4:88.80}',
    u'{0:2}.,{1},{2},{3},{4}'
]

if format_index >= len(FORMATS):
    format_index = 0

picked_format = FORMATS[format_index]
for idx, issue in enumerate(RESULTS):
    print picked_format.format(idx + 1, issue.key, issue.fields.status, issue.fields.assignee, issue.fields.summary)
