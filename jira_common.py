#!/usr/local/bin/python3
# DEPENDENCIES:
# keyring: pip install keyring

import keyring
import getpass
import sys

from jira import JIRA
from jira.exceptions import JIRAError
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

    vprint("Attempting to authenticate with Jira...")
    vprint("Server: {}".format(server))
    vprint("User: {}".format(user))

    # Authentication to JIRA using token
    try:
        jira = JIRA(
            server=server,
            basic_auth=(user, token)
        )
        vprint("Connected as {}".format(user))
        return jira
    except JIRAError as e:
        print("ERROR: Failed to authenticate with Jira")
        print("Details: {}".format(str(e)))
        if "401" in str(e) or "Unauthorized" in str(e):
            print("This typically indicates an invalid token.")
            print("Please run: dashboard token <TOKEN>")
        sys.exit(1)
    except Exception as e:
        print("ERROR: Connection failed to Jira server")
        print("Server: {}".format(server))
        print("Details: {}".format(str(e)))
        print("Please verify:")
        print("1. The server URL is correct")
        print("2. You have network connectivity")
        print("3. Your token is valid: dashboard token <TOKEN>")
        sys.exit(1)
