from scripting_utils import *

def build_plugin(root_dir, dist_dir):
    ## ------------------------------------------------------------------
    ## Paths
    android_root_dir    = '{0}/plugin/android'.format(root_dir)
    android_plugin_dir  = '{0}/plugin/android/plugin'.format(root_dir)

    ## ------------------------------------------------------------------
    ## Build Corona plugin JAR library.
    debug_green('Building Corona plugin JAR library ...')
    change_dir(android_root_dir)
    gradle_assemble_release()
    gradle_export_plugin_jar()
    
    ## ------------------------------------------------------------------
    ## Copy Corona plugin JAR to dist folder into VERSION subfolder.
    debug_green('Copying Corona plugin JAR library to dist directory ...')
    copy_file('{0}/build/outputs/jar/plugin.adjust.jar'.format(android_plugin_dir), '{0}/plugin.adjust.jar'.format(dist_dir))

def build_testapp(root_dir):
    ## ------------------------------------------------------------------
    ## Paths.
    android_test_app_dir    = '{0}/test/android/app'.format(root_dir)
    android_plugin_dir      = '{0}/plugin/android'.format(root_dir)
    android_plugin_dir_test = '{0}/test/android'.format(root_dir)
    adjust_sdk_dir          = '{0}/ext/android/sdk/Adjust'.format(root_dir)
    jar_in_dir              = '{0}/sdk-core/build/libs'.format(adjust_sdk_dir)
    jar_out_dir             = '{0}/libs'.format(android_test_app_dir)

    ## ------------------------------------------------------------------
    ## Remove current JARs.
    debug_green('Remove current JARs ...')
    clear_dir(jar_out_dir)

    ## ------------------------------------------------------------------
    ## Build Adjust SDK JARs.
    debug_green('Building Adjust SDK JARs ...')
    change_dir(adjust_sdk_dir)
    gradle_make_release_jar()
    
    ## ------------------------------------------------------------------
    ## Copy Adjust SDK JAR.
    debug_green('Copy Adjust SDK JAR ...')
    copy_file('{0}/adjust-sdk-release.jar'.format(jar_in_dir), '{0}/adjust-android.jar'.format(jar_out_dir))

    ## ------------------------------------------------------------------
    ## Build Adjust Corona Plugin JAR.
    debug_green('Building Adjust Corona Plugin JAR ...')
    change_dir(android_plugin_dir_test)
    gradle_assemble_release()
    gradle_export_plugin_jar()

    ## ------------------------------------------------------------------
    ## Copy Adjust SDK JAR.
    debug_green('Copy Adjust Corona Plugin JAR ...')
    copy_file('{0}/plugin/build/outputs/jar/plugin.adjust.jar'.format(android_plugin_dir), '{0}/plugin.adjust.jar'.format(jar_out_dir))

    ## ------------------------------------------------------------------
    ## Script completed.
    debug_green('Open Android Studio and run the TestApp project located in {0}/test/android'.format(root_dir))
