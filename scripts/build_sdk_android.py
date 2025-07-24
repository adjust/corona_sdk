from scripting_utils import *

def build_plugin(dir_root, dir_dist):
    ## ------------------------------------------------------------------
    ## Paths.
    dir_root_android    = '{0}/plugin/android'.format(dir_root)
    dir_android_plugin  = '{0}/plugin/android/plugin'.format(dir_root)

    ## ------------------------------------------------------------------
    ## Build Adjust Corona plugin JAR library.
    debug_green('Building Adjust Corona plugin JAR library ...')
    change_dir(dir_root_android)
    gradle_assemble_release()
    
    ## ------------------------------------------------------------------
    ## Copy Adjust Corona plugin JAR to dist folder into VERSION subfolder.
    debug_green('Copying Adjust Corona plugin JAR library to dist directory ...')
    copy_file('{0}/build/intermediates/aar_main_jar/release/syncReleaseLibJars/classes.jar'.format(dir_android_plugin), '{0}/plugin.adjust.jar'.format(dir_dist))
    # change_dir(dir_dist)
    # extract_plugin_jar_from_aar()

def build_app_example(dir_root, dir_dist):
    ## ------------------------------------------------------------------
    ## Paths.
    dir_example_app         = '{0}/plugin/android/app'.format(dir_root)
    dir_root_android        = '{0}/plugin/android'.format(dir_root)
    dir_android_plugin      = '{0}/plugin/android/plugin'.format(dir_root)
    dir_sdk                 = '{0}/ext/android/sdk/Adjust'.format(dir_root)
    dir_jar_in_sdk          = '{0}/sdk-core/build/libs'.format(dir_sdk)
    dir_jar_out_sdk         = '{0}/libs'.format(dir_example_app)

    ## ------------------------------------------------------------------
    ## Clean example app libs directory.
    debug_green('Cleaning example app libs directory ...')
    clear_dir(dir_jar_out_sdk)

    ## ------------------------------------------------------------------
    ## Build Adjust Corona plugin JAR.
    debug_green('Building Adjust Corona plugin JAR ...')
    change_dir(dir_root_android)
    gradle_assemble_release()

    ## ------------------------------------------------------------------
    ## Copy Adjust Corona plgin JAR.
    debug_green('Copying Adjust Corona plugin JAR to example app libs directory ...')
    copy_file('{0}/build/intermediates/aar_main_jar/release/syncReleaseLibJars/classes.jar'.format(dir_android_plugin), '{0}/plugin.adjust.jar'.format(dir_jar_out_sdk))
    # change_dir(dir_jar_out_sdk)
    # extract_plugin_jar_from_aar()
    debug_green('Copying Adjust Corona plugin JAR library to dist directory ...')
    copy_file('{0}/build/intermediates/aar_main_jar/release/syncReleaseLibJars/classes.jar'.format(dir_android_plugin), '{0}/plugin.adjust.jar'.format(dir_dist))
    # change_dir(dir_dist)
    # extract_plugin_jar_from_aar()

    ## ------------------------------------------------------------------
    ## Script completed.
    debug_green('Open Android Studio and run the example app project located in {0}/android'.format(dir_root))

def build_app_test(dir_root, dir_dist):
    ## ------------------------------------------------------------------
    ## Paths.
    dir_test_app                = '{0}/test/android/app'.format(dir_root)
    dir_root_android            = '{0}/plugin/android'.format(dir_root)
    dir_root_android_test       = '{0}/test/android'.format(dir_root)
    dir_android_plugin          = '{0}/plugin/android/plugin'.format(dir_root)
    dir_android_test            = '{0}/test/android/plugin'.format(dir_root)
    dir_sdk                     = '{0}/ext/android/sdk/Adjust'.format(dir_root)
    dir_jar_in_sdk              = '{0}/sdk-core/build/libs'.format(dir_sdk)
    dir_jar_out_sdk             = '{0}/libs'.format(dir_test_app)
    dir_jar_in_sdk_test_library = '{0}/tests/test-library/build/intermediates/aar_main_jar/debug/syncDebugLibJars'.format(dir_sdk)
    dir_jar_in_sdk_test_options = '{0}/tests/test-options/build/intermediates/aar_main_jar/debug/syncDebugLibJars'.format(dir_sdk)
    dir_jar_out_sdk_test        = '{0}/test/android/plugin/libs'.format(dir_root)

    ## ------------------------------------------------------------------
    ## Clean test app libs directory.
    debug_green('Cleaning test app libs directory ...')
    clear_dir(dir_jar_out_sdk)

    ## ------------------------------------------------------------------
    ## Build Adjust Corona Plugin JAR.
    debug_green('Building Adjust Corona Plugin JAR ...')
    change_dir(dir_root_android)
    gradle_assemble_release()

    ## ------------------------------------------------------------------
    ## Copy Adjust Corona plugin JAR.
    debug_green('Copy Adjust Corona plugin JAR to test app libs directory ...')
    copy_file('{0}/build/intermediates/aar_main_jar/release/syncReleaseLibJars/classes.jar'.format(dir_android_plugin), '{0}/plugin.adjust.jar'.format(dir_jar_out_sdk))
    # change_dir(dir_jar_out_sdk)
    # extract_plugin_jar_from_aar()
    debug_green('Copying Adjust Corona plugin JAR to dist directory ...')
    copy_file('{0}/build/intermediates/aar_main_jar/release/syncReleaseLibJars/classes.jar'.format(dir_android_plugin), '{0}/plugin.adjust.jar'.format(dir_dist))
    # change_dir(dir_dist)
    # extract_plugin_jar_from_aar()

    # ------------------------------------------------------------------
    # Running Gradle tasks: clean :tests:test-library:adjustTestLibraryJarDebug ...
    change_dir(dir_sdk)
    debug_green('Running Gradle tasks clean :tests:test-library:adjustTestLibraryJarDebug ...')
    gradle_run([':tests:test-library:adjustTestLibraryJarDebug'])

    # ------------------------------------------------------------------
    # Copy Adjust Test Library JAR.
    debug_green('Copying Adjust Test Library JAR to Corona test plugin libs directory ...')
    copy_file('{0}/classes.jar'.format(dir_jar_in_sdk_test_library), '{0}/adjust-test-library.jar'.format(dir_jar_out_sdk_test))

    # ------------------------------------------------------------------
    # Running Gradle tasks: clean :tests:test-options:assembleDebug ...
    debug_green('Running Gradle tasks: clean :tests:test-options:assembleDebug ...')
    gradle_run([':tests:test-options:assembleDebug'])

    # ------------------------------------------------------------------
    # Copy Adjust Test Library JAR.
    debug_green('Copy Adjust Test Library JAR to Corona test plugin libs directory ...')
    copy_file('{0}/classes.jar'.format(dir_jar_in_sdk_test_options), '{0}/adjust-test-options.jar'.format(dir_jar_out_sdk_test))

    ## ------------------------------------------------------------------
    ## Build Adjust Corona test plugin JAR.
    debug_green('Building Adjust Corona test plugin JAR ...')
    change_dir(dir_root_android_test)
    gradle_assemble_release()

    ## ------------------------------------------------------------------
    ## Copy Adjust Corona test plugin JAR.
    debug_green('Copying Adjust Corona test plugin JAR to test app libs directory ...')
    copy_file('{0}/build/outputs/aar/plugin-release.aar'.format(dir_android_test), '{0}/plugin-release.aar'.format(dir_jar_out_sdk))
    change_dir(dir_jar_out_sdk)
    extract_test_jar_from_aar()

    ## ------------------------------------------------------------------
    ## Script completed.
    debug_green('Open Android Studio and run the TestApp project located in {0}/test/android'.format(dir_root))
