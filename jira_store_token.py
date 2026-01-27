#!/usr/local/bin/python3
# DEPENDENCIES:
# keyring: pip install keyring

import keyring
import sys

def store_token(token):
    keychain_service = "jira_script"
    token_key_entry = "token"
    keyring.set_password(keychain_service, token_key_entry, token)
    print("Token stored successfully in keychain")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: jira_store_token.py <token>")
        sys.exit(1)

    token = sys.argv[1]
    store_token(token)
