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
SDK_SRC_DIR=ext/ios/sdk
PLUGIN_DIR=plugin/ios
PLUGIN_OUTPUT_DIR=build/Release-iphoneos
TESTAPP_DIR=test/ios
OUTPUT_DIR=${TESTAPP_DIR}/Plugin
STATIC_FRAMEWORK_DIR=$SDK_SRC_DIR/Frameworks/Static/AdjustSdk.framework

# ======================================== #

# Generate static library and public header files needed for Plugin Xcode project
echo -e "${CYAN}[ADJUST][IOS][BUILD-SDK]:${GREEN} Building AdjustSdk.framework as Relese target ... ${NC}"
cd ${ROOT_DIR}/${SDK_SRC_DIR}
xcodebuild -target AdjustStatic -configuration Release clean build
echo -e "${CYAN}[ADJUST][IOS][BUILD-SDK]:${GREEN} Done! ${NC}"

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

# Build static library of Corona SDK for iOS (libplugin_adjust.a)
echo -e "${CYAN}[ADJUST][IOS][BUILD-PLUGIN]:${GREEN} Building plugin_adjust target of the Plugin Xcode project ... ${NC}"
cd ${ROOT_DIR}/${PLUGIN_DIR}
xcodebuild -target plugin_adjust -project Plugin.xcodeproj -configuration Release clean build
echo -e "${CYAN}[ADJUST][IOS][BUILD-PLUGIN]:${GREEN} Done! ${NC}"

# ======================================== #

# Copy Corona plugin static library to dist folder into VERSION subfolder
echo -e "${CYAN}[ADJUST][IOS][BUILD-PLUGIN]:${GREEN} Copying Corona plugin static library file to test/ios/ directory ... ${NC}"
cp -vf ${ROOT_DIR}/${PLUGIN_DIR}/${PLUGIN_OUTPUT_DIR}/libplugin_adjust.a ${ROOT_DIR}/${TESTAPP_DIR}/libplugin_adjust.a
echo -e "${CYAN}[ADJUST][IOS][BUILD-PLUGIN]:${GREEN} Done! ${NC}"

# ======================================== #

echo -e "${CYAN}[ADJUST][IOS][BUILD-PLUGIN]:${GREEN} Script completed! ${NC}"
echo -e "${CYAN}[ADJUST][IOS][BUILD-PLUGIN]:${GREEN} Open Xcode and run the TestApp project located in ${ROOT_DIR}/test/ios/App.xcodeproj ${NC}"
