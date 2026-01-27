#!/usr/local/bin/python3
# DEPENDENCIES:
# keyring: pip install keyring

import keyring
import getpass

from jira import JIRA
from config import *

def shared_authenticate_and_make_JIRA():
    keychain_service = "jira_script"
    server_key_entry = "server"
    server = keyring.get_password(keychain_service, server_key_entry)
    if server is None:
        server = getpass.getpass('Server: ')
        keyring.set_password(keychain_service, server_key_entry, server)

    user_key_entry = "user"
    user = keyring.get_password(keychain_service, user_key_entry)
    if user is None:
        user = getpass.getpass('User (email): ')
        keyring.set_password(keychain_service, user_key_entry, user)

    # Get token from keychain
    token_key_entry = "token"
    token = keyring.get_password(keychain_service, token_key_entry)
    if token is None:
        token = getpass.getpass('Token: ')
        keyring.set_password(keychain_service, token_key_entry, token)

    # Authentication to JIRA using token
    jira = JIRA(
        server=server,
        basic_auth=(user, token)
    )

    vprint("Connected as {}".format(user))
    return jira
