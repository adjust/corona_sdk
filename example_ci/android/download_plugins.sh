#!/usr/bin/env bash

BUILDER="${HOME}/Library/Application Support/Corona/Native/Corona/mac/bin/CoronaBuilder.app/Contents/MacOS/CoronaBuilder"
BUILD_SETTINGS="$(dirname "$0")/../Corona/build.settings"

if [[ ! -f ${BUILDER} ]]; then
	echo "Setu op Corona Native first by running /Applications/Corona/Native/Setup Corona Native.app"
	exit 1
fi

"${BUILDER}" plugins download android "${BUILD_SETTINGS}"
