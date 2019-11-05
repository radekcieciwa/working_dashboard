#!/usr/bin/env bash
#

function usage() {
  echo "Usage: $0 <jira ticket> <brand>"
}

if [ "$#" -ne 2 ]; then
    usage
    exit 1
fi

PROJET="$TICKETS_WORKSPACE_DIR/$1"
BRAND=$2
BUILD="Calabash"

echo "Starting build on $PROJET/Dev.xcworkspace, scheme: $BRAND, configuration: $BUILD"
echo

xcodebuild \
  -workspace "$PROJET/Dev.xcworkspace" \
  -scheme $BRAND \
  -configuration $BUILD \
  -sdk iphonesimulator \
  build

APP_BUNDLE_PATH=$(\
    xcodebuild \
    -workspace "$PROJET/Dev.xcworkspace" \
    -scheme $BRAND \
    -configuration $BUILD \
    -sdk iphonesimulator \
    -showBuildSettings \
    | awk '/CODESIGNING_FOLDER_PATH/ { print $3 }' \
    | grep .app \
)

echo

# Color changes: https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
GREEN='\033[0;32m'
NC='\033[0m'
printf "Found app at: ${GREEN}${APP_BUNDLE_PATH}${NC}"
echo

# Consider zipping, or copying as zip?
# echo "Exporting..."
# export APP_BUNDLE_PATH

# ZIP_FILE="${BRAND}_${BUILD}_${1}.zip"
# echo "zippin $APP_BUNDLE_PATH into $ZIP_FILE"
# zip $ZIP_FILE $APP_BUNDLE_PATH
# if [ $? -eq 0 ]; then
# echo "zipped binary to: $ZIP_FILE"
# fi

echo
