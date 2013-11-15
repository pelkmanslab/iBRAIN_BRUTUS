import os
import re
from datetime import datetime
from brainy.log import getBasicLogger
logger = getBasicLogger(__name__)
from sh import ErrorReturnCode, grep, wc
from subprocess import (PIPE, Popen)
import json
from brainy.flags import FlagManager
from brainy.lsf import Lsf, SHORT_QUEUE, LONG_QUEUE, NORM_QUEUE


# Set this value from the point of import.
IBRAIN_ROOT = None


def invoke(command, _in=None):
    '''
    Invoke command as a new system process and return its output.
    '''
    process = Popen(command, stdin=PIPE, stdout=PIPE, shell=True,
                    executable='/bin/bash')
    if _in is not None:
        process.stdin.write(_in)
    return process.stdout.read()


def get_config(root=None):
    if root is None:
        root = IBRAIN_ROOT
    if root is None:
        raise Exception('IBRAIN_ROOT is not set')
    config_file = os.path.join(root, 'etc', 'config')
    if not os.path.exists(config_file):
        raise Exception('Missing iBRAIN configuration file: %s' %
                        config_file)

    config_json = invoke('''
export IBRAIN_ROOT=%(IBRAIN_ROOT)s
. ${IBRAIN_ROOT}/etc/config
echo {
echo \\"bin_path\\": \\\"$IBRAIN_BIN_PATH\\\",
echo \\"etc_path\\": \\\"$IBRAIN_ETC_PATH\\\",
echo \\"var_path\\": \\\"$IBRAIN_VAR_PATH\\\",
echo \\"log_path\\": \\\"$IBRAIN_LOG_PATH\\\",
echo \\"database_path\\": \\\"$IBRAIN_DATABASE_PATH\\\",
echo \\"user_path\\": \\\"$IBRAIN_USER\\\",
echo \\"admin_path\\": \\\"$IBRAIN_ADMIN_EMAIL\\\"
echo }
    ''' % {'IBRAIN_ROOT': root})
    #print config_json
    config = json.loads(config_json)
    config['root'] = root
    return config


# def dump_config(config, format='json'):
#     if format == 'json':
#         return json.dumps(config)
#     elif format == 'bash':
#         # Map to bash variables


class BrainyModule(FlagManager):

    def __init__(self, name, env):
        self.name = name
        # Check for missing values?
        self.env = env
        self.__results = None
        self.scheduler = Lsf()

    def _get_flag_prefix(self):
        return os.path.join(self.env['project_dir'], self.name)

    def get_results(self):
        if self.__results is None:
            # Find result files only once.
            results_regex = re.compile('%s_\d+.results' % self.name)
            self.__results = [filename for filename
                              in os.listdir(self.env['batch_dir'])
                              if results_regex.search(filename)]
        return self.__results

    def submit_job(self, script, queue=SHORT_QUEUE):
        results_file = os.path.join(self.env['batch_dir'], '%s_%s.results') % \
            (self.name, datetime.now().strftime('%y%m%d%H%M%S'))
        return self.scheduler.bsub(
            '-W', queue,
            '-o', results_file,
            script)

    @property
    def results_count(self):
        return len(self.get_results())

    def job_count(self, needle=None):
        if needle is None:
            needle = os.path.basename(self.env['project_dir'])
        try:
            return int(wc(grep(self.scheduler.bjobs('-w'), needle), '-l'))
        except ErrorReturnCode:
            return 0
