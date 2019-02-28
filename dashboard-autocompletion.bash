#/usr/bin/env bash
# keep in sync with dashboard.sh
# words to complete are all secondary commands (here eg. boot)
# script is the main function name (here: dashboard)
complete -W "boot delete view copy" dashboard
