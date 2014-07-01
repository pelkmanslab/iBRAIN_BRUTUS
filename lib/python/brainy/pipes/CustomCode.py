import os
import sys
from xml.sax.saxutils import escape as escape_xml
import textwrap
import brainy
from brainy.utils import invoke
from brainy.pipes import BrainyPipe
from brainy.process.code import (BashCodeProcess, MatlabCodeProcess,
                                 PythonCodeProcess)


# TODO: if process description contains map_call() call it to obtain
# a dictionary of submit_calls and keys. By default, map_call() prints
# JSON out, which is then parsed and processed.
# Approach to reduce is some what similar same set of keys should
# help generate reduce jobs.


class CustomPipe(BrainyPipe):
    '''
    CustomPipe is a stub to supervise running of custom user code processes.
    '''


class PythonCall(PythonCodeProcess):
    '''Run a piece of custom code given by user .'''

    def get_python_call_stmt(self, call_type, call_stmt=None):
        '''
        Note that the interpreter call is included by
        self.submit_python_code().  We refer a required process description
        key called 'custom_code'.
        '''
        # Call type is expected to be a property.
        if call_stmt is None:
            call_stmt = getattr(self, call_type).__get__(self)
            call_stmt = call_stmt.format(self.parameters)
        code = '''
            # Import iBRAIN environment.
            import ext_path

            %s ''' % call_stmt
        return code

    def get_python_code(self):
        '''
        Bake code that would be actually submitted to run. Expected JSON field
        is *custom_code*.
        '''
        return self.get_python_call_stmt('submit_call')

    def has_data(self):
        '''
        Optionally call the method responsible for checking consistency of the
        data.
        '''
        if not 'check_data_call' in self.description:
            return
        output = invoke(self.get_python_call_stmt(
                        call_stmt=self.description['check_data_call']))
        if len(output.strip()) > 0:
            # Interpret any output as error.
            print '<!-- Checking data consistency failed: %s -->' % \
                  escape_xml(output)
            return False
        return True
