#!/usr/bin/python
'''
A command-line interface to run a single iBRAIN module.

'''
import os
import sys
from ext_path import get_root_path
import brainy.modules
import argparse
from pprint import pformat


brainy.modules.IBRAIN_ROOT = get_root_path(
    os.path.abspath(__file__), 'root', readlink=False)
config = brainy.get_config()


DRY_RUN = False
VERBOSE = False
NAMES_OF_MODULE_PARAMETERS = [
    # Required
    'PROJECTPATH',  # old INCLUDEDPATH
    'PLATEDIRECTORYLIST',  # old PLATEDIRECTORYLISTING
    'PLATEPATH',  # old PROJECTDIR
    'PIPESPATH',  # For iBRAIN PIPES
    # Inferable
    'TIFFPATH',  # old TIFFPATH
    'BATCHPATH',  # old BATCHPATH
    'POSTANALYSISPATH',  # old POSTANALYSISPATH
    'JPGPATH',  # old JPGDIR
    'JOBSFILE',
    'PLATEJOBCOUNT',
]


class ParameterError(Exception):
    '''Raised while checking for module parameters'''


def parse_module_parameters(args):
    module_parameters = dict()
    # Check for obligatory parameters.
    required_params = [
        'projectpath',
        'platedirectorylist',
        'platepath',
    ]
    if all([getattr(args, required_param)
            for required_param in required_params]):
        raise ParameterError('Missing one of the required parameters: %s' %
                             required_params)
    # Pack all of them into a dictionary.
    for parameter_name in NAMES_OF_MODULE_PARAMETERS:
        key = parameter_name.lower()
        module_parameters[key] = getattr(args, key)

    # iBRAIN's INCLUDEDPATH, PLATEDIRECTORYLISTING, PROJECTDIR
    # Infer missing parameters from platepath.
    if not module_parameters['projectpath'] \
            and not module_parameters['platedirectorylist']:
        platepath = module_parameters['platepath']
        if not platepath:
            raise ParameterError('Missing platepath parameter. Parameters '
                                 'as specified by you are:\n%s' %
                                 pformat(module_parameters))
        module_parameters['platedirectorylist'] = [platepath]
        module_parameters['projectpath'] = os.path.dirname(platepath)

    projectpath = module_parameters['projectpath']
    if not projectpath or not os.path.exists(projectpath):
        raise ParameterError('Project path does not exists: %s' % projectpath)

    platepath = module_parameters['platepath']
    if not platepath or not os.path.exists(platepath):
        raise ParameterError('Plate path does not exists: %s' % platepath)

    # TIFFDIR, BATCHDIR, POSTANALYSISDIR,  JPGDIR
    # JOBSFILE, PLATEJOBCOUNT
    tiffpath = module_parameters['tiffpath']
    if not tiffpath:
        tiffpath = os.path.join(platepath, 'TIFF')
    if not os.path.exists(tiffpath):
        raise ParameterError('TIFF path does not exists: %s' % tiffpath)

    batchpath = module_parameters['batchpath']
    if not batchpath:
        batchpath = os.path.join(platepath, 'BATCH')
    if not os.path.exists(batchpath):
        raise ParameterError('BATCH path does not exists: %s' % batchpath)
    module_parameters['batchpath'] = batchpath

    postanalysispath = module_parameters['postanalysispath']
    if not postanalysispath:
        postanalysispath = os.path.join(platepath, 'POSTANALYSIS')
    if not os.path.exists(postanalysispath):
        sys.stderr.write('POSTANALYSIS path does not exists (yet?): %s\n' %
                         postanalysispath)
    module_parameters['postanalysispath'] = postanalysispath

    jpgpath = module_parameters['jpgpath']
    if not jpgpath:
        jpgpath = os.path.join(platepath, 'JPG')
    if not os.path.exists(jpgpath):
        sys.stderr.write('JPG path does not exists (yet?): %s\n' % jpgpath)
    module_parameters['jpgpath'] = jpgpath

    pipespath = module_parameters['pipespath']
    if not pipespath:
        pipespath = os.path.join(platepath, 'PIPES')
    if not os.path.exists(pipespath):
        sys.stderr.write('PIPES path does not exists (yet?): %s\n' % pipespath)
    module_parameters['pipespath'] = pipespath

    # jobsfile = module_parameters['jobsfile']
    # if not jobsfile:
    #     '/*.' config['log_path']
    #     exit()
    #     output = brainy.invoke(command)
    #     jobsfile = output.strip()
    #     if not os.path.exists(jobsfile):
    #         sys.stderr.write('JOBs file does not exists (yet?): %s\n' %
    #                          jobsfile)
    #     module_parameters['jobsfile'] = jobsfile

    return module_parameters


def run_module(name, parameters, args):
    module_path = os.path.join(config['root'], 'core', 'modules',
                               '%s.sh' % name)
    if not os.path.exists(module_path):
        raise Exception('Module path not found: %s' % module_path)
    export_vars = {
        'IBRAIN_ROOT': config['root'],
        'module_name': name,
        'module_path': module_path,
    }
    export_vars.update(parameters)
    command = '''
export IBRAIN_ROOT=%(IBRAIN_ROOT)s
export MODULENAME=%(module_name)s
export MODULEPATH=%(module_path)s
export INCLUDEDPATH=%(projectpath)s
export PLATEDIRECTORYLISTING=%(platedirectorylist)s
export TIFFDIR=%(tiffpath)s
export PROJECTDIR=%(platepath)s
export BATCHDIR=%(batchpath)s
export POSTANALYSISDIR=%(postanalysispath)s
export JPGDIR=%(jpgpath)s
export JOBSFILE=%(jobsfile)s
export PLATEJOBCOUNT=%(jobsfile)s
export PIPESDIR=%(pipespath)s
. ${IBRAIN_ROOT}/etc/config
. ${IBRAIN_ROOT}/core/functions/execute_ibrain_module.sh
. %(module_path)s
    ''' % export_vars
    if VERBOSE:
        print command
    output = brainy.invoke(command)
    print output


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='A command-line interface '
                                     'to run a single iBRAIN module',
                                     epilog='Example: ./iBRAIN_module.py '
                                     '--name dummy_module --run --set-platepa'
                                     'th <...>')
    parser.add_argument('-d', '--dry-run', dest='dryrun',
                        action='store_true', help='Dry-run mode')
    parser.add_argument('--name', help='Name of the module in core/module/'
                        '<name>.sh')
    # Add all module parameters as arguments.
    for parameter_name in NAMES_OF_MODULE_PARAMETERS:
        parser.add_argument(
            '--set-' + parameter_name.lower(),
            dest=parameter_name.lower(),
            help='Set ' + parameter_name.upper(),
        )
    # Actions
    parser.add_argument('-r', '--run', dest='action', action='store_const',
                        const='run', help='Dry-run mode')

    args = parser.parse_args()
    if args.dryrun:
        DRY_RUN = True
    try:
        module_parameters = parse_module_parameters(args)
    except ParameterError as error:
        sys.stderr.write(error.message + '\n')
        parser.print_help(sys.stderr)
        exit()

    if args.action == 'run':
        run_module(args.name, module_parameters, args)
    elif not args.action:
        parser.print_help(sys.stderr)
        exit()
