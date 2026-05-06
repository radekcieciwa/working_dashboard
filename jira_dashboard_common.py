#!/usr/local/bin/python

from jira import JIRA
from jira.exceptions import JIRAError
from jira_common import shared_authenticate_and_make_JIRA
import keyring
import getpass
import sys
from config import *

def authenticate_and_make_JIRA():
	return shared_authenticate_and_make_JIRA()

def get_ticket_list(TICKETS_BY_COMMA, ORDERED_BY = ""):
    try:
        jira = authenticate_and_make_JIRA()
    except SystemExit:
        raise
    except Exception as e:
        print("ERROR: Failed to authenticate with Jira")
        print("Details: {}".format(str(e)))
        sys.exit(1)

    try:
        query = "key in ({}) {}".format(TICKETS_BY_COMMA, ORDERED_BY)
        vprint("Querying: '{}'".format(query))
        RESULTS = jira.search_issues(query, maxResults=200)
        jira.close()
        vprint("Got results ...")
        return RESULTS
    except JIRAError as e:
        jira.close()
        print("ERROR: Failed to query Jira")
        print("Query: key in ({}) {}".format(TICKETS_BY_COMMA, ORDERED_BY))
        print("Details: {}".format(str(e)))
        sys.exit(1)
    except Exception as e:
        jira.close()
        print("ERROR: Unexpected error while querying Jira")
        print("Details: {}".format(str(e)))
        sys.exit(1)

def get_ticket_list_in_status(TICKETS_BY_COMMA, STATUSES):
    try:
        jira = authenticate_and_make_JIRA()
    except SystemExit:
        raise
    except Exception as e:
        print("ERROR: Failed to authenticate with Jira")
        print("Details: {}".format(str(e)))
        sys.exit(1)

    try:
        query = "key in ({0}) and status in ({1})".format(TICKETS_BY_COMMA, STATUSES)
        vprint("Querying: '{}'".format(query))
        RESULTS = jira.search_issues(query, maxResults=200)
        jira.close()
        vprint("Got results ...")
        return RESULTS
    except JIRAError as e:
        jira.close()
        print("ERROR: Failed to query Jira")
        print("Query: key in ({0}) and status in ({1})".format(TICKETS_BY_COMMA, STATUSES))
        print("Details: {}".format(str(e)))
        sys.exit(1)
    except Exception as e:
        jira.close()
        print("ERROR: Unexpected error while querying Jira")
        print("Details: {}".format(str(e)))
        sys.exit(1)
