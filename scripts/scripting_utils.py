import os, shutil, glob, platform, subprocess

## ------------------------------------------------------------------
## Tag.
def set_log_tag(t):
    global TAG
    TAG = t

## ------------------------------------------------------------------
## Terminal colours.

CEND = '\033[0m'

CBOLD     = '\33[1m'
CITALIC   = '\33[3m'
CURL      = '\33[4m'
CBLINK    = '\33[5m'
CBLINK2   = '\33[6m'
CSELECTED = '\33[7m'

CBLACK  = '\33[30m'
CRED    = '\33[31m'
CGREEN  = '\33[32m'
CYELLOW = '\33[33m'
CBLUE   = '\33[34m'
CVIOLET = '\33[35m'
CBEIGE  = '\33[36m'
CWHITE  = '\33[37m'

CBLACKBG  = '\33[40m'
CREDBG    = '\33[41m'
CGREENBG  = '\33[42m'
CYELLOWBG = '\33[43m'
CBLUEBG   = '\33[44m'
CVIOLETBG = '\33[45m'
CBEIGEBG  = '\33[46m'
CWHITEBG  = '\33[47m'

CGREY    = '\33[90m'
CRED2    = '\33[91m'
CGREEN2  = '\33[92m'
CYELLOW2 = '\33[93m'
CBLUE2   = '\33[94m'
CVIOLET2 = '\33[95m'
CBEIGE2  = '\33[96m'
CWHITE2  = '\33[97m'

CGREYBG    = '\33[100m'
CREDBG2    = '\33[101m'
CGREENBG2  = '\33[102m'
CYELLOWBG2 = '\33[103m'
CBLUEBG2   = '\33[104m'
CVIOLETBG2 = '\33[105m'
CBEIGEBG2  = '\33[106m'
CWHITEBG2  = '\33[107m'

## ------------------------------------------------------------------
## File system methods.

def copy_file(sourceFile, destFile):
    debug('copying: {0} -> {1}'.format(sourceFile, destFile))
    shutil.copyfile(sourceFile, destFile)

def copy_files(fileNamePattern, sourceDir, destDir):
    for file in glob.glob(sourceDir + '/' + fileNamePattern):
        debug('copying: {0} -> {1}'.format(file, destDir))
        shutil.copy(file, destDir)

def copy_dir_contents(sourceDir, destDir):
    copy_tree(sourceDir, destDir)

def remove_files(fileNamePattern, sourceDir, log=True):
    for file in glob.glob(sourceDir + '/' + fileNamePattern):
        if log:
            debug('deleting: ' + file)
        os.remove(file)

def rename_file(fileNamePattern, newFileName, sourceDir):
    for file in glob.glob(sourceDir + '/' + fileNamePattern):
        debug('rename: {0} -> {1}'.format(file, newFileName))
        os.rename(file, sourceDir + '/' + newFileName)

def remove_dir_if_exists(path):
    if os.path.exists(path):
        debug('deleting dir: ' + path)
        shutil.rmtree(path)
    else:
        debug('canot delete {0}. dir does not exist'.format(path))

def remove_file_if_exists(path):
    if os.path.exists(path):
        debug('deleting: ' + path)
        os.remove(path)
    else:
        debug('canot delete {0}. file does not exist'.format(path))

def clear_dir(dir):
    shutil.rmtree(dir)
    os.mkdir(dir)

def recreate_dir(dir):
    if os.path.exists(dir):
        shutil.rmtree(dir)
    os.mkdir(dir)

def create_dir_if_not_exist(dir):
    if not os.path.exists(dir):
        os.makedirs(dir)

## ------------------------------------------------------------------
## Logging methods.

def debug(msg):
    if not is_windows():
        print(('{0}* [{1}][INFO]:{2} {3}').format(CBOLD, TAG, CEND, msg))
    else:
        print(('* [{0}][INFO]: {1}').format(TAG, msg))

def debug_green(msg):
    if not is_windows():
        print(('{0}* [{1}][INFO]:{2} {3}{4}{5}').format(CBOLD, TAG, CEND, CGREEN, msg, CEND))
    else:
        print(('* [{0}][INFO]: {1}').format(TAG, msg))

def debug_blue(msg):
    if not is_windows():
        print(('{0}* [{1}][INFO]:{2} {3}{4}{5}').format(CBOLD, TAG, CEND, CBLUE, msg, CEND))
    else:
        print(('* [{0}][INFO]: {1}').format(TAG, msg))

def error(msg, do_exit=False):
    if not is_windows():
        print(('{0}* [{1}][ERROR]:{2} {3}{4}{5}').format(CBOLD, TAG, CEND, CRED, msg, CEND))
    else:
        print(('* [{0}][ERROR]: {1}').format(TAG, msg))

    if do_exit:
        exit()

## ------------------------------------------------------------------
## Random utility methods.

def check_submodule_dir(platform, submodule_dir):
    if not os.path.isdir(submodule_dir) or not os.listdir(submodule_dir):
        error('Submodule [{0}] folder empty. Did you forget to run "git submodule update --init --recursive"?'.format(platform))
        exit()

def is_windows():
    return platform.system().lower() == 'windows';

# https://stackoverflow.com/questions/17140886/how-to-search-and-replace-text-in-a-file-using-python
def replace_text_in_file(file_path, substring, replace_with):
    # Read in the file.
    with open(file_path, 'r') as file:
        filedata = file.read()

    # Replace the target string.
    filedata = filedata.replace(substring, replace_with)

    # Write the file out again.
    with open(file_path, 'w') as file:
        file.write(filedata)

def execute_command(cmd_params, log=True):
    if log:
        debug_blue('Executing: [{0}]'.format(' '.join(str(x) for x in cmd_params)))
    subprocess.call(cmd_params)

def change_dir(dir):
    os.chdir(dir)

def xcode_build(target, configuration='Release', use_modern_build_system=False):
    if use_modern_build_system:
        execute_command(['xcodebuild', '-target', target, '-configuration', configuration, 'clean', 'build'])
    else:
        execute_command(['xcodebuild', '-target', target, '-configuration', configuration, 'clean', 'build', '-UseModernBuildSystem=NO'])

def xcode_build_project(target, project, configuration='Release', use_modern_build_system=False):
    if use_modern_build_system:
        execute_command(['xcodebuild', '-target', target, '-project', project, '-configuration', configuration, 'clean', 'build'])
    else:
        execute_command(['xcodebuild', '-target', target, '-project', project, '-configuration', configuration, 'clean', 'build', '-UseModernBuildSystem=NO'])

def gradle_make_release_jar():
    execute_command(['./gradlew', 'adjustCoreJarRelease'])

def gradle_assemble_release():
    execute_command(['./gradlew', 'plugin:clean', 'plugin:assemble'])

def gradle_export_plugin_jar():
    execute_command(['./gradlew', 'exportPluginJar'])

def gradle_run(options):
    cmd_params = ['./gradlew']
    for opt in options:
        cmd_params.append(opt)
    execute_command(cmd_params)

def extract_plugin_jar_from_aar():
    execute_command(['unzip', 'plugin-release.aar', '-d', 'temp'])
    execute_command(['mv', 'temp/classes.jar', 'plugin.adjust.jar'])
    execute_command(['rm', '-rf', 'temp'])
    execute_command(['rm', '-rf', 'plugin-release.aar'])

def extract_test_jar_from_aar():
    execute_command(['unzip', 'plugin-release.aar', '-d', 'temp'])
    execute_command(['mv', 'temp/classes.jar', 'test.adjust.jar'])
    execute_command(['rm', '-rf', 'temp'])
    execute_command(['rm', '-rf', 'plugin-release.aar'])
