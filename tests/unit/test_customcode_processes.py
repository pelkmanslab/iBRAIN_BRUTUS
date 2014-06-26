'''
Testing brainy.process.code.* classes that help to submit custom user code.

Usage example:
    nosetests -vv -x --pdb test_customcode_processes
'''
import re
import os
from brainy_tests import MockPipesModule, BrainyTest


def bake_a_mock_pipe_with_no_param():
    return MockPipesModule('''
{
    // Define iBRAIN pipe type
    "type": "CellProfiler.Pipe",
    // Define chain of processes
    "chain": [
        {
            "type": "CustomCode.PythonCall",
            "default_parameters": {
                "job_submission_queue": "8:00",
                "job_resubmission_queue": "36:00",
                "batch_path": "../../BATCH"
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
            "type": "CustomCode.PythonCall",
            "submit_call": "print 'I am a mock custom call'",
            "default_parameters": {
                "job_submission_queue": "8:00",
                "job_resubmission_queue": "36:00",
                "batch_path": "../../BATCH"
            }
        }
    ]
}
    \n''')


class TestCustomCode(BrainyTest):

    def test_python_call_missing_param(self):
        '''Test PythonCall: for "missing parameter" error'''
        self.start_capturing_output()
        # Run pipes.
        pipes_module = bake_a_mock_pipe_with_no_param()
        pipes_module.process_pipelines()
        # Check output.
        self.stop_capturing_output()
        print self.captured_output
        assert 'Missing "submit_call" key in JSON descriptor' \
            in self.captured_output

    def test_a_basic_python_call(self):
        '''Test PythonCall: for basic submission'''
        self.start_capturing_output()
        # Run pipes.
        pipes_module = bake_a_working_mock_pipe()
        pipes_module.process_pipelines()
        # Check output.
        self.stop_capturing_output()
        #print self.captured_output
        match = re.search('^Report file is written to:\s*([^\s\<]+)',
                          self.captured_output, re.MULTILINE)
        report_file = match.group(1)
        assert os.path.exists(report_file)
        report_file_content = open(report_file).read()
        assert 'I am a mock custom call' in report_file_content

