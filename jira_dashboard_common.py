#!/usr/local/bin/python

from jira import JIRA
from jira.exceptions import JIRAError
from jira_common import shared_authenticate_and_make_JIRA
import keyring
import getpass
import re
import sys
from config import *

# Matches a Jira issue key: a project key (an uppercase letter followed by
# uppercase letters/digits) joined by a dash to the issue number, e.g. IAT-1234.
JIRA_KEY_RE = re.compile(r'[A-Z][A-Z0-9]*-\d+')

def parse_worktree_tickets(TICKETS_BY_COMMA):
    """Single source of truth for turning worktree / branch names into tickets.

    Worktree directories are not always bare keys: jira-boot.sh names them
    <KEY>-<slug> (e.g. IAT-1234-summary-is-long) and users may also have plain
    branch-named worktrees. We pull the leading Jira key out of each name so it
    can be queried, while remembering the original name so Jira results can be
    mapped back to the directory on disk.

    Returns an ordered list of (jira_key, worktree_name) pairs. Entries that
    contain no key are dropped and keys are de-duplicated (first name wins).
    """
    pairs = []
    seen = set()
    for entry in TICKETS_BY_COMMA.split(','):
        name = entry.strip()
        match = JIRA_KEY_RE.search(name)
        if not match:
            continue
        key = match.group(0)
        if key in seen:
            continue
        seen.add(key)
        pairs.append((key, name))
    return pairs

def extract_jira_keys(TICKETS_BY_COMMA):
    """Comma-separated Jira keys extracted from worktree / branch names."""
    return ','.join(key for key, _ in parse_worktree_tickets(TICKETS_BY_COMMA))

def worktree_names_by_key(TICKETS_BY_COMMA):
    """Map each Jira key back to the worktree / branch name it came from, so a
    Jira result (which only knows the key) can be resolved to the directory on
    disk (e.g. IAT-1234 -> IAT-1234-summary-is-long)."""
    return dict(parse_worktree_tickets(TICKETS_BY_COMMA))

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

    KEYS = extract_jira_keys(TICKETS_BY_COMMA)
    if not KEYS:
        vprint("No Jira keys found in: '{}'".format(TICKETS_BY_COMMA))
        jira.close()
        return []

    try:
        query = "key in ({}) {}".format(KEYS, ORDERED_BY)
        vprint("Querying: '{}'".format(query))
        RESULTS = jira.search_issues(query, maxResults=200)
        jira.close()
        vprint("Got results ...")
        return RESULTS
    except JIRAError as e:
        jira.close()
        print("ERROR: Failed to query Jira")
        print("Query: key in ({}) {}".format(KEYS, ORDERED_BY))
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

    KEYS = extract_jira_keys(TICKETS_BY_COMMA)
    if not KEYS:
        vprint("No Jira keys found in: '{}'".format(TICKETS_BY_COMMA))
        jira.close()
        return []

    try:
        query = "key in ({0}) and status in ({1})".format(KEYS, STATUSES)
        vprint("Querying: '{}'".format(query))
        RESULTS = jira.search_issues(query, maxResults=200)
        jira.close()
        vprint("Got results ...")
        return RESULTS
    except JIRAError as e:
        jira.close()
        print("ERROR: Failed to query Jira")
        print("Query: key in ({0}) and status in ({1})".format(KEYS, STATUSES))
        print("Details: {}".format(str(e)))
        sys.exit(1)
    except Exception as e:
        jira.close()
        print("ERROR: Unexpected error while querying Jira")
        print("Details: {}".format(str(e)))
        sys.exit(1)
