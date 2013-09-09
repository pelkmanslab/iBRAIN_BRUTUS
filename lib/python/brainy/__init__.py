'''
Integration of python-based mashups into iBRAIN.

Put the following call into the import section of your python code:

import brainy
brainy.prepend_lib_path()


@author: Yauhen Yakimovich <yauhen.yakimovich@uzh.ch>

'''
import os
import re
from datetime import datetime
from brainy.log import getBasicLogger
logger = getBasicLogger(__name__)
from sh import ErrorReturnCode, grep, wc, touch
from brainy.lsf import Lsf, SHORT_QUEUE, LONG_QUEUE, NORM_QUEUE
from subprocess import (PIPE, Popen)
import json


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
    if not root:
        root = IBRAIN_ROOT
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
    config['root'] = IBRAIN_ROOT
    return config


# def dump_config(config, format='json'):
#     if format == 'json':
#         return json.dumps(config)
#     elif format == 'bash':
#         # Map to bash variables


class BrainyModule(object):

    def __init__(self, name, env):
        self.name = name
        # Check for missing values?
        self.env = env
        self.__results = None
        self.scheduler = Lsf()

    def get_results(self):
        if self.__results is None:
            # Find result files only once.
            results_regex = re.compile('%s_\d+.results' % self.name)
            self.__results = [filename for filename \
                    in os.listdir(self.env['batch_dir']) \
                    if results_regex.search(filename)]
        return self.__results

    def _get_flag_prefix(self):
        return os.path.join(self.env['project_dir'], self.name)

    @property
    def is_submitted(self):
        return os.path.exists('%s.submitted' % self._get_flag_prefix())

    @property
    def is_resubmitted(self):
        return os.path.exists('%s.submitted' % self._get_flag_prefix())\
                and  os.path.exists('%s.resubmitted' % self._get_flag_prefix())

    @property
    def has_runlimit(self):
        return os.path.exists('%s.runlimit' % self._get_flag_prefix())

    def reset_submitted(self):
        '''
        If no no jobs are found for this project, waiting is senseless. Remove
        ".submitted" file and try again.
        '''
        submitted_flag = '%s.submitted' % self._get_flag_prefix()
        if not os.path.exists(submitted_flag):
            print('Failed to reset: submission flag not found.')
            return
        os.remove(submitted_flag)

    def set_flag(self, flag='submitted'):
        flag = '.'.join((self._get_flag_prefix(), flag))
        touch(flag)

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
