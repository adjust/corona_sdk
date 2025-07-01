#!/bin/bash -e


PLUGIN="${1:-plugin.library}"
PUBLISHER="${1:-com.solar2d}"

path=$(cd "$(dirname "$0")"; pwd)

(
	set -e
	cd "$path"

	./build.sh
	cd BuiltPlugin

	for platform in *
	do
	    if [ "$platform" != "universal" ] && [ -d "$platform" ]
	    then
	    (
	        cd "$platform"
	        tarPath="$HOME/Solar2DPlugins/$PUBLISHER/$PLUGIN/$platform"
	        rm -rf "$tarPath"
	        mkdir -p "$tarPath"
	        COPYFILE_DISABLE=1 tar -czvf "$tarPath/data.tgz" -- * &> "$tarPath/$REV.txt" || echo "Errored on $PUBLISHER/$PLUGIN/$platform"
	    )
		fi
	done
)

echo
echo '== !!! IMPORTANT !!! =='
echo "Make sure to delete plugin when done: ~/Solar2DPlugins/$PUBLISHER/$PLUGIN"
echo "This plugin will override any Solar2Directory plugin, or plugin from any other source"
echo
