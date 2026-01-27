echo "Install script start"

# resolve for python3

python3 -m venv venv
source venv/bin/activate

if which pip3 >/dev/null; then
    echo
else
    echo "pip does't not exist, please install manually"
fi

if pip3 show jira >/dev/null; then
    echo "jira module installed"
else
    pip3 install --upgrade jira
fi

if pip3 show keyring >/dev/null; then
    echo "keyring module installed"
else
    pip3 install --upgrade keyring
fi

echo "Install script done"
