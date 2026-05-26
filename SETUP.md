# Quick Start Guide

## Prerequisites
- Python 3.7+ installed
- macOS with Keychain (for credential storage)
- Git repository set up

**Validate environment:**
```bash
python3 --version
echo $SHELL  # Should be zsh or bash
```

## Installation

1. **Clone and navigate:**
```bash
cd /path/to/working_dashboard
```

2. **Run install script:**
```bash
./install.sh
```

3. **Add to shell config** (`~/.zshrc` or `~/.bash_profile`):
```bash
export DASHBOARD_DIR="/path/to/working_dashboard"
source $DASHBOARD_DIR/dashboard.sh
```

4. **Reload shell:**
```bash
source ~/.zshrc  # or ~/.bash_profile
```

## Configuration

1. **Initialize your repository:**
```bash
dashboard config init myrepo /path/to/repo /path/to/tickets
```

2. **Store JIRA token (one-time):**
```bash
dashboard token YOUR_JIRA_API_TOKEN
```

3. **Verify setup:**
```bash
dashboard config list
dashboard view
```

## First Use

```bash
# Create ticket workspace
dashboard boot TICKET-123

# View all tickets
dashboard view

# Open ticket directory
dashboard open TICKET-123
```
