#!/usr/bin/env bash

# End script if one of the lines fails
set -e

# Get the current directory (scripts/)
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Traverse up to get to the root directory
ROOT_DIR="$(dirname "$ROOT_DIR")"

SCRIPTS_DIR=scripts
IOS_SUBMODULE_DIR=ext/ios
FRAMEWORK_DIR=Frameworks/Static
HEADER_OUT_DIR=plugin/ios/Plugin

RED='\033[0;31m' # Red color
GREEN='\033[0;32m' # Green color
NC='\033[0m' # No Color

echo -e "${GREEN}[*] START ${NC}"

echo -e "${GREEN}[*] Building framework ${NC}"
cd ${ROOT_DIR}/${IOS_SUBMODULE_DIR}
./build.sh

echo -e "${GREEN}[*] Copy headers from framework ${NC}"
cd ${ROOT_DIR}/${IOS_SUBMODULE_DIR}/${FRAMEWORK_DIR}
cp -v AdjustSdk.framework/Versions/A/Headers/* ${ROOT_DIR}/${HEADER_OUT_DIR}

echo -e "${GREEN}[*] Copy static library ${NC}"
cd ${ROOT_DIR}/${IOS_SUBMODULE_DIR}/${FRAMEWORK_DIR}
cp -v AdjustSdk.framework/Versions/A/AdjustSdk ${ROOT_DIR}/${HEADER_OUT_DIR}/AdjustSdk.a

echo -e "${GREEN}[*] DONE ${NC}"
