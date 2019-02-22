#!/usr/local/bin/python

from jira import JIRA
import keyring
import getpass
import sys

def authenticate_and_make_JIRA():
    keychain_service = "jira_script"

    # https://jira.badoojira.com
    server_key_entry = "server"
    server = keyring.get_password(keychain_service, server_key_entry)
    if server is None:
        server = getpass.getpass('Server: ')
        keyring.set_password(keychain_service, server_key_entry, server)

    user_key_entry = "user"
    user = keyring.get_password(keychain_service, user_key_entry)
    if user is None:
        user = getpass.getpass('User: ')
        keyring.set_password(keychain_service, user_key_entry, user)

    password_key_entry = "password"
    password = keyring.get_password(keychain_service, password_key_entry)
    if password is None:
        password = getpass.getpass('Password: ')
        keyring.set_password(keychain_service, password_key_entry, password)

    # Authentication to JIRA
    print "Connecting ..."
    jira = JIRA(server, auth=(user, password))
    return jira

def get_ticket_list(TICKETS_BY_COMMA):
    jira = authenticate_and_make_JIRA()
    query = "key in ({})".format(TICKETS_BY_COMMA)
    print "Querying ..."
    RESULTS = jira.search_issues(query, maxResults=50)
    jira.close()
    print "Got results ..."
    return RESULTS

def get_ticket_list_in_status(TICKETS_BY_COMMA, STATUSES):
    jira = authenticate_and_make_JIRA()
    query = "key in ({0}) and status in ({1})".format(TICKETS_BY_COMMA, STATUSES)
    print "Querying ..."
    RESULTS = jira.search_issues(query, maxResults=50)
    jira.close()
    print "Got results ..."
    return RESULTS
