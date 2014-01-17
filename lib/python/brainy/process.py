import os
import re
from datetime import datetime
from sh import ErrorReturnCode, grep, egrep, wc
from xml.sax.saxutils import escape as escape_xml

import pipette
from brainy.flags import FlagManager
from brainy.modules import invoke
from brainy.lsf import SHORT_QUEUE, NORM_QUEUE
from brainy.config import config
from brainy.errors import (UnknownError, KnownError, TermRunLimitError,
                           check_report_file_for_errors)


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

    def __init__(self, warning, output=''):
        self.warning = warning
        self.output = output


class BrainyProcess(pipette.Process, FlagManager):

    def __init__(self):
        super(BrainyProcess, self).__init__()
        self.pipes_module = None
        self.__reports = None
        self.__batch_listing = None
        self.job_report_exp = '%s_\d+.job_report' % self.step_name

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
            reports_regex = re.compile(self.job_report_exp)
            self.__reports = [filename for filename
                              in os.listdir(self.reports_path)
                              if reports_regex.search(filename)]
        return self.__reports

    def list_batch_dir(self):
        if self.__batch_listing is None:
            print('Listing batch folder. Please wait.. ')
            self.__batch_listing = list()
            for filename in os.listdir(self.batch_path):
                self.__batch_listing.append(
                    os.path.join(self.batch_path, filename))
            #     sys.stdout.write('.')
            # sys.stdout.write('\n')
            # sys.stdout.flush()
        return self.__batch_listing

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

    def has_job_reports(self):
        return self.job_reports_count > 0

    def working_jobs_count(self, needle=None):
        if needle is None:
            needle = os.path.dirname(self.reports_path)
        try:
            return int(wc(
                egrep(
                    grep(self.scheduler.bjobs('-aw'), needle),
                    '(RUN|PEND)'
                ), '-l'
            ))
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
                and self.working_jobs_count() == 0 \
                and self.has_job_reports() is False:
            return True
        return False

    def still_working(self):
        if (self.is_submitted or self.is_resubmitted) \
                and self.is_complete is False:
            return self.has_job_reports() is False \
                and self.working_jobs_count() > 0
        return False

    def has_data(self):
        '''
        Override this method to implement step specific data existence and
        integrity checks.
        '''
        #raise NotImplemented('Missing implementation for has_data() method.')
        return True

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
        for report_filename in self.get_job_reports():
            ## print report_filename
            report_filepath = os.path.join(self.reports_path, report_filename)
            try:
                check_report_file_for_errors(report_filepath)
            except TermRunLimitError as error:
                if os.path.exists(self.get_flag('runlimit')):
                    message = '''
                        Job %s timed out too many times.
                        <result_file>%s</result_file>
                    ''' % (report_filename, report_filepath)
                    raise BrainyProcessError(warning=message.strip(),
                                             output=error.details)
                else:
                    print '[KNOWN ERROR FOUND]: Job exceeded runlimit, ' \
                        'resetting job and placing timeout flag file'
                    self.set_flag('runlimit')
            except KnownError as error:
                print '[KNOWN ERROR FOUND]: %s' % error.message
                print 'Resetting ".submitted" flag and removing job report.'
                self.reset_submitted()
                self.unlink('report_filepath')
                raise BrainyProcessError(warning=error.message,
                                         output=error.details)
            except UnknownError as error:
                message = '''
                    Unknown error found in result file %s
                    <result_file>%s</result_file>
                ''' % (report_filename, report_filepath)
                raise BrainyProcessError(warning=message.strip(),
                                         output=error.details)
                # TODO: append error message to ~/iBRAIN_errorlog.xml

        # Finally, no errors were found.

    def run(self):
        ## print self.working_jobs_count()
        # Skip if ".complete" flag was found.
        if self.is_complete:
            self.results['step_status'] = 'completed'
        # Step is incomplete. Do we want to submit?
        elif self.want_to_submit():
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
            self.check_logs_for_errors()
            self.results['step_status'] = 'completed'
            self.set_flag('complete')

    def reduce(self):
        if self.results['step_status'] == 'completed':
            print('''
        <status action="%(step_name)s">completed</status>
            ''' % {'step_name': self.step_name})
