import textwrap
from  brainy.utils import invoke, escape_xml
from brainy.pipes import BrainyPipe
from brainy.process.code import (BashCodeProcess, MatlabCodeProcess,
                                 PythonCodeProcess)
from brainy.process.decorator import (format_with_params,
                                      require_key_in_description)


class CustomPipe(BrainyPipe):
    '''
    CustomPipe is a stub to supervise running of custom user code processes.
    '''


class Submittable(object):
    '''
    Run a piece of custom code given by user in self.description[submit_call].
    '''

    @property
    @format_with_params
    @require_key_in_description
    def submit_call(self):
        'Main code to be submitted.'


class BashCall(BashCodeProcess, Submittable):
    '''Bake and call bash as a single job.'''

    def get_bash_code(self):
        return self.submit_call


class MatlabCall(MatlabCodeProcess, Submittable):
    '''Bake and call python as a single job.'''

    def get_matlab_code(self):
        return self.submit_call


class PythonCall(PythonCodeProcess, Submittable):
    '''Bake and call python as a single job.'''

    def get_python_code(self):
        return self.submit_call


# TODO: if process description contains map_call() call it to obtain
# a dictionary of submit_calls and keys. By default, map_call() prints
# JSON out, which is then parsed and processed.
# Approach to reduce is some what similar same set of keys should
# help generate reduce jobs.

class Map(object):
    pass


class Reduce(object):
    pass
