#!/usr/bin/env bash

# End script if one of the lines fails
set -e

# Get the current directory (scripts/)
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Traverse up to get to the root directory
ROOT_DIR="$(dirname "$ROOT_DIR")"

SCRIPTS_DIR=scripts
ANDROID_SUBMODULE_DIR=ext/android
ANDROID_PLUGIN_DIR=plugin/android/plugin

RED='\033[0;31m' # Red color
GREEN='\033[0;32m' # Green color
NC='\033[0m' # No Color

echo -e "${GREEN}[*] START ${NC}"

echo -e "${GREEN}[*] Build JAR ${NC}"
cd ${ROOT_DIR}/${ANDROID_SUBMODULE_DIR}
./build.sh

echo -e "${GREEN}[*] Copy JAR file to project ${NC}"
cd ${ROOT_DIR}/${ANDROID_PLUGIN_DIR}

cp -vf ${ROOT_DIR}/${ANDROID_SUBMODULE_DIR}/adjust-android.jar ${ROOT_DIR}/${ANDROID_PLUGIN_DIR}/libs

echo -e "${GREEN}[*] DONE ${NC}"
