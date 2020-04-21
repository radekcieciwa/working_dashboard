# working_dashboard

## How to install

Add this to your `~/.bash_profile` file.

```
export BADOO_REPO_DIR="/Users/`whoami`/Development/iOS/Badoo"
export DASHBOARD_DIR="$BADOO_REPO_DIR/working_dashboard"

# This will source main dashboard.sh script. It's important to be able to enter directory after creating the ticket.
source $DASHBOARD_DIR/dashboard.sh
```

#### Why?

Previously I dependent only on directory convention, which were hardcoded in scripts. Now, they are control by env variables.

### Default setup

Default setup is in `dashboard.sh`, but you can override it by exporting your own values to those variables.

```
export TICKETS_WORKSPACE_DIR="$BADOO_REPO_DIR"
export SOURCE_REPO_PATH="$BADOO_REPO_DIR/_source"
```

`SOURCE_REPO_PATH` - **this is your original (ad only one) working copy directory, keep the some neutral branch, like `dev` or `master`**

`TICKETS_WORKSPACE_DIR` - place where you want to add your worktree copies

### Dashbaord view

Python modules requirements:

These can be install via `pip` (install pip https://pip.pypa.io/en/stable/installing/):

`pip install jira`

`pip install keyring`

* `jira`
* `keyring`

#### Jira script will prompt you for:

* server (eg. `https://your.domain.co.uk`)
* user (your jira user eg. `john.doe` - so without `@bla.bla.com`)
* password

##### To clean those entries

* Go to keychain
* Search for `jira_script`
* Remove entries

