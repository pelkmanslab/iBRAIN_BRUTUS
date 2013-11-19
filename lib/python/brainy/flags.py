import os
from sh import touch


class FlagManager(object):

    def _get_flag_prefix(self):
        raise NotImplemented()

    @property
    def is_complete(self):
        return os.path.exists('%s.complete' % self._get_flag_prefix())

    @property
    def is_submitted(self):
        return os.path.exists('%s.submitted' % self._get_flag_prefix())

    @property
    def is_resubmitted(self):
        return os.path.exists('%s.submitted' % self._get_flag_prefix()) \
            and os.path.exists('%s.resubmitted' % self._get_flag_prefix())

    @property
    def has_runlimit(self):
        return os.path.exists('%s.runlimit' % self._get_flag_prefix())

    def reset_submitted(self):
        '''
        If no no jobs are found for this project, module, or step, waiting is
        senseless. Remove ".submitted" file and try again.
        '''
        self.reset_flag()

    def set_flag(self, flag='submitted'):
        flag = '.'.join((self._get_flag_prefix(), flag))
        touch(flag)

    def get_flag(self, flag='submitted'):
        return '%s.%s' % (self._get_flag_prefix(), flag)

    def reset_flag(self, flag='submitted'):
        flag_path = self.get_flag(flag)
        if not os.path.exists(flag_path):
            print('Failed to reset: "%s" flag not found.' % flag)
            return
        os.remove(flag_path)
