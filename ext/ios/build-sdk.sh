#!/usr/bin/env bash

set -e

# ======================================== #

# Colors for output
NC='\033[0m'
RED='\033[0;31m'
CYAN='\033[1;36m'
GREEN='\033[0;32m'

# ======================================== #

# Usage hint in case of wrong invocation.
if [ $# -ne 1 ]; then
    echo -e "${CYAN}[ADJUST][IOS][BUILD-SDK]:${RED} Usage: ./build.sh [debug || release] ${NC}"
    exit 1
fi

BUILD_TYPE=$1

# ======================================== #

# Directories and paths of interest for the script.
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$ROOT_DIR")"
ROOT_DIR="$(dirname "$ROOT_DIR")"
SDK_SRC_DIR=ext/ios/sdk
OUTPUT_DIR=plugin/ios/Plugin
STATIC_FRAMEWORK_DIR=$SDK_SRC_DIR/Frameworks/Static/AdjustSdk.framework

# ======================================== #

# Build static framework
cd ${ROOT_DIR}/${SDK_SRC_DIR}

if [ "$BUILD_TYPE" == "debug" ]; then
	echo -e "${CYAN}[ADJUST][IOS][BUILD-SDK]:${GREEN} Building AdjustSdk.framework as Debug target ... ${NC}"
	xcodebuild -target AdjustStatic -configuration Debug clean build
	echo -e "${CYAN}[ADJUST][IOS][BUILD-SDK]:${GREEN} Done! ${NC}"
elif [ "$BUILD_TYPE" == "release" ]; then
	echo -e "${CYAN}[ADJUST][IOS][BUILD-SDK]:${GREEN} Building AdjustSdk.framework as Relese target ... ${NC}"
	xcodebuild -target AdjustStatic -configuration Release clean build
	echo -e "${CYAN}[ADJUST][IOS][BUILD-SDK]:${GREEN} Done! ${NC}"
fi

# ======================================== #

# Copy static library from generated framework to output directory
echo -e "${CYAN}[ADJUST][IOS][BUILD-SDK]:${GREEN} Copying AdjustSdk.a from generated framework to output directory ... ${NC}"
cp -v ${ROOT_DIR}/${STATIC_FRAMEWORK_DIR}/Versions/A/AdjustSdk ${ROOT_DIR}/${OUTPUT_DIR}/AdjustSdk.a
echo -e "${CYAN}[ADJUST][IOS][BUILD-SDK]:${GREEN} Done! ${NC}"

# ======================================== #

# Copy public headers from generated framework to output directory
echo -e "${CYAN}[ADJUST][IOS][BUILD-SDK]:${GREEN} Copying headers from AdjustSdk.framework to output directory ... ${NC}"
cp -v ${ROOT_DIR}/${STATIC_FRAMEWORK_DIR}/Versions/A/Headers/* ${ROOT_DIR}/${OUTPUT_DIR}
echo -e "${CYAN}[ADJUST][IOS][BUILD-SDK]:${GREEN} Done! ${NC}"

# ======================================== #

echo -e "${CYAN}[ADJUST][IOS][BUILD-SDK]:${GREEN} Script completed! ${NC}"
