#!/usr/bin/env python3

import json
import os
import sys
from pathlib import Path

CONFIG_DIR = Path.home() / ".dashboard"
CONFIG_FILE = CONFIG_DIR / "config.json"

def ensure_config_dir():
    """Create config directory if it doesn't exist."""
    CONFIG_DIR.mkdir(exist_ok=True, parents=True)

def load_config():
    """Load configuration from file."""
    if not CONFIG_FILE.exists():
        return {"repositories": {}, "current": None}

    try:
        with open(CONFIG_FILE, 'r') as f:
            return json.load(f)
    except (json.JSONDecodeError, IOError):
        return {"repositories": {}, "current": None}

def save_config(config):
    """Save configuration to file."""
    ensure_config_dir()
    with open(CONFIG_FILE, 'w') as f:
        json.dump(config, f, indent=2)

def list_repos():
    """List all configured repositories."""
    config = load_config()
    if not config["repositories"]:
        print("No repositories configured.")
        return

    print("Configured repositories:")
    for name, settings in config["repositories"].items():
        current_marker = " (current)" if name == config.get("current") else ""
        checkouts_dir = settings.get('CHECKOUTS_DIR', 'N/A')
        repo_clone_path = settings.get('REPO_CLONE_PATH', 'N/A')
        print(f"  {name}{current_marker}")
        print(f"    Clone:   {repo_clone_path}")
        print(f"    Tickets: {checkouts_dir}")

def init_repo(repo_name, repo_clone_path=None, checkouts_dir=None):
    """Initialize a new repository configuration."""
    if repo_clone_path is None:
        print(f"Usage: dashboard config init <name> <clone_path> <checkouts_path>")
        return False

    if checkouts_dir is None:
        print(f"Usage: dashboard config init <name> <clone_path> <checkouts_path>")
        return False

    repo_clone_path = os.path.abspath(repo_clone_path)
    checkouts_dir = os.path.abspath(checkouts_dir)

    if not os.path.isdir(repo_clone_path):
        print(f"Error: Clone directory '{repo_clone_path}' does not exist")
        return False

    if not os.path.isdir(checkouts_dir):
        print(f"Error: Checkouts directory '{checkouts_dir}' does not exist")
        return False

    config = load_config()

    config["repositories"][repo_name] = {
        "CHECKOUTS_DIR": checkouts_dir,
        "REPO_CLONE_PATH": repo_clone_path
    }

    if not config.get("current"):
        config["current"] = repo_name

    save_config(config)
    print(f"Configured repository '{repo_name}':")
    print(f"  Clone:   {repo_clone_path}")
    print(f"  Tickets: {checkouts_dir}")
    return True

def get_repo_config(repo_name=None):
    """Get configuration for a specific repository."""
    config = load_config()

    if repo_name is None:
        repo_name = config.get("current")

    if not repo_name or repo_name not in config["repositories"]:
        return None

    return config["repositories"][repo_name]

def switch_current(repo_name):
    """Switch the current repository."""
    config = load_config()

    if repo_name not in config["repositories"]:
        print(f"Error: Repository '{repo_name}' not found")
        return False

    config["current"] = repo_name
    save_config(config)
    print(f"Current repository switched to '{repo_name}'")
    return True

def export_shell_vars(repo_name=None):
    """Export shell variables for sourcing in shell config."""
    repo_config = get_repo_config(repo_name)

    if not repo_config:
        return None

    exports = []
    for key, value in repo_config.items():
        exports.append(f"export {key}=\"{value}\"")

    return "\n".join(exports)

def main():
    if len(sys.argv) < 2:
        print("Usage: dashboard config <command> [args]")
        print("Commands:")
        print("  list                          List all configured repositories")
        print("  init <name> <clone> <tickets> Initialize a new repository")
        print("  switch <name>                 Switch the current repository")
        return 1

    cmd = sys.argv[1]

    if cmd == "list":
        list_repos()
    elif cmd == "init":
        if len(sys.argv) < 5:
            print("Usage: dashboard config init <name> <clone_path> <checkouts_path>")
            return 1
        repo_name = sys.argv[2]
        repo_clone_path = sys.argv[3]
        checkouts_dir = sys.argv[4]
        init_repo(repo_name, repo_clone_path, checkouts_dir)
    elif cmd == "switch":
        if len(sys.argv) < 3:
            print("Usage: jira_config.py switch <name>")
            return 1
        switch_current(sys.argv[2])
    elif cmd == "export":
        repo_name = sys.argv[2] if len(sys.argv) > 2 else None
        vars_export = export_shell_vars(repo_name)
        if vars_export:
            print(vars_export)
        else:
            print("No configuration found")
            return 1
    else:
        print(f"Unknown command: {cmd}")
        return 1

    return 0

if __name__ == "__main__":
    sys.exit(main())
