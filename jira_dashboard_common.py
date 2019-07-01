#!/usr/local/bin/python

from jira import JIRA
from jira_common import shared_authenticate_and_make_JIRA
import keyring
import getpass
import dashboard_config

# Solution taken from: https://stackoverflow.com/questions/5980042/how-to-implement-the-verbose-or-v-option-into-a-script
# You can look for other python versions there
if dashboard_config.verbose:
    def verboseprint(*args):
        # Print each argument separately so caller doesn't need to
        # stuff everything to be printed into a single string
        for arg in args:
           print arg,
        print
else:
    verboseprint = lambda *a: None      # do-nothing function

def authenticate_and_make_JIRA():
	return shared_authenticate_and_make_JIRA(dashboard_config.verbose)

def get_ticket_list(TICKETS_BY_COMMA, ORDERED_BY = ""):
    jira = authenticate_and_make_JIRA()
    query = "key in ({}) {}".format(TICKETS_BY_COMMA, ORDERED_BY)
    verboseprint("Querying: '{}'".format(query))
    RESULTS = jira.search_issues(query, maxResults=50)
    jira.close()
    verboseprint("Got results ...")
    return RESULTS

def get_ticket_list_in_status(TICKETS_BY_COMMA, STATUSES):
    jira = authenticate_and_make_JIRA()
    query = "key in ({0}) and status in ({1})".format(TICKETS_BY_COMMA, STATUSES)
    verboseprint("Querying ...")
    RESULTS = jira.search_issues(query, maxResults=50)
    jira.close()
    verboseprint("Got results ...")
    return RESULTS
