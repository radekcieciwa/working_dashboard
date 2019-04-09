#!/usr/local/bin/python
# DEPENDENCIES:
# keyring: pip install keyring

import keyring
import getpass

from jira import JIRA
from config import *

def shared_shared_authenticate_and_make_JIRA(verbose):
    keychain_service = "jira_script"

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
    vprint("Connecting: {}".format(server))
    jira = JIRA(server, auth=(user, password))
    vprint("Connected as {}".format(user))
    return jira
