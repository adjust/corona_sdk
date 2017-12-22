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
SCRIPTS_DIR=scripts
ANDROID_SUBMODULE_DIR=ext/android
ANDROID_ROOT_DIR=plugin/android
ANDROID_PLUGIN_DIR=plugin/android/plugin
VERSION_DIR="$(cat ${ROOT_DIR}/VERSION)"

echo -e "${CYAN}[ADJUST]:${GREEN} START of Corona make_corona_plugin_jar.sh script ${NC}"

# Build Corona plugin JAR library
echo -e "${CYAN}[ADJUST]:${GREEN} Building Corona plugin JAR ... ${NC}"
cd ${ROOT_DIR}/${ANDROID_ROOT_DIR}
./gradlew clean assembleRelease
./gradlew exportPluginJar
echo -e "${CYAN}[ADJUST]:${GREEN} Done! ${NC}"

# Copy Corona plugin JAR to dist folder into VERSION subfolder
echo -e "${CYAN}[ADJUST]:${GREEN} Copying Corona plugin JAR file to dist directory ... ${NC}"
mkdir -p ${ROOT_DIR}/${DIST_DIR}/${VERSION_DIR}
cp -vf ${ROOT_DIR}/${ANDROID_PLUGIN_DIR}/build/outputs/jar/plugin.adjust.jar ${ROOT_DIR}/${DIST_DIR}/${VERSION_DIR}/plugin.adjust.jar
echo -e "${CYAN}[ADJUST]:${GREEN} Done! ${NC}"

echo -e "${CYAN}[ADJUST]:${GREEN} END of make_corona_plugin_android.sh script execution ${NC}"
