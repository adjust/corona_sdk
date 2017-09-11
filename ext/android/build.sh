#!/usr/bin/env bash

# End script if one of the lines fails
set -e

# Get the current directory (ext/android/)
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Traverse up to get to the root directory
ROOT_DIR="$(dirname "$ROOT_DIR")"
ROOT_DIR="$(dirname "$ROOT_DIR")"
ANDROID_SUBMODULE_DIR=ext/android
BUILD_DIR=sdk/Adjust
JAR_IN_DIR=adjust/build/outputs
JAR_OUT_DIR=ext/android/

RED='\033[0;31m' # Red color
GREEN='\033[0;32m' # Green color
NC='\033[0m' # No Color

echo -e "${GREEN}[*build.sh*] START ${NC}"

echo -e "${GREEN}[*build.sh*] Running Gradle tasks: clean makeJar ${NC}"
cd ${ROOT_DIR}/${ANDROID_SUBMODULE_DIR}/${BUILD_DIR}
./gradlew clean :adjust:makeJar

echo -e "${GREEN}[*build.sh*] Moving the jar from ${JAR_IN_DIR} to ${JAR_OUT_DIR} ${NC}"
mv -v ${JAR_IN_DIR}/*.jar ${ROOT_DIR}/${JAR_OUT_DIR}/adjust-android.jar

echo -e "${GREEN}[*build.sh*] DONE ${NC}"
