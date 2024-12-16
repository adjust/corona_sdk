#!/usr/bin/python

from scripting_utils import *
import argparse
import build_sdk_android as android
import build_sdk_ios     as ios

set_log_tag('CORONA-SDK')

## ------------------------------------------------------------------
## Arguments.
parser = argparse.ArgumentParser(description='Adjust SDK for Corona build script.')
parser.add_argument('-p', '--platform', help='Platform to build the plugin for.', choices=['android', 'ios'])
parser.add_argument('-t', '--type', help='Type of build.', choices=['plugin', 'app-example', 'app-test'])
args = parser.parse_args()
debug_green('Script started. Selected platform: {0}. Selected build type: {1}.'.format(args.platform, args.type))

# ------------------------------------------------------------------
# Paths.
dir_script              = os.path.dirname(os.path.realpath(__file__))
dir_root                = os.path.dirname(os.path.normpath(dir_script))
dir_submodule_android   = '{0}/ext/android'.format(dir_root)
dir_submodule_ios       = '{0}/ext/ios'.format(dir_root)
dir_dist				= '{0}/dist'.format(dir_root)

try:
    if args.platform == 'ios':
        if args.type == 'plugin':
            set_log_tag('CORONA-SDK-IOS')
            check_submodule_dir('ios', dir_submodule_ios + '/sdk')
            ios.build_plugin(dir_root, dir_dist)
        if args.type == 'app-test':
            set_log_tag('CORONA-SDK-IOS-APP-TEST')
            ios.build_app_test(dir_root)
        if args.type == 'app-example':
            set_log_tag('CORONA-SDK-IOS-APP-EXAMPLE')
            ios.build_app_example(dir_root)
    else:
        if args.type == 'plugin':
            set_log_tag('CORONA-SDK-ANDROID')
            check_submodule_dir('android', dir_submodule_android + '/sdk')
            android.build_plugin(dir_root, dir_dist)
        if args.type == 'app-test':
            set_log_tag('CORONA-SDK-ANDROID-APP-TEST')
            android.build_app_test(dir_root, dir_dist)
        if args.type == 'app-example':
            set_log_tag('CORONA-SDK-ANDROID-APP-EXAMPLE')
            android.build_app_example(dir_root, dir_dist)
finally:
    # Remove autocreated python compiled files.
    remove_files('*.pyc', dir_script, log=False)

## ------------------------------------------------------------------
## Script completed.
debug_green('Script completed!')
