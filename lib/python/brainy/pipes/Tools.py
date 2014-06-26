import os
import re
import shutil
from datetime import datetime
from plato.shell.findutils import (Match, find_files)
from fnmatch import fnmatch, translate as fntranslate

import brainy
from brainy.process.code import PythonCodeProcess


KNOWN_MICROSCOPES = ['CV7K']


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

    def has_data(self):
        '''
        If backups folder is empty, it means no backup was done.
        '''
        previous_backups = find_files(
            path=self.backups_path,
            match=Match(filetype='directory', name='BATCH_*'),
            recursive=False,
        )
        for item in previous_backups:
            return True
        return False


def move_microscope_metadata(tiff_path, metadata_path):
    # Make sure folders exist.
    if not os.path.exists(tiff_path):
        raise IOError('TIFF path was not found: %s' % tiff_path)
    if not os.path.exists(metadata_path):
        raise IOError('METADATA path was not found: %s' % metadata_path)

    # Roll over possible types.
    for microscope_type in KNOWN_MICROSCOPES:
        print '<!-- Checking if %s meta data is present -->' % microscope_type
        microscope_metadata_path = os.path.join(metadata_path, microscope_type)
        if microscope_type == 'CV7K':
            masks = [
                'geometry_parameter.xml',
                'MeasurementData.mlf',
                'MeasurementDetail.mrf',
                # e.g.: 1038402001_Greiner_#781091.wpp
                '*.wpp',
                # e.g.: 140314_InSituGFP.mes
                '*.mes',
                # e.g.: 140324-pilot-GFP-InSitu-gfp.wpi
                '*.wpi',
                # e.g.: DC_Andor #1_CAM1.tif
                re.compile('DC_Andor\ \#.*_CAM\d\.(tif|png)$'),
                # e.g.: SC_BP445-45_40x_M10_CH01.tif
                re.compile('SC_BP.*CH.*\.(tif|png)$'),
            ]
            metadata_files = list()
            for mask in masks:
                metadata_files += list(find_files(
                    path=tiff_path,
                    match=Match(filetype='f', name=mask),
                ))
            if len(metadata_files) > 0:
                # Detected files for the microscope.
                if not os.path.exists(microscope_metadata_path):
                    os.mkdir(microscope_metadata_path)
                # Move files
                for metadata_file in metadata_files:
                    destination = os.path.join(
                        microscope_metadata_path,
                        os.path.basename(metadata_file),
                    )
                    print '<!-- Moving %s metadata: %s -&gt; %s -->' %\
                          (microscope_type, metadata_file, destination)
                    os.rename(metadata_file, destination)
