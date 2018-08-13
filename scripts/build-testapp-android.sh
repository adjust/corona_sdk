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
ANDROID_PLUGIN_ROOT_DIR=plugin/android
ANDROID_APP_DIR=test/android/app
ADJUST_SDK_DIR=$ROOT_DIR/ext/android/sdk/Adjust
JARINDIR=$ADJUST_SDK_DIR/target
JAROUTDIR=$ROOT_DIR/$ANDROID_APP_DIR/libs

# ======================================== #

# Remove current JARs
echo -e "${CYAN}[TEST-APP][ANDROID][TEST-APP]:${GREEN} Remove current JARs ... ${NC}"
rm -rf $JAROUTDIR/*

# ======================================== #

echo -e "${CYAN}[TEST-APP][ANDROID][BUILD-SDK]:${GREEN} Initiate MVN clean & MVN package ... ${NC}"

(cd $ADJUST_SDK_DIR; mvn clean)
(cd $ADJUST_SDK_DIR; mvn package)

# ======================================== #

# Build Adjust SDK
echo -e "${CYAN}[TEST-APP][ANDROID][BUILD-SDK]:${GREEN} Building Adjust JAR library ... ${NC}"
cp -v $JARINDIR/adjust-android-*.*.*.jar $JAROUTDIR
rm -v $JAROUTDIR/*-javadoc.jar
rm -v $JAROUTDIR/*-sources.jar
mv -v $JAROUTDIR/adjust-android-*.*.*.jar $JAROUTDIR/adjust-android.jar
echo -e "${CYAN}[TEST-APP][ANDROID][BUILD-SDK]:${GREEN} Done! ${NC}"

# ======================================== #

# Build Corona plugin JAR library
echo -e "${CYAN}[ADJUST][ANDROID][BUILD-PLUGIN]:${GREEN} Building Corona plugin JAR library ... ${NC}"
cd ${ROOT_DIR}/${ANDROID_PLUGIN_ROOT_DIR}
./gradlew clean assembleRelease
./gradlew exportPluginJar
echo -e "${CYAN}[ADJUST][ANDROID][BUILD-PLUGIN]:${GREEN} Done! ${NC}"

# ======================================== #

# Copy Corona plugin JAR to ...test/android/app/libs
echo -e "${CYAN}[ADJUST][ANDROID][BUILD-PLUGIN]:${GREEN} Copying Corona plugin JAR library to dist directory ... ${NC}"
cp -vf ${ROOT_DIR}/${ANDROID_PLUGIN_ROOT_DIR}/plugin/build/outputs/jar/plugin.adjust.jar ${ROOT_DIR}/${ANDROID_APP_DIR}/libs/plugin.adjust.jar
echo -e "${CYAN}[ADJUST][ANDROID][BUILD-PLUGIN]:${GREEN} Done! ${NC}"

# ======================================== #

echo -e "${CYAN}[ADJUST][ANDROID][BUILD-PLUGIN]:${GREEN} Script completed! ${NC}"
echo -e "${CYAN}[ADJUST][ANDROID][BUILD-PLUGIN]:${GREEN} Open Android Studio and run the TestApp project located in ${ROOT_DIR}/test/android ${NC}"
