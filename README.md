# working_dashboard

## How to run

### Authentication
```bash
# Store your JIRA API token
dashboard token YOUR_JIRA_API_TOKEN
```

### Common commands
```bash
# Create a working directory and initiate scripts for a ticket
dashboard boot IOS-123456

# View tickets
dashboard view

# Open ticket directory (interactive selection)
dashboard open

# Open specific ticket directory
dashboard open IOS-123456

# Delete ticket workspace
dashboard delete IOS-123456

# Delete tickets by status (interactive selection)
dashboard delete-batch

# Delete tickets by specific status
dashboard delete-batch -s "In Release branch"
```

### Command reference

**token** - Store authentication token in keychain

**boot** - Create a working directory and initiate the scripts for ticket

**open** - Opens the directory for ticket. If no ticket key is provided, displays an interactive menu to select from current tickets (use arrow keys to navigate, Enter to select)

**view** - Display list of tickets (requires JIRA credentials)

**delete** - Clean local branches and worktree copy for a specific ticket

**delete-batch** - Clean local branches and worktree copy for tickets by status. If no status is provided with `-s` flag, displays an interactive menu to select from available statuses in your current tickets (use arrow keys to navigate, Enter to select). Options:
  - `-s STATUS` - Specify status directly (e.g., `-s "Closed"`)
  - `-n` - Dry run mode (show what would be deleted without deleting)
  - `-f` - Skip confirmation prompts
  - `-F` - Skip force delete prompts

**cleanup** - Clean done tickets by status and remove derived data

### Create working copy fast and prototype the solution, end with a patch

**boot-random** - creates a working directory, without any scripts

**patch-close** - remove working directory and creates the patch in main directory with the same file name as working directory

## How to install

### 1. Run the installation script

```bash
cd /path/to/working_dashboard
./install.sh
```

The installation script will:
- Create a Python virtual environment
- Install all required dependencies from `requirements.txt`
- Set executable permissions on Python scripts

### 2. Configure your shell

Add this to your `~/.bash_profile` or `~/.zshrc` file:

```bash
export BADOO_REPO_DIR="/Users/`whoami`/Development/iOS/Badoo"
export DASHBOARD_DIR="$BADOO_REPO_DIR/working_dashboard"

# This will source main dashboard.sh script. It's important to be able to enter directory after creating the ticket.
source $DASHBOARD_DIR/dashboard.sh
```

#### Why?

Previously I dependent only on directory convention, which were hardcoded in scripts. Now, they are controlled by env variables.

### 3. Set up authentication

Store your JIRA API token securely in the keychain:

```bash
dashboard token YOUR_JIRA_API_TOKEN
```

On first use, the scripts will also prompt you for:
* Server URL (e.g., `https://your.domain.co.uk`)
* User email (e.g., `john.doe@company.com`)

These credentials are stored securely in your system keychain.

### Default setup

Default setup is in `dashboard.sh`, but you can override it by exporting your own values to those variables:

```bash
export TICKETS_WORKSPACE_DIR="$BADOO_REPO_DIR"
export SOURCE_REPO_PATH="$BADOO_REPO_DIR/_source"
```

`SOURCE_REPO_PATH` - **this is your original (and only one) working copy directory, keep on some neutral branch, like `dev` or `master`**

`TICKETS_WORKSPACE_DIR` - place where you want to add your worktree copies

## Python dependencies

All Python dependencies are managed through `requirements.txt`:

* `jira` - JIRA API client
* `keyring` - Secure credential storage
* `simple-term-menu` - Interactive CLI menus

To upgrade dependencies:
```bash
./upgrade.sh
```

## Managing credentials

### To clean keychain entries

* Go to Keychain Access app
* Search for `jira_script`
* Remove entries

Or use the command line:
```bash
security delete-generic-password -s "jira_script" -a "token"
security delete-generic-password -s "jira_script" -a "server"
security delete-generic-password -s "jira_script" -a "user"
```

