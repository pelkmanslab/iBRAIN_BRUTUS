import os
import re
import textwrap
from datetime import datetime
from xml.sax.saxutils import escape as escape_xml
#from plato.shell.findutils import (Match, find_files)
from fnmatch import fnmatch, translate as fntranslate
from os.path import basename

import brainy
from brainy.process import BrainyProcess, BrainyProcessError
from brainy.pipes import BrainyPipe
from brainy.config import config


def get_timestamp_str():
    return datetime.now().strftime('%Y%m%d%H%M%S')


def get_cp2_call():
    return '%s %s' % (
        config['python_cmd'],
        os.path.join(os.path.expanduser(config['cellprofiler2_path']),
                     'CellProfiler.py'),
    )


def create_imagelists_for_batching(tiff_path, batch_path,
                                   image_list_settings_filename):
    ''' Create CSV input image lists'''
    from brainy.apps.cellprofiler import CellProfilerImages

    images_path = tiff_path
    output_path = os.path.join(batch_path, 'IMAGE_LISTS')
    if os.path.exists(batch_path)\
            and not os.path.exists(output_path):
        os.makedirs(output_path)
    image_list_settings_filename = image_list_settings_filename

    cpimages = CellProfilerImages()
    if os.path.exists(image_list_settings_filename):
        # Load custom JSON settings file
        cpimages.parse_settings(image_list_settings_filename)
    cpimages.split_images(images_path, output_path)
    num_of_image_sets = cpimages.set_num

    if num_of_image_sets == 0:
        print 'Error, splitting of images failed. No image set were '\
              'generated.'
        exit(1)

    return cpimages


def run_cp2_pipeline_batch(tiff_path, batch_path, cp_pipeline_file,
                           csv_filepath):
    '''
    Execute CellProfiller2 in process in a command line. Pass arguments
    sufficient to process a single batch of images.
    '''
    command_lines = textwrap.wrap('''
    %(cp2_call)s -b -c -i %(tiff_path)s -o %(batch_path)s \
        --do-not-build --do-not-fetch --pipeline=%(cp_pipeline_file)s \
        --data-file=%(csv_filepath)s -L INFO
    ''' % {
        'cp2_call': get_cp2_call(),
        'tiff_path': tiff_path,
        'batch_path': batch_path,
        'cp_pipeline_file': cp_pipeline_file,
        'csv_filepath': csv_filepath,
    }, width=210, break_on_hyphens=False, break_long_words=False)
    command = ' \\\n'.join(command_lines)
    print command
    return brainy.invoke(command)


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
        super(CreateJobBatches, self).put_on()
        # Make sure those pathnames exists. Create if missing.
        if not os.path.exists(self.batch_path):
            os.makedirs(self.batch_path)
        if not os.path.exists(self.postanalysis_path):
            os.makedirs(self.postanalysis_path)
        if not os.path.exists(self.reports_path):
            os.makedirs(self.reports_path)

    def get_python_code(self):
        '''
        Note that the interpreter call is included by
        self.submit_python_code()
        '''
        code = '''
        # Import iBRAIN environment.
        import ext_path
        from brainy.pipes.CellProfiler2 import (
            create_imagelists_for_batching,
            run_cp2_pipeline_batch)

        cpimages = create_imagelists_for_batching(
            '%(tiff_path)s',
            '%(batch_path)s',
            '%(image_list_settings_filename)s',
        )

        # Test pipeline by running first batch of images
        output = run_cp2_pipeline_batch(
            '%(tiff_path)s',
            '%(batch_path)s',
            '%(cp_pipeline_file)s',
            # Pick first set of images for this test run.
            csv_filepath=cpimages.saved_csv_files[0],
        )
        # TODO: check output for any errors or exceptions raised.
        # But do it rather in has_data().
        print output
        ''' % {
            'tiff_path': self.tiff_path,
            'batch_path': self.batch_path,
            'image_list_settings_filename': self.description.get(
                'image_list_settings_filename',
                '',
            ),
            'cp_pipeline_file': self.get_cp_pipeline_path(),
        }
        return code

    def submit(self):
        submission_result = self.submit_python_job(self.get_python_code())

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
        submission_result = self.submit_python_job(self.get_python_code(),
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
