#!/usr/bin/env bash
#

# Color changes: https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

function usage() {
  echo "Usage: $0 <device id> <application bundle>"
  echo "  build {Calabash, Debug}"
}

if [ "$#" -ne 2 ]; then
    usage
    exit 1
fi

DEVICE_ID=$1
APPLICATION=$2

xcrun simctl boot $DEVICE_ID
open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app/
xcrun simctl install $DEVICE_ID
xcrun simctl launch $DEVICE_ID $APPLICATION

# printf "${YELLOW}Checking ${PROJECT}, scheme: ${BRAND}, configuration: ${BUILD}${NC}\n"
# echo
#
# APP_BUNDLE_PATH=$(\
#     xcodebuild \
#     -workspace "$PROJECT" \
#     -scheme $BRAND \
#     -configuration $BUILD \
#     -sdk iphonesimulator \
#     -showBuildSettings \
#     | awk '/CODESIGNING_FOLDER_PATH/ { print $3 }' \
#     | grep .app \
# )
#
# printf "Found at: ${GREEN}${APP_BUNDLE_PATH}${NC}\n"
