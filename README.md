# working_dashboard

## How to run

### Repository Selection

All commands use the current repository. Switch repositories using the `config switch` command:

```bash
# See which repository is current
dashboard config list

# Switch to a different repository
dashboard config switch staging

# Now all commands use the staging repository
dashboard boot IOS-123
dashboard view
```

### Authentication
```bash
# Store your JIRA API token
dashboard token YOUR_JIRA_API_TOKEN
```

### Common commands

```bash
# Check current repository setup
dashboard config current

# Create a working directory and initiate scripts for a ticket
dashboard boot <TICKET>

# View tickets
dashboard view

# Open ticket directory (interactive selection)
dashboard open

# Open specific ticket directory
dashboard open <TICKET>

# Delete ticket workspace
dashboard delete <TICKET>

# Delete tickets by status (interactive selection)
dashboard delete-batch

# Delete tickets by specific status
dashboard delete-batch -s "In Release branch"
```

### Command reference

**token `<TOKEN>`** - Store authentication token in keychain

**boot `<TICKET>`** - Create a working directory and initiate the scripts for ticket

**open `[TICKET]`** - Opens the directory for ticket. If no ticket key is provided, displays an interactive menu to select from current tickets (use arrow keys to navigate, Enter to select)

**view** - Display list of tickets (requires JIRA credentials)

**delete `<TICKET>`** - Clean local branches and worktree copy for a specific ticket

**delete-batch** - Clean local branches and worktree copy for tickets by status. If no status is provided with `-s` flag, displays an interactive menu to select from available statuses in your current tickets (use arrow keys to navigate, Enter to select). Options:
  - `-s STATUS` - Specify status directly (e.g., `-s "Closed"`)
  - `-n` - Dry run mode (show what would be deleted without deleting)
  - `-f` - Skip confirmation prompts
  - `-F` - Skip force delete prompts

**config current** - Display the current repository setup with clone and tickets paths

**config list** - List all configured repositories with current selection

**config init `<name> <clone-path> <tickets-path>`** - Initialize a new repository configuration

**config switch `<name>`** - Switch the current repository


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
# Show current repository setup
dashboard config current

# List all configured repositories
dashboard config list

# Initialize a new repository
dashboard config init <repo-name> <clone-path> <tickets-path>

# Switch the current repository
dashboard config switch <repo-name>
```

### 3. Set up authentication

Store your JIRA API token securely in the keychain:

```bash
dashboard token YOUR_JIRA_API_TOKEN
```

**On first use** of any dashboard command, you'll be prompted for:

* **Server** — The full JIRA server URL (e.g., `https://jira.company.com` or `https://your.domain.co.uk`). This is the domain you visit in your browser, not a file path.
* **User** — Your JIRA account email address (e.g., `john.doe@company.com`)
* **Token** — A personal access token generated from JIRA. Get it from JIRA Settings → Personal Access Tokens → Create Token. Use the token value, not your password.

All credentials are stored securely in your system keychain and won't be prompted again.

### Configuration Variables

The following environment variables are stored in `~/.dashboard/config.json`:

- `REPO_CLONE_PATH` - Path to the source repository clone (where worktrees are created)
- `CHECKOUTS_DIR` - Path to where worktree checkouts for tickets are created
- `POST_BOOT_SCRIPT` - (Optional) Post-boot script to run after worktree creation

These paths can be anywhere and are independent. They are configured via `dashboard config init <name> <clone-path> <tickets-path>`.

### Post-Boot Scripts

You can define a custom post-boot script that runs after a new worktree is created. This is useful for repository-specific initialization (e.g., running build scripts, setting up dependencies).

Configure it:
```bash
dashboard config set bumble POST_BOOT_SCRIPT /path/to/script.sh
```

The script receives the ticket number as an argument and runs in the newly created checkout directory:
```bash
#!/bin/bash
TICKET_NUMBER=$1
# Custom initialization here
./aida -ei $TICKET_NUMBER
```

Post-boot scripts are optional - if not configured, only the worktree is created.

## Python dependencies

All Python dependencies are managed through `requirements.txt`:

* `jira` - JIRA API client
* `keyring` - Secure credential storage
* `simple-term-menu` - Interactive CLI menus

To upgrade dependencies:
```bash
./upgrade.sh
```

## Troubleshooting

### Reset stored credentials

If you need to change your JIRA credentials:

```bash
# Reset just the token (personal access token from JIRA Settings)
dashboard token YOUR_NEW_TOKEN

# Reset everything (server URL, email, and token will be re-prompted)
security delete-generic-password -s "jira_script" -a "token"      # Personal access token
security delete-generic-password -s "jira_script" -a "server"     # JIRA server URL
security delete-generic-password -s "jira_script" -a "user"       # JIRA email address

# Or use Keychain Access app: Search for "jira_script" and remove entries
```

