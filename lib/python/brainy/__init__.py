'''
Integration of python-based mashups into iBRAIN.

Put the following call into the import section of your python code:

import brainy
brainy.prepend_lib_path()


@author: Yauhen Yakimovich <yauhen.yakimovich@uzh.ch>

'''

import sys
import os

#Extend python path with iBRAIN lib/python folder.
_lib_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'lib', 'python')
sys.path = [_lib_path] + sys.path

import re
from datetime import datetime
from sh import ErrorReturnCode, bsub, bjobs, grep, wc, touch


SHORT_QUEUE = '1:00'
NORM_QUEUE = '8:00'
LONG_QUEUE = '36:00'


class BrainyModule(object):

    def __init__(self, name, env):
        self.name = name
        # Check for missing values?
        self.env = env
        self.__results = None

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
        flag = '.'.join((self._get_flag_prefix(),flag))
        touch(flag)

    def submit_job(self, script, queue=SHORT_QUEUE):
        results_file = os.path.join(self.env['batch_dir'], '%s_%s.results') % \
                (self.name, datetime.now().strftime('%y%m%d%H%M%S'))
        return bsub(
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
            return int(wc(grep(bjobs('-w'), needle), '-l'))
        except ErrorReturnCode:
            return 0

