import os
import re
from datetime import datetime
from xml.sax.saxutils import escape as escape_xml
#from plato.shell.findutils import (Match, find_files)
from fnmatch import fnmatch, translate as fntranslate
from os.path import basename

from brainy.process import BrainyProcess, BrainyProcessError
from brainy.pipes import BrainyPipe
from brainy.config import config

def get_timestamp_str():
    return datetime.now().strftime('%Y%m%d%H%M%S')

def get_cellprofiler2_path():
    print config['cellprofiler2_path']
    return os.path.join(config['cellprofiler2_path'], '')


class Pipe(BrainyPipe):
    '''
    CellProfiller 2.1 pipe includes steps like:
     - CreateJobBatches
     - SubmitJobs
     - MergeJobData
    '''


class CreateJobBatches(BrainyProcess):
    '''
    Run CellProfiller2 project (pipeline) with CreateBatchFiles module.
    Expecting to create BATCH/Batch_data.h5 file.
    '''

    @property
    def cp_pipeline_fnpattern(self):
        return self.description.get(
            'filename',
            'run_*.cppipe',
        )

    def get_cp_pipeline_path(self):
        filename_regex_obj = re.compile(fntranslate(
                                        self.cp_pipeline_fnpattern))
        cp_pipeline_files = [
            filename for filename in os.listdir(self.process_path)
            if filename_regex_obj.match(filename)
        ]
        if len(cp_pipeline_files) > 1:
            raise BrainyProcessError('More than one CP pipeline settings file'
                                     ' found matching: %s in %s' %
                                     (self.cp_pipeline_fnpattern,
                                      self.process_path))
        elif len(cp_pipeline_files) == 0:
            raise BrainyProcessError('No CP pipeline settings file'
                                     ' found matching: %s in %s' %
                                     (self.cp_pipeline_fnpattern,
                                      self.process_path))
        return os.path.join(self.process_path, cp_pipeline_files[0])

    def put_on(self):
        super(PreCluster, self).put_on()
        # Make sure those pathnames exists. Create if missing.
        if not os.path.exists(self.batch_path):
            os.makedirs(self.batch_path)
        if not os.path.exists(self.postanalysis_path):
            os.makedirs(self.postanalysis_path)
        if not os.path.exists(self.reports_path):
            os.makedirs(self.reports_path)

    def get_bash_code(self):
        '''
        Note that the interpreter call is included by
        self.submit_bash_code()
        '''
        python_code = '''

            '%(cp_pipeline_file)s'
        ''' % {
            'cp_pipeline_file': self.get_cp_pipeline_path(),
            'batch_path': self.batch_path,
            'tiff_path': self.tiff_path,
        }
        return python_code

    def submit(self):
        submission_result = self.submit_bash_job(self.get_bash_code())

        print('''
            <status action="%(step_name)s">submitting
            <output>%(submission_result)s</output>
            </status>
        ''' % {
            'step_name': self.step_name,
            'submission_result': escape_xml(submission_result),
        })

        self.set_flag('submitted')

    def resubmit(self):
        submission_result = self.submit_bash_job(self.get_bash_code(),
                                                 is_resubmitting=True)

        print('''
            <status action="%(step_name)s">resubmitting
            <output>%(resubmission_result)s</output>
            </status>
        ''' % {
            'step_name': self.step_name,
            'resubmission_result': escape_xml(resubmission_result),
        })

        self.set_flag('resubmitted')
        super(CreateJobBatches, self).resubmit()
