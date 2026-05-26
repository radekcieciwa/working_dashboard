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

### 2. Configure your repository

You can use the new central configuration manager to set up multiple repositories without editing shell config files.

Initialize your repository configuration:

```bash
dashboard config init badoo /Users/$(whoami)/Development/iOS/Badoo
```

Then add this to your `~/.bash_profile` or `~/.zshrc` file:

```bash
export DASHBOARD_DIR="/path/to/working_dashboard"
source $DASHBOARD_DIR/dashboard.sh
```

The dashboard will automatically load your default repository configuration.

#### Configuration Commands

```bash
# List all configured repositories
dashboard config list

# Initialize a new repository (auto-detects paths)
dashboard config init <repo-name> [directory]

# Set a specific configuration value
dashboard config set <repo-name> BADOO_REPO_DIR /path/to/repo

# Switch the default repository
dashboard config switch <repo-name>

# Export shell variables for a repository
dashboard config export <repo-name>
```

### 3. Set up authentication

Store your JIRA API token securely in the keychain:

```bash
dashboard token YOUR_JIRA_API_TOKEN
```

On first use, the scripts will also prompt you for:
* Server URL (e.g., `https://your.domain.co.uk`)
* User email (e.g., `john.doe@company.com`)

These credentials are stored securely in your system keychain.

### Configuration Variables

The following environment variables can be set to override the default configuration:

- `BADOO_REPO_DIR` - Main repository directory
- `DASHBOARD_DIR` - Dashboard script location
- `TICKETS_WORKSPACE_DIR` - Where to create worktree copies (defaults to `BADOO_REPO_DIR`)
- `SOURCE_REPO_PATH` - Original working copy directory for maintaining neutral branch (defaults to `BADOO_REPO_DIR/_source`)

These are automatically configured via `dashboard config init` and stored in `~/.dashboard/config.json`.

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

