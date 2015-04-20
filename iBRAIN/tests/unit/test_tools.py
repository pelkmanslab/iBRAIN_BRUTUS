'''
Testing brainy.process.code.* classes that help to submit custom user code.

Usage example:
    nosetests -vv -x --pdb test_customcode_processes
'''
import os
import shutil
from brainy_tests import MockPipesModule, BrainyTest


MOCK_LINKING_FILEPATH = os.path.join('..', 'mock', 'linking')


def bake_an_empty_filepattern_list_pipe():
    return MockPipesModule('''
{
    // Define iBRAIN pipe type
    "type": "CellProfiler.Pipe",
    // Define chain of processes
    "chain": [
        {
            "type": "Tools.LinkFiles",
            "source_location": "''' + MOCK_LINKING_FILEPATH + '''",
            "target_location": "{batch_path}",
            "file_patterns": {
                "hardlink": [],
                "symlink": []
            },
            "default_parameters": {
                "job_submission_queue": "8:00",
                "job_resubmission_queue": "36:00"
            }
        }
    ]
}
    \n''')


def bake_a_working_mock_pipe():
    return MockPipesModule('''
{
    // Define iBRAIN pipe type
    "type": "CellProfiler.Pipe",
    // Define chain of processes
    "chain": [
        {
            "type": "Tools.LinkFiles",
            "source_location": "{batch_path}_old",
            "target_location": "{batch_path}",
            "file_patterns": {
                "symlink": ["test_sym_linking*"],
                "hardlink": ["/^.*_hard_linking$/"]
            },
            "default_parameters": {
                "job_submission_queue": "8:00",
                "job_resubmission_queue": "36:00"
            }
        }
    ]
}
    \n''')


def bake_a_pipe_for_folder_linking():
    return MockPipesModule('''
{
    // Define iBRAIN pipe type
    "type": "CellProfiler.Pipe",
    // Define chain of processes
    "chain": [
        {
            "type": "Tools.LinkFiles",
            "source_location": "{process_path}",
            "target_location": "{plate_path}",
            "file_patterns": {
                "symlink": ["BATCH_*"]
            },
            "file_type": "d"
            //"recursively": 0
        }
    ]
}
    \n''')


class TestFileLinking(BrainyTest):

    def test_failing_pipe(self):
        '''Test LinkFiles: for failing if file pattern list is empty'''
        self.start_capturing_output()
        # Run pipes.
        pipes_module = bake_an_empty_filepattern_list_pipe()
        pipes_module.process_pipelines()
        # Check output.
        self.stop_capturing_output()
        #print self.captured_output
        assert 'warning' in self.captured_output

    def fetch_expected_files(self, pipes_module):
        batch_path = os.path.join(
            pipes_module._get_flag_prefix(),
            pipes_module.pipelines[0].name,
            'BATCH',
        )
        old_batch_path = batch_path + '_old'
        os.makedirs(old_batch_path)
        expected_files = ['test_hard_linking', 'test_sym_linking',
                          'test_sym_linking2']
        for src_file in expected_files:
            shutil.copy(
                os.path.join(MOCK_LINKING_FILEPATH, src_file),
                old_batch_path,
            )
        return (batch_path, old_batch_path, expected_files)

    def test_a_basic_linking(self):
        '''Test LinkFiles: for basic linking'''
        self.start_capturing_output()
        # Run pipes.
        pipes_module = bake_a_working_mock_pipe()
        # Do some mocking to make sure hard link is done on /tmp - same
        # file system.
        batch_path, old_batch_path, expected_files = \
            self.fetch_expected_files(pipes_module)
        # Run the pipes.
        pipes_module.process_pipelines()
        # Check output.
        self.stop_capturing_output()
        #print self.captured_output
        #print self.get_report_content()
        #assert False
        assert 'Linking ' in self.get_report_content()
        links = os.listdir(old_batch_path)
        assert all([(expected_file in links)
                   for expected_file in expected_files])
        # We want to test LinkFiles.has_data(). For this we just simulate
        # running pipes_module and attached pipeline with single tested
        # process type of interest, i.e. LinkFiles
        self.start_capturing_output()
        pipes_module.process_pipelines()
        self.stop_capturing_output()
        #print self.captured_output
        assert '<status action="pipes-mock-linkfiles">completed</status>'\
            in self.captured_output
        #assert False

    def test_folder_linking(self):
        '''Test LinkFiles: for folder linking'''
        self.start_capturing_output()
        # Run pipes.
        pipes_module = bake_a_pipe_for_folder_linking()
        # Do some mocking to make sure hard link is done on /tmp - same
        # file system.
        batch_path, old_batch_path, expected_files = \
            self.fetch_expected_files(pipes_module)
        sub_old = os.path.join(old_batch_path, 'BATCH_old')
        os.makedirs(sub_old)
        # Run the pipes.
        pipes_module.process_pipelines()
        # Check output.
        self.stop_capturing_output()
        #print self.captured_output
        #print self.get_report_content()
        #assert False
        assert 'Linking ' in self.get_report_content()
        result_link = os.path.join(pipes_module.env['plate_path'], 'BATCH_old')
        assert os.path.exists(result_link) and os.path.islink(result_link)
        #assert False

