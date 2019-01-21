#!/usr/bin/python

from scripting_utils import *
import argparse
import build_sdk_android as android
import build_sdk_ios     as ios

set_log_tag('CORONA-SDK')

## ------------------------------------------------------------------
## Arguments.
parser = argparse.ArgumentParser(description='Script used to build Adjust SDK for Corona.')
parser.add_argument('-p', '--platform', help='Platform for which the scripts will be executed.', choices=['android', 'ios'])
parser.add_argument('-t', '--type', help='Type of SDK plugin to be built', choices=['plugin', 'testapp'], default='plugin')
args = parser.parse_args()
debug_green('Script start. Platform=[{0}]. Building Adjust SDK for Corona [{1}] ...'.format(args.platform, args.type))

# ------------------------------------------------------------------
# Paths.
script_dir              = os.path.dirname(os.path.realpath(__file__))
root_dir                = os.path.dirname(os.path.normpath(script_dir))
android_submodule_dir   = '{0}/ext/android'.format(root_dir)
ios_submodule_dir       = '{0}/ext/ios'.format(root_dir)
dist_dir				= '{0}/dist'.format(root_dir)

try:
    if args.platform == 'ios':
        if args.type == 'plugin':
            set_log_tag('IOS-SDK-BUILD')
            check_submodule_dir('iOS', ios_submodule_dir + '/sdk')
            ios.build_plugin(root_dir, dist_dir)
        if args.type == 'testapp':
            set_log_tag('IOS-TESTAPP-RUN')
            ios.build_testapp(root_dir)
    else:
        if args.type == 'plugin':
            set_log_tag('ANROID-SDK-BUILD')
            check_submodule_dir('Android', android_submodule_dir + '/sdk')
            android.build_plugin(root_dir, dist_dir)
        if args.type == 'testapp':
            set_log_tag('ANDROID-TESTAPP-RUN')
            android.build_testapp(root_dir)
finally:
    # Remove autocreated python compiled files.
    remove_files('*.pyc', script_dir, log=False)

## ------------------------------------------------------------------
## Script completed.
debug_green('Script completed!')
