#!/usr/local/bin/python3

import sys
from jira_common import shared_authenticate_and_make_JIRA
from jira.exceptions import JIRAError

try:
    jira = shared_authenticate_and_make_JIRA()
    # Make an actual API call to verify the token works
    user = jira.myself()
    jira.close()
    print("✓ Token is valid and Jira connection successful")
    # Handle both dict and object responses
    if isinstance(user, dict):
        user_name = user.get('displayName', user.get('name', 'User'))
    else:
        user_name = user.displayName
    print("Logged in as: {}".format(user_name))
    sys.exit(0)
except SystemExit as e:
    sys.exit(1)
except JIRAError as e:
    error_str = str(e)
    if "401" in error_str or "Unauthorized" in error_str:
        print("ERROR: Token is invalid or expired")
        print("Please update your token with:")
        print("  dashboard token <YOUR_NEW_TOKEN>")
    else:
        print("ERROR: Jira connection failed")
        print("Details: {}".format(error_str))
    sys.exit(1)
except Exception as e:
    print("ERROR: Failed to verify token")
    print("Details: {}".format(str(e)))
    sys.exit(1)
