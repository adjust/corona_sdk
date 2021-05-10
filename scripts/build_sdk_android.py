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
    
    ## ------------------------------------------------------------------
    ## Copy Corona plugin JAR to dist folder into VERSION subfolder.
    debug_green('Copying Corona plugin JAR library to dist directory ...')
    copy_file('{0}/build/outputs/aar/plugin-release.aar'.format(dir_android_plugin), '{0}/plugin-release.aar'.format(dir_dist))
    change_dir(dir_dist)
    extract_plugin_jar_from_aar()

def build_app_example(dir_root):
    ## ------------------------------------------------------------------
    ## Paths.
    dir_example_app         = '{0}/plugin/android/app'.format(dir_root)
    dir_root_android        = '{0}/plugin/android'.format(dir_root)
    dir_android_plugin      = '{0}/plugin/android/plugin'.format(dir_root)
    dir_sdk                 = '{0}/ext/android/sdk/Adjust'.format(dir_root)
    dir_jar_in_sdk          = '{0}/sdk-core/build/libs'.format(dir_sdk)
    dir_jar_out_sdk         = '{0}/libs'.format(dir_example_app)

    ## ------------------------------------------------------------------
    ## Remove current JARs.
    debug_green('Remove current JARs ...')
    clear_dir(dir_jar_out_sdk)

    ## ------------------------------------------------------------------
    ## Build Adjust Corona Plugin JAR.
    debug_green('Building Adjust Corona Plugin JAR ...')
    change_dir(dir_root_android)
    gradle_assemble_release()

    ## ------------------------------------------------------------------
    ## Copy Adjust SDK JAR.
    debug_green('Copy Adjust Corona Plugin JAR ...')
    copy_file('{0}/build/outputs/aar/plugin-release.aar'.format(dir_android_plugin), '{0}/plugin-release.aar'.format(dir_jar_out_sdk))
    change_dir(dir_jar_out_sdk)
    extract_plugin_jar_from_aar()

    ## ------------------------------------------------------------------
    ## Script completed.
    debug_green('Open Android Studio and run the example app project located in {0}/android'.format(dir_root))

def build_app_test(dir_root):
    ## ------------------------------------------------------------------
    ## Paths.
    dir_test_app                = '{0}/test/android/app'.format(dir_root)
    dir_root_android            = '{0}/plugin/android'.format(dir_root)
    dir_android_plugin          = '{0}/plugin/android/plugin'.format(dir_root)
    dir_sdk                     = '{0}/ext/android/sdk/Adjust'.format(dir_root)
    dir_jar_in_sdk              = '{0}/sdk-core/build/libs'.format(dir_sdk)
    dir_jar_out_sdk             = '{0}/libs'.format(dir_test_app)
    dir_jar_in_sdk_test_library = '{0}/test-library/build/libs'.format(dir_sdk)
    dir_jar_in_sdk_test_options = '{0}/test-options/build/intermediates/aar_main_jar/release'.format(dir_sdk)
    dir_jar_out_sdk_test        = '{0}/test/android/plugin/libs'.format(dir_root)

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
    # Running Gradle tasks: clean test-library:adjustTestLibraryJarDebug ...
    debug_green('Running Gradle tasks: clean test-library:adjustTestLibraryJarDebug ...')
    gradle_run([':test-library:adjustTestLibraryJarDebug'])

    # ------------------------------------------------------------------
    # Copy Adjust Test Library JAR.
    debug_green('Copy Adjust Test Library JAR ...')
    copy_file('{0}/test-library-debug.jar'.format(dir_jar_in_sdk_test_library), '{0}/adjust-test-library.jar'.format(dir_jar_out_sdk_test))

    # ------------------------------------------------------------------
    # Running Gradle tasks: clean test-options:assembleRelease ...
    debug_green('Running Gradle tasks: clean test-options:assembleRelease ...')
    gradle_run([':test-options:assembleRelease'])

    # ------------------------------------------------------------------
    # Copy Adjust Test Library JAR.
    debug_green('Copy Adjust Test Library JAR ...')
    copy_file('{0}/classes.jar'.format(dir_jar_in_sdk_test_options), '{0}/adjust-test-options.jar'.format(dir_jar_out_sdk_test))

    ## ------------------------------------------------------------------
    ## Build Adjust Corona Plugin JAR.
    debug_green('Building Adjust Corona Plugin JAR ...')
    change_dir(dir_root_android)
    gradle_assemble_release()

    ## ------------------------------------------------------------------
    ## Copy Adjust SDK JAR.
    debug_green('Copy Adjust Corona Plugin JAR ...')
    copy_file('{0}/build/outputs/aar/plugin-release.aar'.format(dir_android_plugin), '{0}/plugin-release.aar'.format(dir_jar_out_sdk))
    change_dir(dir_jar_out_sdk)
    extract_plugin_jar_from_aar()

    ## ------------------------------------------------------------------
    ## Script completed.
    debug_green('Open Android Studio and run the TestApp project located in {0}/test/android'.format(dir_root))
