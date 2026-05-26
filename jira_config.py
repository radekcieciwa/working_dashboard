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
        return {"repositories": {}, "default": None}

    try:
        with open(CONFIG_FILE, 'r') as f:
            return json.load(f)
    except (json.JSONDecodeError, IOError):
        return {"repositories": {}, "default": None}

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
        default_marker = " (default)" if name == config.get("default") else ""
        print(f"  {name}{default_marker}")
        print(f"    CONTAINER_DIR: {settings.get('CONTAINER_DIR', 'N/A')}")

def init_repo(repo_name, repo_dir=None):
    """Initialize a new repository configuration."""
    if repo_dir is None:
        repo_dir = os.getcwd()

    repo_dir = os.path.abspath(repo_dir)
    if not os.path.isdir(repo_dir):
        print(f"Error: Directory '{repo_dir}' does not exist")
        return False

    config = load_config()

    container_dir = repo_dir
    checkouts_dir = os.path.join(repo_dir, "_tickets")
    repo_clone_path = os.path.join(repo_dir, "bumble")  # Or detect from git

    config["repositories"][repo_name] = {
        "CONTAINER_DIR": container_dir,
        "CHECKOUTS_DIR": checkouts_dir,
        "REPO_CLONE_PATH": repo_clone_path
    }

    if not config.get("default"):
        config["default"] = repo_name

    save_config(config)
    print(f"Configured repository '{repo_name}':")
    print(f"  CONTAINER_DIR: {container_dir}")
    print(f"  CHECKOUTS_DIR: {checkouts_dir}")
    print(f"  REPO_CLONE_PATH: {repo_clone_path}")
    return True

def get_repo_config(repo_name=None):
    """Get configuration for a specific repository."""
    config = load_config()

    if repo_name is None:
        repo_name = config.get("default")

    if not repo_name or repo_name not in config["repositories"]:
        return None

    return config["repositories"][repo_name]

def set_value(repo_name, key, value):
    """Set a configuration value for a repository."""
    config = load_config()

    if repo_name not in config["repositories"]:
        print(f"Error: Repository '{repo_name}' not found")
        return False

    valid_keys = ["CONTAINER_DIR", "CHECKOUTS_DIR", "REPO_CLONE_PATH", "POST_BOOT_SCRIPT"]
    if key not in valid_keys:
        print(f"Error: Invalid key '{key}'. Valid keys are: {', '.join(valid_keys)}")
        return False

    config["repositories"][repo_name][key] = value
    save_config(config)
    print(f"Set {repo_name}.{key} = {value}")
    return True

def switch_default(repo_name):
    """Switch the default repository."""
    config = load_config()

    if repo_name not in config["repositories"]:
        print(f"Error: Repository '{repo_name}' not found")
        return False

    config["default"] = repo_name
    save_config(config)
    print(f"Default repository switched to '{repo_name}'")
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
        print("Usage: jira_config.py <command> [args]")
        print("Commands:")
        print("  list              List all configured repositories")
        print("  init <name> [dir] Initialize a new repository configuration")
        print("  get <name>        Get configuration for a repository")
        print("  set <name> <key> <value>  Set a configuration value")
        print("  switch <name>     Switch the default repository")
        print("  export [name]     Export shell variables for a repository")
        return 1

    cmd = sys.argv[1]

    if cmd == "list":
        list_repos()
    elif cmd == "init":
        if len(sys.argv) < 3:
            print("Usage: jira_config.py init <name> [directory]")
            return 1
        repo_name = sys.argv[2]
        repo_dir = sys.argv[3] if len(sys.argv) > 3 else None
        init_repo(repo_name, repo_dir)
    elif cmd == "get":
        if len(sys.argv) < 3:
            print("Usage: jira_config.py get <name>")
            return 1
        repo_config = get_repo_config(sys.argv[2])
        if repo_config:
            print(json.dumps(repo_config, indent=2))
        else:
            print(f"Repository '{sys.argv[2]}' not found")
            return 1
    elif cmd == "set":
        if len(sys.argv) < 5:
            print("Usage: jira_config.py set <name> <key> <value>")
            return 1
        set_value(sys.argv[2], sys.argv[3], sys.argv[4])
    elif cmd == "switch":
        if len(sys.argv) < 3:
            print("Usage: jira_config.py switch <name>")
            return 1
        switch_default(sys.argv[2])
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
