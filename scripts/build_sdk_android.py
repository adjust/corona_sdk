from scripting_utils import *

def build_plugin(dir_root, dir_dist):
    ## ------------------------------------------------------------------
    ## Paths.
    dir_root_android    = '{0}/plugin/android'.format(dir_root)
    dir_android_plugin  = '{0}/plugin/android/plugin'.format(dir_root)

    ## ------------------------------------------------------------------
    ## Build Corona plugin JAR library.
    debug_green('Building Corona plugin JAR library ...')
    change_dir(dir_root_android)
    gradle_assemble_release()
    gradle_export_plugin_jar()
    
    ## ------------------------------------------------------------------
    ## Copy Corona plugin JAR to dist folder into VERSION subfolder.
    debug_green('Copying Corona plugin JAR library to dist directory ...')
    copy_file('{0}/build/outputs/jar/plugin.adjust.jar'.format(dir_android_plugin), '{0}/plugin.adjust.jar'.format(dir_dist))

def build_testapp(dir_root):
    ## ------------------------------------------------------------------
    ## Paths.
    dir_test_app            = '{0}/test/android/app'.format(dir_root)
    dir_root_android        = '{0}/plugin/android'.format(dir_root)
    dir_sdk                 = '{0}/ext/android/sdk/Adjust'.format(dir_root)
    dir_jar_in_sdk          = '{0}/sdk-core/build/libs'.format(dir_sdk)
    dir_jar_out_sdk         = '{0}/libs'.format(dir_test_app)
    dir_jar_in_sdk_test     = '{0}/test-library/build/libs'.format(dir_sdk)
    dir_jar_out_sdk_test    = '{0}/test/android/plugin/libs'.format(dir_root)

    ## ------------------------------------------------------------------
    ## Remove current JARs.
    debug_green('Remove current JARs ...')
    clear_dir(dir_jar_out_sdk)

    ## ------------------------------------------------------------------
    ## Build Adjust SDK JARs.
    debug_green('Building Adjust SDK JARs ...')
    change_dir(dir_sdk)
    gradle_make_release_jar()
    
    ## ------------------------------------------------------------------
    ## Copy Adjust SDK JAR.
    debug_green('Copy Adjust SDK JAR ...')
    copy_file('{0}/adjust-sdk-release.jar'.format(dir_jar_in_sdk), '{0}/adjust-android.jar'.format(dir_jar_out_sdk))

    # ------------------------------------------------------------------
    # Running Gradle tasks: clean testlibrary:adjustTestLibraryJarDebug ...
    debug_green('Running Gradle tasks: clean test-library:adjustTestLibraryJarDebug ...')
    gradle_run([':test-library:adjustTestLibraryJarDebug'])

    # ------------------------------------------------------------------
    # Copy Adjust Test Library JAR.
    debug_green('Copy Adjust Test Library JAR ...')
    copy_file('{0}/test-library-debug.jar'.format(dir_jar_in_sdk_test), '{0}/adjust-test.jar'.format(dir_jar_out_sdk_test))

    ## ------------------------------------------------------------------
    ## Build Adjust Corona Plugin JAR.
    debug_green('Building Adjust Corona Plugin JAR ...')
    change_dir(dir_root_android)
    gradle_assemble_release()
    gradle_export_plugin_jar()

    ## ------------------------------------------------------------------
    ## Copy Adjust SDK JAR.
    debug_green('Copy Adjust Corona Plugin JAR ...')
    copy_file('{0}/plugin/build/outputs/jar/plugin.adjust.jar'.format(dir_root_android), '{0}/plugin.adjust.jar'.format(dir_jar_out_sdk))

    ## ------------------------------------------------------------------
    ## Script completed.
    debug_green('Open Android Studio and run the TestApp project located in {0}/test/android'.format(dir_root))
