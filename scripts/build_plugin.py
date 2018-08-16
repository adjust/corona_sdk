import os, subprocess, sys
from scripting_utils import *

setLogTag('BUILD-PLUGIN')

## ------------------------------------------------------------------
## get arguments
if len(sys.argv) != 2:
	error('Error. Platform not provided.')
	debug('Usage >> python build-testapp.py [ios | android]\n')
	exit()

platform = sys.argv[1]
if platform != 'ios' and platform != 'android':
	error('Error. Unknown platform provided: [{0}]'.format(platform))
	debug('Usage >> python build-testapp.py [ios | android]\n')
	exit()	

debugGreen('Script start. Platform=[{0}]. Build Adjust SDK Corona Plugin ...'.format(platform))

## ------------------------------------------------------------------
## common paths
scriptDir 	= os.path.dirname(os.path.realpath(__file__))
rootDir 	= os.path.dirname(os.path.normpath(scriptDir))
version 	= open(rootDir + '/VERSION').read()
version 	= version[:-1] # remove end character
versionDir 	= '{0}/dist/{1}'.format(rootDir, version)
if not os.path.exists(versionDir):
		os.mkdir(versionDir)

def buildForAndroid():
	## ------------------------------------------------------------------
	## paths
	submoduleDir = '{0}/ext/android'.format(rootDir)
	androidRootDir = '{0}/plugin/android'.format(rootDir)
	androidPluginDir = '{0}/plugin/android/plugin'.format(rootDir)

	## ------------------------------------------------------------------
	## Build Corona plugin JAR library
	debugGreen('Building Corona plugin JAR library ...')
	os.chdir(androidRootDir)
	subprocess.call(['./gradlew', 'clean', 'assembleRelease'])
	subprocess.call(['./gradlew', 'exportPluginJar'])

	## ------------------------------------------------------------------
	## Copy Corona plugin JAR to dist folder into VERSION subfolder
	debugGreen('Copying Corona plugin JAR library to dist directory ...')
	copyFile(androidPluginDir + '/build/outputs/jar/plugin.adjust.jar', versionDir + '/plugin.adjust.jar')

	## ------------------------------------------------------------------
	## Script completed
	debugGreen('Script completed!')

def buildForiOS():
	## ------------------------------------------------------------------
	## paths
	submoduleDir 		= '{0}/ext/ios'.format(rootDir)
	pluginDir 			= '{0}/plugin/ios'.format(rootDir)
	pluginOutputDir 	= '{0}/build/Release-iphoneos'.format(pluginDir)
	staticFrameworkDir 	= '{0}/sdk/Frameworks/Static/AdjustSdk.framework'.format(submoduleDir)
	outputDir 			= '{0}/plugin/ios/Plugin'.format(rootDir)

	## ------------------------------------------------------------------
	## Generate static library and public header files needed for Plugin Xcode project
	debugGreen('Building AdjustSdk.framework as Relese target ...')
	os.chdir('{0}/sdk'.format(submoduleDir))
	subprocess.call(['xcodebuild', '-target', 'AdjustStatic', '-configuration', 'Release', 'clean', 'build'])
	
	## ------------------------------------------------------------------
	## Copy static library from generated framework to output directory
	debugGreen('Copying AdjustSdk.a from generated framework to output directory ...')
	copyFile(staticFrameworkDir + '/Versions/A/AdjustSdk', outputDir + '/AdjustSdk.a')

	## ------------------------------------------------------------------
	## Copy public headers from generated framework to output directory
	debugGreen('Copying headers from AdjustSdk.framework to output directory ...')
	copyFiles('*', staticFrameworkDir + '/Versions/A/Headers/', outputDir)

	## ------------------------------------------------------------------
	## Build static library of Corona SDK for iOS (libplugin_adjust.a)
	debugGreen('Building plugin_adjust target of the Plugin Xcode project ...')
	os.chdir(pluginDir)
	subprocess.call(['xcodebuild', '-target', 'plugin_adjust', '-project', 'Plugin.xcodeproj', '-configuration', 'Release', 'clean', 'build'])

	## ------------------------------------------------------------------
	## Copy Corona plugin static library to dist folder into VERSION subfolder
	debugGreen('Copying Corona plugin static library file to dist directory ...')
	copyFile(pluginOutputDir + '/libplugin_adjust.a', versionDir + '/libplugin_adjust.a')

	## ------------------------------------------------------------------
	## Script completed
	debugGreen('Script completed!')

## ------------------------------------------------------------------
## call platform specific build method
if platform == 'ios':
	buildForiOS()
else:
	buildForAndroid()
