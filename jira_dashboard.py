#!/usr/local/bin/python

import keyring
import getpass
import argparse
from jira import JIRA

# Arguments
parser = argparse.ArgumentParser()
parser.add_argument("-v", "--verbose", action="store_true")
parser.add_argument("tickets", help="ticket list separated by coma, eg. IOS-123,IOS-456")
args = parser.parse_args()

# Config
# Initialize config before other scripts
import dashboard_config
dashboard_config.init(args.verbose)

# Main
from jira_dashboard_common import *

RESULTS = get_ticket_list(args.tickets)
# u'{4:2}.,{0},{1},{2},{3}'
# u'{0:2}.\t{1:10.8}\t{2:12.10}\t{3:20.18}\t{4:88.80}'

for idx, issue in enumerate(RESULTS):
    print u'{4:2}. {0:10.10}\t{1:16.14}\t{2:20.18}\t{3:88.80}'.format(issue.key, issue.fields.status, issue.fields.assignee, issue.fields.summary, idx + 1)
