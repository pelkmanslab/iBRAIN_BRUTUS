from brainy.scheduler.base import (SHORT_QUEUE, NORM_QUEUE, LONG_QUEUE,
                                   PENDING_STATE, RUNNING_STATE, DONE_STATE,
                                   JOB_STATES, BrainyScheduler)
import logging
logger = logging.getLogger(__name__)
from sh import ErrorReturnCode, grep, egrep, wc


class NoLsfSchedulerFound(Exception):
    '''No LSF scheduler'''


class Lsf(BrainyScheduler):

    def __init__(self):
        self.bsub = None
        self.bjobs = None
        self.__bjobs_cache = None
        self.bkill = None
        self.init_scheduling()
        self.states_map = {
            PENDING_STATE: 'PEND',
            RUNNING_STATE: 'RUN',
            DONE_STATE: 'DONE',
        }

    def init_scheduling(self):
        try:
            from sh import bjobs as _bjobs, bsub as _bsub, bkill as _bkill
            self.bsub = _bsub
            self.bjobs = _bjobs
            self.bkill = _bkill
        except ImportError:
            exception = NoLsfSchedulerFound('Failed to locate LSF commands '
                                            'like bjobs, bsub, bkill. Is LSF '
                                            'installed?')
            logger.warn(exception)

    def bjobs(self, *args, **kwds):
        if not self.__bjobs_cache:
            self.__bjobs_cache = self._bjobs(*args, **kwds)
        return self.__bjobs_cache

    def submit_job(self, shell_command, queue, report_file):
        '''Submit job using *bsub* command.'''
        return self.bsub(
            '-W', queue,
            '-o', report_file,
            shell_command,
        )

    def count_working_jobs(self, key):
        try:
            return int(wc(
                egrep(
                    grep(self.bjobs('-aw'), key),
                    '(RUN|PEND)'
                ), '-l'
            ))
        except ErrorReturnCode:
            return 0

    def list_jobs(self, states):
        assert all([(state in JOB_STATES) for state in states])
        lsf_states = None
        for state in states:
            if not lsf_states:
                lsf_states = self.states_map[state]
            else:
                lsf_states += '|%s' % self.states_map[state]
        try:
            return egrep(self.bjobs('-aw'), '(%s)' % lsf_states).split('\n')
        except ErrorReturnCode:
            # Return empty list
            return list()
