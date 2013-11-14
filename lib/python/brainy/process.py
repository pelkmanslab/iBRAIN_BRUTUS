import os
import re
from datetime import datetime
from sh import ErrorReturnCode, grep, wc
from xml.sax.saxutils import escape as escape_xml

import pipette
from brainy.flags import FlagManager
from brainy.modules import invoke
from brainy.lsf import SHORT_QUEUE, NORM_QUEUE


NO_ERRORS_MSG = 'Strangely, no known errors were found.'
MATLAB_CALL = 'matlab -singleCompThread -nodisplay -nojvm'
PROCESS_STATUS = [
    'submitting',
    'waiting',
    'resubmitted',
    'reseted',
    'failed',
    'completed',
]


def format_code(code):
    result = ''
    for line in code.split('\n'):
        if len(line.strip()) == 0:
            continue
        result += line.strip() + '\n'
    return result


class BrainyProcessError(Exception):
    '''Logical error that happened while executing brainy pipe process'''


class BrainyProcess(pipette.Process, FlagManager):

    def __init__(self):
        super(BrainyProcess, self).__init__()
        self.pipes_module = None
        self.__reports = None

    @property
    def env(self):
        return self.parameters['pipes_module'].env

    @property
    def scheduler(self):
        return self.parameters['pipes_module'].scheduler

    @property
    def name(self):
        return self.parameters['name']

    @property
    def step_name(self):
        return self.parameters['step_name']

    @property
    def batch_size(self):
        return self.parameters.get('batch_size', '1')

    @property
    def process_path(self):
        return self.parameters['process_path']

    @property
    def reports_path(self):
        return self.parameters.get(
            'reports_path',
            os.path.join(self.process_path, 'REPORTS'),
        )

    @property
    def batch_path(self):
        return self.parameters.get(
            'batch_path',
            os.path.join(self.process_path, 'BATCH'),
        )

    @property
    def tiff_path(self):
        return self.parameters.get(
            'tiff_path',
            self.env['tiff_path'],
        )

    @property
    def postanalysis_path(self):
        return self.parameters.get(
            'postanalysis_path',
            self.env['postanalysis_path'],
        )

    @property
    def jpg_path(self):
        return self.parameters.get(
            'jpg_path',
            self.env['jpg_path'],
        )

    @property
    def plate_path(self):
        return self.parameters.get(
            'plate_path',
            self.env['plate_path'],
        )

    @property
    def job_submission_queue(self):
        return self.parameters.get(
            'job_submission_queue',
            SHORT_QUEUE,
        )

    @property
    def job_resubmission_queue(self):
        return self.parameters.get(
            'job_resubmission_queue',
            NORM_QUEUE,
        )

    @property
    def matlab_call(self):
        return self.parameters.get(
            'matlab_call',
            MATLAB_CALL,
        )

    def _get_flag_prefix(self):
        return os.path.join(self.process_path, self.name)

    def get_job_reports(self):
        if self.__reports is None:
            # Find result files only once.
            reports_regex = re.compile('%s_\d+.job_report' % self.name)
            self.__reports = [filename for filename
                              in os.listdir(self.reports_path)
                              if reports_regex.search(filename)]
        return self.__reports

    def submit_job(self, script, queue=None, report_file=None,
                   is_resubmitting=False):
        # Differentiate between submission and resubmission parameters.
        if is_resubmitting:
            if not queue:
                queue = self.job_submission_queue
        else:
            if not queue:
                queue = self.job_resubmission_queue
        # Form a unique report file path.
        if not report_file:
            report_file = os.path.join(
                self.reports_path, '%s_%s.job_report' %
                (self.name, datetime.now().strftime('%y%m%d%H%M%S')))
        return self.scheduler.bsub(
            '-W', queue,
            '-o', report_file,
            script,
        )

    def submit_matlab_job(self, matlab_code, queue=None, report_file=None,
                          is_resubmitting=False):
        script = '''
        %(matlab_call)s << MATLAB_CODE;
        %(matlab_code)s
        MATLAB_CODE''' % {
            'matlab_call': self.matlab_call,
            'matlab_code': matlab_code,
        }
        return self.submit_job(format_code(script), queue, report_file)

    @property
    def job_reports_count(self):
        return len(self.get_job_reports())

    def working_jobs_count(self, needle=None):
        if needle is None:
            needle = os.path.basename(self.reports_path)
        try:
            return int(wc(grep(self.scheduler.bjobs('-w'), needle), '-l'))
        except ErrorReturnCode:
            return 0

    def put_on(self):
        super(BrainyProcess, self).put_on()
        # Recreate missing process folder path.
        if not os.path.exists(self.process_path):
            os.makedirs(self.process_path)
        # Set status to
        self.results['step_status'] = 'submitting'

    def want_to_submit(self):
        if self.is_submitted is False and self.is_resubmitted is False \
                and self.is_complete is False:
            return True
        return False

    def no_work_is_happening(self):
        if (self.is_submitted or self.is_resubmitted) \
                and self.is_complete is False \
                and self.working_jobs_count() == 0:
            return True
        return False

    def still_working(self):
        if (self.is_submitted or self.is_resubmitted) \
                and self.is_complete is False:
            return self.has_job_reports() is False \
                and self.working_jobs_count() > 0
        return False

    def finished_work_but_has_no_data(self):
        if (self.is_submitted or self.is_resubmitted) \
                and self.is_complete is False:
            return self.has_job_reports() and not self.has_data()
        return False

    def report(self, message, warning=''):
        if warning:
            warning = '\n                <warning>%s</warning>' % warning
        print('''
        <status action="%(step_name)s">%(message)s%(warning)s
        </status>
        ''' % {
            'step_name': self.step_name,
            'message': escape_xml(message),
            'warning': warning,
        })

    def check_logs_for_errors(self):
        check_output = invoke(
            '%(IBRAIN_BIN_PATH)s/check_resultfiles_for_known_errors.sh '
            '%(BATCHDIR)s "CreateMIPs" $PROJECTDIR/CreateMIPs.resubmitted')

        if NO_ERRORS_MSG in check_output:
            return False

        print('''
            <status action="%(step_name)s">failed
              <warning>ALERT: FOUND ERRORS</warning>
              <output>
              %{check_errors}s
              </output>
            </status>
        ''' % {
            'step_name': self.step_name,
            'check_errors': escape_xml(check_output),
        })
        return True

    def run(self):
        # Do we want to submit?
        if self.want_to_submit():
            self.submit()
        # Submitted but no work has started yet?
        elif self.no_work_is_happening():
            self.report('resetting', warning='No work is happening')
            self.reset_submitted()
        # Waiting.
        elif self.still_working():
            self.report('waiting')
        # Resubmit if no data output but job results found.
        elif self.finished_work_but_has_no_data():
            self.resubmit()
        # Check for known errors if both data output and job results are
        # present.
        else:
            has_errors = self.check_logs_for_errors()
            if has_errors:
                raise BrainyProcessError()
            self.results['step_status'] = 'completed'

    def reduce(self):
        if self.results['step_status'] == 'completed':
            print('''
                <status action="%(step_name)s">completed</status>
            ''' % {'step_name': self.step_name})
            self.set_flag('complete')
