#!/usr/bin/env bash

# End script if one of the lines fails
set -e

# Colours for output
NC='\033[0m'
RED='\033[0;31m'
CYAN='\033[1;36m'
GREEN='\033[0;32m'

# Validate number of input parameters
if [ $# -ne 1 ]; then
    echo -e "${CYAN}[ADJUST]:${RED} Missing parameter (./build.sh [debug || release])"
    echo -e "${CYAN}[ADJUST]:${RED} Script execution aborted ${NC}"
    exit 1
fi

# Validate input parameter value
if [[ "$1" == "debug" ]] || [[ "$1" == "release" ]]
then
	BUILD_TYPE=$1
else
	echo -e "${CYAN}[ADJUST]:${RED} Wrong parameter '$1' (./build.sh [debug || release])"
    echo -e "${CYAN}[ADJUST]:${RED} Script execution aborted ${NC}"
    exit 1
fi

# Get the current directory (ext/ios)
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Traverse up to get to the root directory
ROOT_DIR="$(dirname "$ROOT_DIR")"
ROOT_DIR="$(dirname "$ROOT_DIR")"

# iOS SDK submodule root directory
SDK_SRC_DIR=ext/ios/sdk

# Output directory where static library and header files will be copied to.
OUTPUT_DIR=plugin/ios/Plugin

# Path in which static framework will be generated.
STATIC_FRAMEWORK_DIR=$SDK_SRC_DIR/Frameworks/Static/AdjustSdk.framework

echo -e "${CYAN}[ADJUST]:${GREEN} START of Corona iOS submodule build.sh script ${NC}"

# Build static framework
echo -e "${CYAN}[ADJUST]:${GREEN} Building static framework ... ${NC}"
cd ${ROOT_DIR}/${SDK_SRC_DIR}

if [ "$BUILD_TYPE" == "debug" ]; then
	xcodebuild -target AdjustStatic -configuration Debug clean build
elif [ "$BUILD_TYPE" == "release" ]; then
	xcodebuild -target AdjustStatic -configuration Release clean build
fi
echo -e "${CYAN}[ADJUST]:${GREEN} Done! ${NC}"

# Copy static library from generated framework to output directory
echo -e "${CYAN}[ADJUST]:${GREEN} Copying static library from generated framework to output directory ... ${NC}"
cp -v ${ROOT_DIR}/${STATIC_FRAMEWORK_DIR}/Versions/A/AdjustSdk ${ROOT_DIR}/${OUTPUT_DIR}/AdjustSdk.a
echo -e "${CYAN}[ADJUST]:${GREEN} Done! ${NC}"

# Copy public headers from generated framework to output directory
echo -e "${CYAN}[ADJUST]:${GREEN} Copying headers from generated framework to output directory ... ${NC}"
cp -v ${ROOT_DIR}/${STATIC_FRAMEWORK_DIR}/Versions/A/Headers/* ${ROOT_DIR}/${OUTPUT_DIR}
echo -e "${CYAN}[ADJUST]:${GREEN} Done! ${NC}"

echo -e "${CYAN}[ADJUST]:${GREEN} END of Corona iOS submodule build.sh script execution ${NC}"
