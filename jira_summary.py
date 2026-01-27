#!/usr/local/bin/python

from jira import JIRA
from jira_common import shared_authenticate_and_make_JIRA
import sys
# from config import *

issue_key = sys.argv[1]
jira = shared_authenticate_and_make_JIRA()
issue = jira.issue(issue_key)
summary = issue.fields.summary
# output = (summary)[:30]
output = summary

print(output)
