#!/bin/bash
set -e

root="$(cd "$(dirname "$0")"; pwd)"

(
	cd "$root/../dist_directory"
	git checkout --force master
	git pull --quiet --force --tags
)

(
	cd "$root/android"
	./gradlew :plugin:extractPluginJar
)

(
	cd "$root/ios"
	./build.sh
)

(
	BUILD=2017.3183
	cd "$root"
	rm -rf ../dist_directory/plugins/$BUILD/iphone ../dist_directory/plugins/$BUILD/iphone-sim
	cp -r ios/BuiltPlugin/iphone ios/BuiltPlugin/iphone-sim ../dist_directory/plugins/$BUILD
	rm -f ../dist_directory/plugins/$BUILD/android/plugin.adjust.jar
	cp android/plugin/build/outputs/plugin.adjust.jar ../dist_directory/plugins/$BUILD/android/
)
