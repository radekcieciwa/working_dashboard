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

TICKET=$3
PROJECT="${TICKETS_WORKSPACE_DIR}/${TICKET}/Dev.xcworkspace"
BRAND=$2
BUILD=$1

printf "${YELLOW}Checking ${TICKET} (${PROJECT}), scheme: ${BRAND}, configuration: ${BUILD}${NC}\n"
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

TMP_SOURCE_FILE=$(mktemp -t ${TICKET})
# swap - to _ as this character is not allowed in env names
ENV_VAR="`echo ${TICKET} | sed 's/-/_/'`_APP"
echo "export ${ENV_VAR}=\"${APP_BUNDLE_PATH}\"" > $TMP_SOURCE_FILE
echo
printf "${YELLOW}Build at `date`${NC}\n\n"
printf "Found at: ${GREEN}${APP_BUNDLE_PATH}${NC}\n"
SOURCE_COMMAND=". ${TMP_SOURCE_FILE}"
echo $SOURCE_COMMAND | pbcopy
printf "\n\n${YELLOW}Source this file to get ${ENV_VAR} variable: '${SOURCE_COMMAND}'${NC}\n"
echo
