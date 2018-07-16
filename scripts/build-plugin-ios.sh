#!/usr/bin/env bash

set -e

# ======================================== #

# Colors for output
NC='\033[0m'
RED='\033[0;31m'
CYAN='\033[1;36m'
GREEN='\033[0;32m'

# ======================================== #

# Directories and paths of interest for the script.
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$ROOT_DIR")"
DIST_DIR=dist
SUBMODULE_DIR=ext/ios
PLUGIN_DIR=plugin/ios
PLUGIN_OUTPUT_DIR=build/Release-iphoneos
VERSION_DIR="$(cat ${ROOT_DIR}/VERSION)"

# ======================================== #

# Generate static library and public header files needed for Plugin Xcode project
echo -e "${CYAN}[ADJUST][IOS][BUILD-PLUGIN]:${GREEN} Invoking Corona iOS submodule build-sdk.sh script ... ${NC}"
cd ${ROOT_DIR}/${SUBMODULE_DIR}
./build-sdk.sh release
echo -e "${CYAN}[ADJUST][IOS][BUILD-PLUGIN]:${GREEN} Done! ${NC}"

# ======================================== #

# Build static library of Corona SDK for iOS (libplugin_adjust.a)
echo -e "${CYAN}[ADJUST][IOS][BUILD-PLUGIN]:${GREEN} Building plugin_adjust target of the Plugin Xcode project ... ${NC}"
cd ${ROOT_DIR}/${PLUGIN_DIR}
xcodebuild -target plugin_adjust -project Plugin.xcodeproj -configuration Release clean build
echo -e "${CYAN}[ADJUST][IOS][BUILD-PLUGIN]:${GREEN} Done! ${NC}"

# ======================================== #

# Copy Corona plugin static library to dist folder into VERSION subfolder
echo -e "${CYAN}[ADJUST][IOS][BUILD-PLUGIN]:${GREEN} Copying Corona plugin static library file to dist directory ... ${NC}"
mkdir -p ${ROOT_DIR}/${DIST_DIR}/${VERSION_DIR}
cp -vf ${ROOT_DIR}/${PLUGIN_DIR}/${PLUGIN_OUTPUT_DIR}/libplugin_adjust.a ${ROOT_DIR}/${DIST_DIR}/${VERSION_DIR}/libplugin_adjust.a
echo -e "${CYAN}[ADJUST][IOS][BUILD-PLUGIN]:${GREEN} Done! ${NC}"

# ======================================== #

echo -e "${CYAN}[ADJUST][IOS][BUILD-PLUGIN]:${GREEN} Script completed! ${NC}"