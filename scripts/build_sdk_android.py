from scripting_utils import *

def build_plugin(root_dir, dist_dir):
    ## ------------------------------------------------------------------
    ## paths
    android_root_dir = '{0}/plugin/android'.format(root_dir)
    android_plugin_dir = '{0}/plugin/android/plugin'.format(root_dir)

    ## ------------------------------------------------------------------
    ## Build Corona plugin JAR library
    debug_green('Building Corona plugin JAR library ...')
    change_dir(android_root_dir)
    gradle_assemble_release()
    gradle_export_plugin_jar()
    
    ## ------------------------------------------------------------------
    ## Copy Corona plugin JAR to dist folder into VERSION subfolder
    debug_green('Copying Corona plugin JAR library to dist directory ...')
    copy_file('{0}/build/outputs/jar/plugin.adjust.jar'.format(android_plugin_dir), '{0}/plugin.adjust.jar'.format(dist_dir))

def build_testapp(root_dir):
    ## ------------------------------------------------------------------
    ## paths
    android_test_app_dir = '{0}/test/android/app'.format(root_dir)
    android_plugin_dir  = '{0}/plugin/android'.format(root_dir)
    adjust_sdk_dir      = '{0}/ext/android/sdk/Adjust'.format(root_dir)
    jar_in_dir          = '{0}/target'.format(adjust_sdk_dir)
    jar_out_dir         = '{0}/libs'.format(android_test_app_dir)

    ## ------------------------------------------------------------------
    ## remove current JARs
    debug_green('Remove current JARs ...')
    clear_dir(jar_out_dir)

    ## ------------------------------------------------------------------
    ## build Adjust SDK JAR
    debug_green('Building Adjust SDK JAR ...')
    change_dir(adjust_sdk_dir)
    mvn_clean()
    mvn_package()
    
    ## ------------------------------------------------------------------
    ## copy Adjust SDK JAR
    debug_green('Copy Adjust SDK JAR ...')
    copy_files('adjust-android-*.*.*.jar', jar_in_dir, jar_out_dir)
    remove_files('*-javadoc.jar', jar_out_dir)
    remove_files('*-sources.jar', jar_out_dir)
    rename_file('adjust-android-*.*.*.jar', 'adjust-android.jar', jar_out_dir)

    ## ------------------------------------------------------------------
    ## build Adjust Corona Plugin JAR
    debug_green('Building Adjust Corona Plugin JAR ...')
    change_dir(android_plugin_dir)
    gradle_assemble_release()
    gradle_export_plugin_jar()

    ## ------------------------------------------------------------------
    ## copy Adjust SDK JAR
    debug_green('Copy Adjust Corona Plugin JAR ...')
    copy_file('{0}/plugin/build/outputs/jar/plugin.adjust.jar'.format(android_plugin_dir), '{0}/plugin.adjust.jar'.format(jar_out_dir))

    ## ------------------------------------------------------------------
    ## Script completed
    debug_green('Open Android Studio and run the TestApp project located in {0}/test/android'.format(root_dir))
