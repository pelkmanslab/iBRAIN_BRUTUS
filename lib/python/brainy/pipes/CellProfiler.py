import os
import re
import fnmatch
from brainy.pipes import BrainyProcess, BrainyPipe, BrainyProcessError


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
            'submission_result': submission_result,
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
            'resubmission_result': resubmission_result,
        })

        self.set_flag('resubmitted')
