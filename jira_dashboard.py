#!/usr/local/bin/python

from jira_dashboard_common import *
from jira import JIRA
import keyring
import getpass
import sys

TICKETS_BY_COMMA = sys.argv[1]
RESULTS = get_ticket_list(TICKETS_BY_COMMA)

for idx, issue in enumerate(RESULTS):
    print u'{4:2}. {0:10.10}\t{1:16.14}\t{2:20.18}\t{3:88.80}'.format(issue.key, issue.fields.status, issue.fields.assignee, issue.fields.summary, idx + 1)
