#!/usr/local/bin/python

from jira import JIRA
from jira_common import shared_authenticate_and_make_JIRA
import keyring
import getpass
import dashboard_config
from config import *

def authenticate_and_make_JIRA():
	return shared_authenticate_and_make_JIRA()

def get_ticket_list(TICKETS_BY_COMMA, ORDERED_BY = ""):
    jira = authenticate_and_make_JIRA()
    query = "key in ({}) {}".format(TICKETS_BY_COMMA, ORDERED_BY)
    vprint("Querying: '{}'".format(query))
    RESULTS = jira.search_issues(query, maxResults=200)
    jira.close()
    vprint("Got results ...")
    return RESULTS

def get_ticket_list_in_status(TICKETS_BY_COMMA, STATUSES):
    jira = authenticate_and_make_JIRA()
    query = "key in ({0}) and status in ({1})".format(TICKETS_BY_COMMA, STATUSES)
    vprint("Querying: '{}'".format(query))
    RESULTS = jira.search_issues(query, maxResults=200)
    jira.close()
    vprint("Got results ...")
    return RESULTS
