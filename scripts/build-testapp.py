import os, subprocess, sys
from scriptingUtils import *

setLogTag('TEST-APP')

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

debugGreen('Script start. Platform=[{0}]. Update test app Adjust SDK and Adjust SDK Corona Plugin ...'.format(platform))

## ------------------------------------------------------------------
## common paths
scriptDir 		  = os.path.dirname(os.path.realpath(__file__))
rootDir 		  = os.path.dirname(os.path.normpath(scriptDir))

def buildForAndroid():
	## ------------------------------------------------------------------
	## paths
	androidTestAppDir = '{0}/test/android/app'.format(rootDir)
	androidPluginDir  = '{0}/plugin/android'.format(rootDir)
	adjustSdkDir 	  = '{0}/ext/android/sdk/Adjust'.format(rootDir)
	jarInDir 		  = '{0}/target'.format(adjustSdkDir)
	jarOutDir 		  = '{0}/libs'.format(androidTestAppDir)

	## ------------------------------------------------------------------
	## remove current JARs
	debugGreen('Remove current JARs ...')
	clearDir(jarOutDir)

	## ------------------------------------------------------------------
	## build Adjust SDK JAR
	debugGreen('Building Adjust SDK JAR ...')
	os.chdir(adjustSdkDir) # change dir to adjustSdkDir
	subprocess.call(['mvn', 'clean'])
	subprocess.call(['mvn', 'package'])

	## ------------------------------------------------------------------
	## copy Adjust SDK JAR
	debugGreen('Copy Adjust SDK JAR ...')
	copyFiles('adjust-android-*.*.*.jar', jarInDir, jarOutDir)
	removeFiles('*-javadoc.jar', jarOutDir)
	removeFiles('*-sources.jar', jarOutDir)
	renameFile('adjust-android-*.*.*.jar', 'adjust-android.jar', jarOutDir)

	## ------------------------------------------------------------------
	## build Adjust Corona Plugin JAR
	debugGreen('Building Adjust Corona Plugin JAR ...')
	os.chdir(androidPluginDir)
	subprocess.call(['./gradlew', 'clean', 'assembleRelease'])
	subprocess.call(['./gradlew', 'exportPluginJar'])

	## ------------------------------------------------------------------
	## copy Adjust SDK JAR
	debugGreen('Copy Adjust Corona Plugin JAR ...')
	copyFiles('plugin.adjust.jar', androidPluginDir + '/plugin/build/outputs/jar', jarOutDir)

	## ------------------------------------------------------------------
	## Script completed
	debugGreen('Script completed!')
	debugGreen('Open Android Studio and run the TestApp project located in {0}/test/android'.format(rootDir))

def buildForiOS():
	## ------------------------------------------------------------------
	## paths
	adjustSdkDir 	   = '{0}/ext/ios/sdk'.format(rootDir)
	pluginDir 		   = '{0}/plugin/ios'.format(rootDir)
	pluginOutputDir    = '{0}/build/Release-iphoneos'.format(pluginDir)
	iosTestAppDir 	   = '{0}/test/ios'.format(rootDir)
	outputDir 		   = '{0}/Plugin'.format(iosTestAppDir)
	staticFrameworkDir = '{0}/Frameworks/Static/AdjustSdk.framework'.format(adjustSdkDir)

	## ------------------------------------------------------------------
	## generate static library and public header files
	debugGreen('Building AdjustSdk.framework as Relese target ...')
	os.chdir(adjustSdkDir)
	subprocess.call(['xcodebuild', '-target', 'AdjustStatic', '-configuration', 'Release', 'clean', 'build'])

	## ------------------------------------------------------------------
	## copy static library from generated framework to output directory
	debugGreen('Copying static library from generated framework to output directory ...')
	copyFile(staticFrameworkDir + '/Versions/A/AdjustSdk', outputDir + '/AdjustSdk.a')

	## ------------------------------------------------------------------
	## copy public headers from generated framework to output directory
	debugGreen('Copying static library from generated framework to output directory ...')
	copyFiles('*', staticFrameworkDir + '/Versions/A/Headers/', outputDir)

	## ------------------------------------------------------------------
	## build static library of Corona SDK for iOS (libplugin_adjust.a)
	debugGreen('Building static library of Corona SDK for iOS (libplugin_adjust.a) ...')
	os.chdir(pluginDir)
	subprocess.call(['xcodebuild', '-target', 'plugin_adjust', '-project', 'Plugin.xcodeproj', '-configuration', 'Release', 'clean', 'build'])

	## ------------------------------------------------------------------
	## copy Corona plugin static library to test app dir
	debugGreen('Copying static library from generated framework to output directory (test app dir) ...')
	copyFile(pluginOutputDir + '/libplugin_adjust.a', iosTestAppDir + '/libplugin_adjust.a')

	## ------------------------------------------------------------------
	## Script completed
	debugGreen('Script completed!')
	debugGreen('Open Xcode and run the TestApp project located in {0}/test/ios/App.xcodeproj'.format(rootDir))

## ------------------------------------------------------------------
## call platform specific build method
if platform == 'ios':
	buildForiOS()
else:
	buildForAndroid()
