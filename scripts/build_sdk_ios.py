from scripting_utils import *

def build_plugin(root_dir, dist_dir):
    ## ------------------------------------------------------------------
    ## paths
    submodule_dir        = '{0}/ext/ios'.format(root_dir)
    plugin_dir           = '{0}/plugin/ios'.format(root_dir)
    plugin_output_dir    = '{0}/build/Release-iphoneos'.format(plugin_dir)
    static_framework_dir = '{0}/sdk/Frameworks/Static/AdjustSdk.framework'.format(submodule_dir)
    output_dir           = '{0}/plugin/ios/Plugin'.format(root_dir)

    ## ------------------------------------------------------------------
    ## Generate static library and public header files needed for Plugin Xcode project
    debug_green('Building AdjustSdk.framework as Relese target ...')
    change_dir(submodule_dir)
    xcode_build('AdjustStatic')
    
    ## ------------------------------------------------------------------
    ## Copy static library from generated framework to output directory
    debug_green('Copying AdjustSdk.a from generated framework to output directory ...')
    copy_file(static_framework_dir + '/Versions/A/AdjustSdk', output_dir + '/AdjustSdk.a')

    ## ------------------------------------------------------------------
    ## Copy public headers from generated framework to output directory
    debug_green('Copying headers from AdjustSdk.framework to output directory ...')
    copy_files('*', static_framework_dir + '/Versions/A/Headers/', output_dir)

    ## ------------------------------------------------------------------
    ## Build static library of Corona SDK for iOS (libplugin_adjust.a)
    debug_green('Building plugin_adjust target of the Plugin Xcode project ...')
    change_dir(plugin_dir)
    xcode_build_project('plugin_adjust', 'Plugin.xcodeproj')

    ## ------------------------------------------------------------------
    ## Copy Corona plugin static library to dist folder into VERSION subfolder
    debug_green('Copying Corona plugin static library file to dist directory ...')
    copy_file(plugin_output_dir + '/libplugin_adjust.a', dist_dir + '/libplugin_adjust.a')

def build_testapp(root_dir):
    ## ------------------------------------------------------------------
    ## paths
    adjust_sdk_dir       = '{0}/ext/ios/sdk'.format(root_dir)
    plugin_dir           = '{0}/plugin/ios'.format(root_dir)
    plugin_output_dir    = '{0}/build/Release-iphoneos'.format(plugin_dir)
    ios_test_app_dir     = '{0}/test/ios'.format(root_dir)
    output_dir           = '{0}/Plugin'.format(ios_test_app_dir)
    static_framework_dir = '{0}/Frameworks/Static/AdjustSdk.framework'.format(adjust_sdk_dir)

    ## ------------------------------------------------------------------
    ## generate static library and public header files
    debug_green('Building AdjustSdk.framework as Relese target ...')
    change_dir(adjust_sdk_dir)
    xcode_build('AdjustStatic')

    ## ------------------------------------------------------------------
    ## copy static library from generated framework to output directory
    debug_green('Copying static library from generated framework to output directory ...')
    copy_file(static_framework_dir + '/Versions/A/AdjustSdk', output_dir + '/AdjustSdk.a')

    ## ------------------------------------------------------------------
    ## copy public headers from generated framework to output directory
    debug_green('Copying static library from generated framework to output directory ...')
    copy_files('*', static_framework_dir + '/Versions/A/Headers/', output_dir)

    ## ------------------------------------------------------------------
    ## build static library of Corona SDK for iOS (libplugin_adjust.a)
    debug_green('Building static library of Corona SDK for iOS (libplugin_adjust.a) ...')
    change_dir(plugin_dir)
    xcode_build_project('plugin_adjust', 'Plugin.xcodeproj')

    ## ------------------------------------------------------------------
    ## copy Corona plugin static library to test app dir
    debug_green('Copying static library from generated framework to output directory (test app dir) ...')
    copy_file(plugin_output_dir + '/libplugin_adjust.a', ios_test_app_dir + '/libplugin_adjust.a')

    ## ------------------------------------------------------------------
    ## Script completed
    debug_green('Open Xcode and run the TestApp project located in {0}/test/ios/App.xcodeproj'.format(root_dir))
