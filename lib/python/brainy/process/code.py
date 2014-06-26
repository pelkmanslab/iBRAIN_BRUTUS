from xml.sax.saxutils import escape as escape_xml
from brainy.process import BrainyProcess
from brainy.process.decorator import require_keys_in_description


@require_keys_in_description('submit_call')
class CodeProcess(BrainyProcess):

    def __init__(self, code_language):
        BrainyProcess.__init__(self)
        self.code_language = code_language

    def submit(self):
        '''Default method for code submission'''
        submit_code_job = getattr(self, 'submit_%s_job' % self.code_language)
        get_code = getattr(self, 'get_%s_code' % self.code_language)

        submission_result = submit_code_job(get_code())

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
        submit_code_job = getattr(self, 'submit_%s_job' % self.code_language)
        get_code = getattr(self, 'get_%s_code' % self.code_language)

        resubmission_result = submit_code_job(get_code(), is_resubmitting=True)

        print('''
            <status action="%(step_name)s">resubmitting
            <output>%(resubmission_result)s</output>
            </status>
        ''' % {
            'step_name': self.step_name,
            'resubmission_result': escape_xml(resubmission_result),
        })

        self.set_flag('resubmitted')
        BrainyProcess.resubmit(self)


class BashCodeProcess(CodeProcess):

    def __init__(self):
        super(BashCodeProcess, self).__init__('bash')


class MatlabCodeProcess(CodeProcess):

    def __init__(self):
        CodeProcess.__init__(self, 'matlab')
        super(MatlabCodeProcess, self).__init__('matlab')


class PythonCodeProcess(CodeProcess):

    def __init__(self):
        super(PythonCodeProcess, self).__init__('python')
