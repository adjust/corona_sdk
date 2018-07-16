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
SCRIPTS_DIR=scripts
ANDROID_SUBMODULE_DIR=ext/android
ANDROID_ROOT_DIR=plugin/android
ANDROID_PLUGIN_DIR=plugin/android/plugin
VERSION_DIR="$(cat ${ROOT_DIR}/VERSION)"

# ======================================== #

# Build Corona plugin JAR library
echo -e "${CYAN}[ADJUST][ANDROID][BUILD-PLUGIN]:${GREEN} Building Corona plugin JAR library ... ${NC}"
cd ${ROOT_DIR}/${ANDROID_ROOT_DIR}
./gradlew clean assembleRelease
./gradlew exportPluginJar
echo -e "${CYAN}[ADJUST][ANDROID][BUILD-PLUGIN]:${GREEN} Done! ${NC}"

# ======================================== #

# Copy Corona plugin JAR to dist folder into VERSION subfolder
echo -e "${CYAN}[ADJUST][ANDROID][BUILD-PLUGIN]:${GREEN} Copying Corona plugin JAR library to dist directory ... ${NC}"
mkdir -p ${ROOT_DIR}/${DIST_DIR}/${VERSION_DIR}
cp -vf ${ROOT_DIR}/${ANDROID_PLUGIN_DIR}/build/outputs/jar/plugin.adjust.jar ${ROOT_DIR}/${DIST_DIR}/${VERSION_DIR}/plugin.adjust.jar
echo -e "${CYAN}[ADJUST][ANDROID][BUILD-PLUGIN]:${GREEN} Done! ${NC}"

# ======================================== #

echo -e "${CYAN}[ADJUST][ANDROID][BUILD-PLUGIN]:${GREEN} Script completed! ${NC}"
