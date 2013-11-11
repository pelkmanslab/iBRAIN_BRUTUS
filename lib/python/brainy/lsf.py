from brainy.log import getBasicLogger
logger = getBasicLogger(__name__)


SHORT_QUEUE = '1:00'
NORM_QUEUE = '8:00'
LONG_QUEUE = '36:00'


class NoSchedulerFound(Exception):
    '''No LSF scheduler'''


class Lsf(object):

    def __init__(self):
        self.bsub = None
        self.bjobs = None
        self.__bjobs_cache = None
        self.bkill = None
        self.init_scheduling()

    def init_scheduling(self):
        try:
            from sh import bjobs as _bjobs, bsub as _bsub, bkill as _bkill
            self.bsub = _bsub
            self.bjobs = _bjobs
            self.bkill = _bkill
        except ImportError:
            exception = NoSchedulerFound('Failed to locate LSF commands like '
                                         'bjobs, bsub, bkill. Is LSF '
                                         'installed?')
            logger.warn(exception)

    def bjobs(self, *args, **kwds):
        if not self.__bjobs_cache:
            self.__bjobs_cache = self._bjobs(*args, **kwds)
        return self.__bjobs_cache
