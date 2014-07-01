import os
import re
import shutil
from datetime import datetime
from findtools.find_files import (find_files, Match, MatchPatterns)
from fnmatch import fnmatch, translate as fntranslate
from brainy.process import BrainyProcessError
from brainy.process.code import PythonCodeProcess
from brainy.process.decorator import (format_with_params,
    require_keys_in_description, require_key_in_description)


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


@require_keys_in_description('file_patterns')
class LinkFiles(PythonCodeProcess):
    '''
    Symlink or hardlink files using relative path to the current process_path.
    '''

    @property
    @format_with_params
    @require_key_in_description
    def source_location():
        pass

    @property
    @format_with_params
    @require_key_in_description
    def target_location():
        pass

    def put_on(self):
        super(LinkFiles, self).put_on()
        # Create missing process folder path.
        if not os.path.exists(self.batch_path):
            os.makedirs(self.batch_path)

    @staticmethod
    def link(source_path, target_path, patterns, link_type='hard'):
        '''
        Expect keys 'hardlink' and 'symlink' keys in
        description['file_patterns']. If pattern string starts and ends with
        '/' then it is a regexp, otherwise it is fnmatch.
        '''
        assert os.path.exists(source_path)
        assert os.path.exists(target_path)
        file_matches = find_files(
            path=source_path,
            match=MatchPatterns(filetype='f', names=patterns),
        )
        if link_type == 'hardlink':
            make_link = os.link
        elif link_type == 'symlink':
            make_link = os.symlink
        else:
            raise IOError('Unsupported link type: %s' % link_type)
        for source_file in file_matches:
            link_path = os.path.join(target_path,
                                     os.path.basename(source_file))
            print 'Linking "%s" -> "%s"' % (source_file, link_path)
            make_link(source_file, link_path)

    @staticmethod
    def build_linking_args(source_location, target_location,
                           nested_file_patterns):
        for link_type in ['hardlink', 'symlink']:
            if link_type in nested_file_patterns:
                if type(nested_file_patterns[link_type]) != list \
                        or len(nested_file_patterns[link_type]) == 0:
                    raise BrainyProcessError(
                        warning='LinkFiles process requires a non empty list '
                                'of file patterns which can be match to '
                                'files in source_location.'
                    )
                args = {
                    'source_location': source_location,
                    'target_location': target_location,
                    'file_patterns': nested_file_patterns[link_type],
                    'link_type': link_type,
                }
                yield args

    def get_python_code(self):
        '''
        Note that the interpreter call is included by
        self.submit_python_code()
        '''
        assert 'hardlink' in self.file_patterns \
            or 'symlink' in self.file_patterns

        code = '''# Import iBRAIN environment.
import ext_path
from brainy.pipes.Tools import LinkFiles
'''

        for args in LinkFiles.build_linking_args(self.source_location,
                                                 self.target_location,
                                                 self.file_patterns):
            code += '''LinkFiles.link(
    '%(source_location)s',
    '%(target_location)s',
    %(file_patterns)s,
    link_type='%(link_type)s',
)
''' % args
        return code

    def has_data(self):
        '''
        Check if all files matching given patterns have been linked.
        '''
        print self.target_location
        if not os.path.exists(self.target_location):
            raise BrainyProcessError(warning='Expected target folder is not '
                                     'found: %s' % self.target_location)

        def get_name(root, name):
            return name

        for link_type in ['hardlink', 'symlink']:
            if link_type in self.file_patterns:
                patterns = self.file_patterns[link_type]
                source_matches = list(find_files(
                    path=self.source_location,
                    match=MatchPatterns(filetype='f', names=patterns),
                    collect=get_name,
                ))
                target_matches = list(find_files(
                    path=self.target_location,
                    match=MatchPatterns(filetype='f', names=patterns),
                    collect=get_name,
                ))
                if not source_matches == target_matches:
                    return False
        print 'you!'
        return True
