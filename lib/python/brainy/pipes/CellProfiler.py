import os
import re
from xml.sax.saxutils import escape as escape_xml
#from plato.shell.findutils import (Match, find_files)
from fnmatch import fnmatch
from os.path import basename

from brainy.process import BrainyProcess, BrainyProcessError
from brainy.pipes import BrainyPipe


class Pipe(BrainyPipe):
    '''
    CellProfiller pipe includes steps like:
     - PreCluster
     - CPCluster
     - CPDataFusion
    '''


class PreCluster(BrainyProcess):
    '''Run CellProfiller with CreateBatchFiles module'''

    @property
    def cp_pipeline_fnpattern(self):
        return self.description.get(
            'filename',
            'PreCluster_*.mat',
        )

    def get_cp_pipeline_path(self):
        filename_regex_obj = re.compile(fnmatch.translate(
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

    def get_matlab_code(self):
        matlab_code = '''
        check_missing_images_in_folder('%(tiff_path)s');
        PreCluster_with_pipeline( ...
            '%(cp_pipeline_file)s','%(tiff_path)s','%(batch_path)s');
        ''' % {
            'cp_pipeline_file': self.get_cp_pipeline_path(),
            'batch_path': self.batch_path,
            'tiff_path': self.tiff_path,
        }
        return matlab_code

    def submit(self):
        matlab_code = self.get_matlab_code()
        submission_result = self.submit_matlab_job(matlab_code)

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
        matlab_code = self.get_matlab_code()
        resubmission_result = self.submit_matlab_job(matlab_code,
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


class CPCluster(BrainyProcess):
    '''Submit individual batches of CellProfiller as jobs and check results'''

    def __init__(self):
        super(CPCluster, self).__init__()
        self.__batch_files = None

    @property
    def batch_files(self):
        '''Get batch files for submission with CPCluster'''
        if self.__batch_files is None:
            batch_expr = re.compile('Batch_\d+_\d+.mat')
            self.__batch_files = [filename for filename
                                  in self.list_batch_dir()
                                  if batch_expr.search(basename(filename))]
        return self.__batch_files

    def put_on(self):
        super(CPCluster, self).put_on()

    def get_matlab_code(self, batch_filename):
        matlab_code = '''
            CPCluster('%(batchfile)s', '%(clusterfile)s')
        ''' % {
            'batchfile': os.path.join(self.batch_path, 'Batch_data.mat'),
            'clusterfile': batch_filename,
        }
        return matlab_code

    def submit(self):
        results = list()
        for batch_filename in self.batch_files:
            matlab_code = self.get_matlab_code(batch_filename)
            batch_report = batch_filename.replace('.mat', '.results')
            submission_result = self.submit_matlab_job(
                matlab_code,
                report_file=batch_report,
            )
            results.append(submission_result)

        if not results:
            raise BrainyProcessError(warning='Failed to find any batches.. '
                                     'check or restart previous step')

        print('''
            <status action="%(step_name)s">submitting (%(batch_count)d) batches..
            <output>%(submission_result)s</output>
            </status>
        ''' % {
            'step_name': self.step_name,
            'batch_count': len(results),
            'submission_result': escape_xml(str(results)),
        })

        self.set_flag('submitted')

    def resubmit(self):

        results = list()
        for batch_filename in self.batch_files:
            # TODO: resubmit only those files that have no data, i.e. failed
            # with no output.
            matlab_code = self.get_matlab_code(batch_filename)
            batch_report = batch_filename.replace('.mat', '.results')
            resubmission_result = self.submit_matlab_job(
                matlab_code,
                report_file=batch_report,
                is_resubmitting=True,
            )
            results.append(resubmission_result)

        if not results:
            raise BrainyProcessError(warning='Failed to find any batches.. '
                                     'check or restart previous step')

        print('''
            <status action="%(step_name)s">resubmitting (%(batch_count)d) batches..
            <output>%(resubmission_result)s</output>
            </status>
        ''' % {
            'step_name': self.step_name,
            'batch_count': len(results),
            'resubmission_result': escape_xml(str(results)),
        })

        self.set_flag('resubmitted')

    def has_data(self):
        '''Validate the integrity of precluster step'''
        expr = re.compile('Batch_(\d+_to_\d+)')
        parse_batch = lambda filename: expr.search(basename(filename)) \
            .group(1)
        output_batches = [parse_batch(filename) for filename
                          in self.list_batch_dir()
                          if fnmatch(basename(filename),
                                     'Batch_*_OUT.mat')]
        result_batches = dict(((parse_batch(filename), filename)
                              for filename in self.list_batch_dir()
                              if fnmatch(basename(filename),
                                         'Batch_*.results')))
        #print('Found %d job results logs vs. %d .MAT output files' %
        #      (len(result_batches), len(output_batches)))
        return len(result_batches) == len(output_batches)
