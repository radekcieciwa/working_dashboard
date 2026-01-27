#!/bin/bash
#
# Dashboard Upgrade Script
# Upgrades Python dependencies to their latest versions
#

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SCRIPT_DIR/venv"
REQUIREMENTS_FILE="$SCRIPT_DIR/requirements.txt"

echo "============================================"
echo "Dashboard Upgrade Script"
echo "============================================"
echo

# Check if virtual environment exists
if [ ! -d "$VENV_DIR" ]; then
    echo "Error: Virtual environment not found at: $VENV_DIR"
    echo "Please run install.sh first"
    exit 1
fi

# Check if requirements.txt exists
if [ ! -f "$REQUIREMENTS_FILE" ]; then
    echo "Error: requirements.txt not found at $REQUIREMENTS_FILE"
    exit 1
fi

# Activate virtual environment
echo "Activating virtual environment..."
source "$VENV_DIR/bin/activate"

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip
echo

# Upgrade all dependencies from requirements.txt
echo "Upgrading dependencies from requirements.txt..."
pip install --upgrade -r "$REQUIREMENTS_FILE"
echo

# Show installed versions
echo "Current package versions:"
echo "----------------------------------------"
while IFS= read -r package; do
    # Skip empty lines and comments
    [[ -z "$package" || "$package" =~ ^# ]] && continue

    # Extract package name (handle package==version format)
    package_name=$(echo "$package" | sed 's/[>=<].*//' | sed 's/\[.*\]//')

    if pip show "$package_name" &> /dev/null; then
        version=$(pip show "$package_name" | grep "Version:" | awk '{print $2}')
        echo "  $package_name: $version"
    fi
done < "$REQUIREMENTS_FILE"
echo "----------------------------------------"
echo

# Deactivate virtual environment
deactivate

echo "============================================"
echo "Upgrade completed successfully!"
echo "============================================"
