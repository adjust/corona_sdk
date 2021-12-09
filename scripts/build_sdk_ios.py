from scripting_utils import *

def build_plugin(dir_root, dir_dist):
    ## ------------------------------------------------------------------
    ## Paths
    dir_submodule        = '{0}/ext/ios'.format(dir_root)
    dir_plugin           = '{0}/plugin/ios'.format(dir_root)
    dir_plugin_output    = '{0}/build/Release-iphoneos'.format(dir_plugin)
    dir_static_framework = '{0}/sdk/Frameworks/Static/AdjustSdk.framework'.format(dir_submodule)
    dir_output           = '{0}/plugin/ios/Plugin'.format(dir_root)

    ## ------------------------------------------------------------------
    ## Generate static library and public header files needed for Plugin Xcode project.
    debug_green('Building AdjustSdk.framework as Relese target ...')
    change_dir('{0}/sdk'.format(dir_submodule))
    xcode_build('AdjustStatic')
    
    ## ------------------------------------------------------------------
    ## Copy static library from generated framework to output directory.
    debug_green('Copying AdjustSdk.a from generated framework to output directory ...')
    copy_file(dir_static_framework + '/Versions/A/AdjustSdk', dir_output + '/AdjustSdk.a')

    ## ------------------------------------------------------------------
    ## Copy public headers from generated framework to output directory.
    debug_green('Copying headers from AdjustSdk.framework to output directory ...')
    copy_files('*', dir_static_framework + '/Versions/A/Headers/', dir_output)

    ## ------------------------------------------------------------------
    ## Build static library of Corona SDK for iOS (libplugin_adjust.a).
    debug_green('Building plugin_adjust target of the Plugin Xcode project ...')
    change_dir(dir_plugin)
    xcode_build_project('plugin_adjust', 'Plugin.xcodeproj')

    ## ------------------------------------------------------------------
    ## Copy Corona plugin static library to dist folder into VERSION subfolder.
    debug_green('Copying Corona plugin static library file to dist directory ...')
    copy_file(dir_plugin_output + '/libplugin_adjust.a', dir_dist + '/libplugin_adjust.a')

def build_app_example(dir_root):
    ## ------------------------------------------------------------------
    ## paths
    dir_adjust_sdk       = '{0}/ext/ios/sdk'.format(dir_root)
    dir_plugin           = '{0}/plugin/ios'.format(dir_root)
    dir_plugin_output    = '{0}/build/Release-iphoneos'.format(dir_plugin)
    dir_ios_app          = '{0}/plugin/ios'.format(dir_root)
    dir_output           = '{0}/Plugin'.format(dir_ios_app)
    dir_static_framework = '{0}/Frameworks/Static/AdjustSdk.framework'.format(dir_adjust_sdk)

    ## ------------------------------------------------------------------
    ## Generate static library and public header files.
    debug_green('Building AdjustSdk.framework as Relese target ...')
    change_dir(dir_adjust_sdk)
    xcode_build('AdjustStatic')

    ## ------------------------------------------------------------------
    ## Copy static library from generated framework to output directory.
    debug_green('Copying static library from generated framework to output directory ...')
    copy_file(dir_static_framework + '/Versions/A/AdjustSdk', dir_output + '/AdjustSdk.a')

    ## ------------------------------------------------------------------
    ## Copy public headers from generated framework to output directory.
    debug_green('Copying static library from generated framework to output directory ...')
    copy_files('*', dir_static_framework + '/Versions/A/Headers/', dir_output)

    ## ------------------------------------------------------------------
    ## Build static library of Corona SDK for iOS (libplugin_adjust.a).
    debug_green('Building static library of Corona SDK for iOS (libplugin_adjust.a) ...')
    change_dir(dir_plugin)
    xcode_build_project('plugin_adjust', 'Plugin.xcodeproj')

    ## ------------------------------------------------------------------
    ## Copy Corona plugin static library to example app dir.
    debug_green('Copying static library from generated framework to output directory (example app dir) ...')
    copy_file(dir_plugin_output + '/libplugin_adjust.a', dir_ios_app + '/libplugin_adjust.a')

    ## ------------------------------------------------------------------
    ## Script completed.
    debug_green('Open Xcode and run the example app project located in {0}/plugin/ios/App.xcodeproj'.format(dir_root))

def build_app_test(dir_root):
    ## ------------------------------------------------------------------
    ## paths
    dir_adjust_sdk          = '{0}/ext/ios/sdk'.format(dir_root)
    dir_adjust_sdk_test     = '{0}/ext/ios/sdk/AdjustTests/AdjustTestLibrary'.format(dir_root)
    dir_plugin              = '{0}/plugin/ios'.format(dir_root)
    dir_plugin_test         = '{0}/test/ios'.format(dir_root)
    dir_plugin_output       = '{0}/build/Release-iphoneos'.format(dir_plugin)
    dir_plugin_output_test  = '{0}/build/Release-iphoneos'.format(dir_plugin_test)
    dir_ios_app_test        = '{0}/test/ios'.format(dir_root)
    dir_output              = '{0}/plugin/ios/Plugin'.format(dir_root)
    dir_output_test         = '{0}/test/ios/Plugin'.format(dir_root)
    dir_static_framework    = '{0}/frameworks/static/AdjustSdk.framework'.format(dir_adjust_sdk)
    dir_static_framework_test_lib       = '{0}/build/Debug-iphoneos'.format(dir_adjust_sdk_test)
    dir_static_framework_test_headers   = '{0}/build/Debug-iphoneos/Static/AdjustTestLibrary.framework'.format(dir_adjust_sdk_test)

    ## ------------------------------------------------------------------
    ## Generate static library and public header files.
    debug_green('Building AdjustSdk.framework as Release target ...')
    change_dir(dir_adjust_sdk)
    xcode_build('AdjustStatic')

    ## ------------------------------------------------------------------
    ## Copy static library from generated framework to output directory.
    debug_green('Copying static library from generated framework to output directory ...')
    copy_file(dir_static_framework + '/Versions/A/AdjustSdk', dir_output + '/AdjustSdk.a')

    ## ------------------------------------------------------------------
    ## Copy public headers from generated framework to output directory.
    debug_green('Copying static library from generated framework to output directory ...')
    copy_files('*', dir_static_framework + '/Versions/A/Headers/', dir_output)

    ## ------------------------------------------------------------------
    ## Build static library of Corona SDK for iOS (libplugin_adjust.a).
    debug_green('Building static library of Corona SDK for iOS (libplugin_adjust.a) ...')
    change_dir(dir_plugin)
    xcode_build_project('plugin_adjust', 'Plugin.xcodeproj')

    ## ------------------------------------------------------------------
    ## Copy Corona plugin static library to test app dir.
    debug_green('Copying static library from generated framework to output directory (test app dir) ...')
    copy_file(dir_plugin_output + '/libplugin_adjust.a', dir_ios_app_test + '/libplugin_adjust.a')

    ## Generate static test library and public header files.
    debug_green('Building AdjustTestLibrary.framework as Debug target ...')
    change_dir(dir_adjust_sdk_test)
    xcode_build('AdjustTestLibrary', 'Debug')

    ## ------------------------------------------------------------------
    ## Copy static test library from generated framework to output directory.
    debug_green('Copying static test library from generated framework to output directory ...')
    copy_file(dir_static_framework_test_lib + '/libAdjustTestLibrary.a', dir_output_test + '/AdjustTestLibrary.a')

    ## ------------------------------------------------------------------
    ## Copy public headers from generated framework to output directory.
    debug_green('Copying static test library from generated framework to output directory ...')
    copy_files('*', dir_static_framework_test_headers + '/Versions/A/Headers/', dir_output_test)

    ## ------------------------------------------------------------------
    ## Build static test library of Corona SDK for iOS (libplugin_library.a).
    debug_green('Building static library of Corona SDK for iOS (libplugin_library.a) ...')
    change_dir(dir_plugin_test)
    xcode_build_project('plugin_library', 'Plugin.xcodeproj')

    ## ------------------------------------------------------------------
    ## Copy Corona plugin static library to test app dir.
    debug_green('Copying static library from generated framework to output directory (test app dir) ...')
    copy_file(dir_plugin_output_test + '/libplugin_library.a', dir_ios_app_test + '/libplugin_library.a')

    ## ------------------------------------------------------------------
    ## Script completed.
    debug_green('Open Xcode and run the test app project located in {0}/test/ios/App.xcodeproj'.format(dir_root))
