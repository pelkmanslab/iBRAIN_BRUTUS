import os
import shutil
from datetime import datetime

import brainy
from brainy.process import PythonCodeProcess


def get_timestamp_str():
    return datetime.now().strftime('%Y%m%d%H%M%S')


def backup_batch_folder(batch_path, backups_path):
    '''Will recursively copy current BATCH to backups path'''
    # Make sure folders exist.
    if not os.path.exists(batch_path):
        raise IOError('BATCH path was not found: %s' % batch_path)
    if not os.path.exists(backups_path):
        raise IOError('BACKUPS path was not found: %s' % backups_path)

    # Making a backup copy.
    backuped_batch_path = os.path.join(backups_path,
                                       'BATCH_%s' % get_timestamp_str())
    if os.path.exists(backuped_batch_path):
        raise IOError('BACKUP destination already exists: %s' %
                      backuped_batch_path)
    # Note: the destination directory must not already exist.
    shutil.copytree(batch_path, backuped_batch_path)


class BackupPreviousBatch(PythonCodeProcess):
    '''Backup BATCH of the successful RUN of the CellProfiller'''

    @property
    def backups_path(self):
        return self.restrict_to_safe_path(self.parameters.get(
            'backups_path',
            os.path.join(self.process_path, 'BACKUPS'),
        ))

    def put_on(self):
        super(BackupPreviousBatch, self).put_on()
        # Recreate missing BACKUPS folder path.
        if not os.path.exists(self.backups_path):
            os.makedirs(self.backups_path)

    def get_python_code(self):
        '''
        Note that the interpreter call is included by
        self.submit_python_code()
        '''
        code = '''
        # Import iBRAIN environment.
        import ext_path
        from brainy.pipes.Tools import backup_batch_folder

        backup_batch_folder('%(batch_path)s', '%(backups_path)s')
        ''' % {
            'batch_path': self.batch_path,
            'backups_path': self.backups_path,
        }
        return code
