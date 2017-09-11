#!/usr/bin/env bash

# End script if one of the lines fails
set -e

# Get the current directory (ext/android/)
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Traverse up to get to the root directory
ROOT_DIR="$(dirname "$ROOT_DIR")"
ROOT_DIR="$(dirname "$ROOT_DIR")"
IOS_SUBMODULE_DIR=ext/ios
FRAMEWORK_IN_DIR=sdk/build/Release-iphoneos/Static
FRAMEWORK_OUT_DIR=Frameworks/Static

RED='\033[0;31m' # Red color
GREEN='\033[0;32m' # Green color
NC='\033[0m' # No Color

echo -e "${GREEN}[*build.sh*] START ${NC}"
cd ${ROOT_DIR}/${IOS_SUBMODULE_DIR}

# Clean the folders
echo -e "${GREEN}[*build.sh*] Cleaning <${FRAMEWORK_OUT_DIR}> directory ${NC}"
rm -rf ${FRAMEWORK_OUT_DIR}

# Create needed folders
mkdir -p ${FRAMEWORK_OUT_DIR}

echo -e "${GREEN}[*build.sh*] Running xcodebuild ${NC}"
cd ${ROOT_DIR}/${IOS_SUBMODULE_DIR}/sdk
xcodebuild -target AdjustStatic -configuration Release clean build

echo -e "${GREEN}[*build.sh*] Moving the framework from ${FRAMEWORK_IN_DIR} to ${FRAMEWORK_OUT_DIR} ${NC}"
cd ${ROOT_DIR}/${IOS_SUBMODULE_DIR}
mv -v ${FRAMEWORK_IN_DIR}/*.framework ${ROOT_DIR}/${IOS_SUBMODULE_DIR}/${FRAMEWORK_OUT_DIR}/AdjustSdk.framework

echo -e "${GREEN}[*build.sh*] DONE ${NC}"
