#!/usr/bin/env bash

# End script if one of the lines fails
set -e

# Colours for output
NC='\033[0m'
RED='\033[0;31m'
CYAN='\033[1;36m'
GREEN='\033[0;32m'

# Get the current directory (scripts/)
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Traverse up to get to the root directory
ROOT_DIR="$(dirname "$ROOT_DIR")"

DIST_DIR=dist
SUBMODULE_DIR=ext/ios
PLUGIN_DIR=plugin/ios
PLUGIN_OUTPUT_DIR=build/Release-iphoneos
VERSION_DIR="$(cat ${ROOT_DIR}/VERSION)"

# Generate static library and public header files needed for Plugin Xcode project
echo -e "${CYAN}[ADJUST]:${GREEN} Invoking Corona iOS submodule build.sh script ... ${NC}"
cd ${ROOT_DIR}/${SUBMODULE_DIR}
./build.sh release

# Build static library of Corona SDK for iOS (libplugin_adjust.a)
echo -e "${CYAN}[ADJUST]:${GREEN} Building plugin_adjust target of Plugin Xcode project ... ${NC}"
cd ${ROOT_DIR}/${PLUGIN_DIR}
xcodebuild -target plugin_adjust -project Plugin.xcodeproj -configuration Release clean build

# Copy Corona plugin static library to dist folder into VERSION subfolder
echo -e "${CYAN}[ADJUST]:${GREEN} Copying Corona plugin .a file to dist directory ... ${NC}"
mkdir -p ${ROOT_DIR}/${DIST_DIR}/${VERSION_DIR}
cp -vf ${ROOT_DIR}/${PLUGIN_DIR}/${PLUGIN_OUTPUT_DIR}/libplugin_adjust.a ${ROOT_DIR}/${DIST_DIR}/${VERSION_DIR}/libplugin_adjust.a
echo -e "${CYAN}[ADJUST]:${GREEN} Done! ${NC}"

echo -e "${CYAN}[ADJUST]:${GREEN} END of make_corona_plugin_ios.sh script execution ${NC}"