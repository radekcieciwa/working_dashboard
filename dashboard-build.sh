#!/usr/bin/env bash
#

# Color changes: https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

function usage() {
  echo "Usage: $0 <build> <brand> <jira ticket>"
  echo "  build {Calabash, Debug}"
}

if [ "$#" -ne 3 ]; then
    usage
    exit 1
fi

PROJECT="${TICKETS_WORKSPACE_DIR}/${3}/Dev.xcworkspace"
BRAND=$2
BUILD=$1

printf "${YELLOW}Checking ${PROJECT}, scheme: ${BRAND}, configuration: ${BUILD}${NC}\n"
echo

APP_BUNDLE_PATH=$(\
    xcodebuild \
    -workspace "$PROJECT" \
    -scheme $BRAND \
    -configuration $BUILD \
    -sdk iphonesimulator \
    -showBuildSettings \
    | awk '/CODESIGNING_FOLDER_PATH/ { print $3 }' \
    | grep .app \
)

echo

if [[ -d "$APP_BUNDLE_PATH" ]]; then
  printf "${GREEN}Build exists${NC}\n"
else
  printf "${RED}Build's missing${NC}\n"
  printf "${YELLOW}Building...${NC}\n\n"
fi

xcodebuild \
  -workspace "$PROJECT" \
  -scheme $BRAND \
  -configuration $BUILD \
  -sdk iphonesimulator \
  build

echo
printf "Found at: ${GREEN}${APP_BUNDLE_PATH}${NC}\n"

echo
