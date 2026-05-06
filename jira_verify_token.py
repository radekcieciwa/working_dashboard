#!/usr/local/bin/python3

import sys
from jira_common import shared_authenticate_and_make_JIRA

try:
    jira = shared_authenticate_and_make_JIRA()
    jira.close()
    print("✓ Token is valid and Jira connection successful")
    sys.exit(0)
except SystemExit as e:
    sys.exit(1)
except Exception as e:
    print("ERROR: Failed to verify token")
    print("Details: {}".format(str(e)))
    sys.exit(1)
