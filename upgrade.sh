echo "Install script start"

# resolve for python3

python3 -m venv venv
source venv/bin/activate

if which pip3 >/dev/null; then
    echo
else
    echo "pip does't not exist, please install manually"
fi

pip3 install --upgrade keyring
pip3 install --upgrade jira
