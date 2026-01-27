#!/bin/bash
#
# Dashboard Installation Script
# Sets up Python virtual environment and installs dependencies
#

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SCRIPT_DIR/venv"
REQUIREMENTS_FILE="$SCRIPT_DIR/requirements.txt"

echo "============================================"
echo "Dashboard Installation Script"
echo "============================================"
echo

# Check Python version
if ! command -v python3 &> /dev/null; then
    echo "Error: python3 is not installed"
    echo "Please install Python 3.7 or higher"
    exit 1
fi

PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
echo "Python version: $PYTHON_VERSION"
echo

# Check if requirements.txt exists
if [ ! -f "$REQUIREMENTS_FILE" ]; then
    echo "Error: requirements.txt not found at $REQUIREMENTS_FILE"
    exit 1
fi

# Create or update virtual environment
if [ -d "$VENV_DIR" ]; then
    echo "Virtual environment already exists at: $VENV_DIR"
    read -p "Do you want to recreate it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing existing virtual environment..."
        rm -rf "$VENV_DIR"
        echo "Creating new virtual environment..."
        python3 -m venv "$VENV_DIR"
    else
        echo "Using existing virtual environment"
    fi
else
    echo "Creating virtual environment at: $VENV_DIR"
    python3 -m venv "$VENV_DIR"
fi

echo

# Activate virtual environment
echo "Activating virtual environment..."
source "$VENV_DIR/bin/activate"

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip
echo

# Install dependencies from requirements.txt
echo "Installing dependencies from requirements.txt..."
pip install -r "$REQUIREMENTS_FILE"
echo

# Verify installations
echo "Verifying installations..."
echo "----------------------------------------"
while IFS= read -r package; do
    # Skip empty lines and comments
    [[ -z "$package" || "$package" =~ ^# ]] && continue

    # Extract package name (handle package==version format)
    package_name=$(echo "$package" | sed 's/[>=<].*//' | sed 's/\[.*\]//')

    if pip show "$package_name" &> /dev/null; then
        version=$(pip show "$package_name" | grep "Version:" | awk '{print $2}')
        echo "✓ $package_name ($version)"
    else
        echo "✗ $package_name - NOT INSTALLED"
    fi
done < "$REQUIREMENTS_FILE"
echo "----------------------------------------"
echo

# Make Python scripts executable
echo "Setting executable permissions on Python scripts..."
chmod +x "$SCRIPT_DIR"/*.py 2>/dev/null || true

# Deactivate virtual environment
deactivate

echo
echo "============================================"
echo "Installation completed successfully!"
echo "============================================"
echo
echo "Virtual environment location: $VENV_DIR"
echo
echo "To use the dashboard commands, make sure DASHBOARD_DIR"
echo "is set in your shell environment and dashboard.sh is sourced."
