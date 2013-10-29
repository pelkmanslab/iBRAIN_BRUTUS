'''
iBRAINPipes is an integration of pipette processes into iBRAIN modules.
'''
import os
import re
from brainy.flags import FlagManager
from brainy.modules import BrainyModule, invoke
from brainy.lsf import SHORT_QUEUE, NORM_QUEUE
import pipette
from datetime import datetime
from sh import ErrorReturnCode, grep, wc


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

    def report_waiting(self):
        print('''
        <status action="%(step_name)s">waiting
        </status>
        ''' % {
            'step_name': self.step_name
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
            'check_errors': check_output,
        })
        return True

    def run(self):
        # Do we want to submit?
        if self.want_to_submit():
            self.submit()
        # Submitted but no work has started yet?
        elif self.no_work_is_happening():
            self.reset_submitted()
        # Waiting.
        elif self.still_working():
            self.report_waiting()
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


class BrainyPipe(pipette.Pipe):

    def __init__(self, pipes_module, definition):
        super(BrainyPipe, self).__init__(definition)
        self.process_namespace = 'brainy.pipes'
        self.pipes_module = pipes_module

    def instantiate_process(self, process_description,
                            default_type=None):
        process = super(BrainyPipe, self).instantiate_process(
            process_description, default_type)
        process.name_prefix = self.name
        return process

    def get_step_name(self, process_name):
        return 'pipes-%s-%s' % (self.name, process_name)

    def execute_process(self, process, parameters):
        '''Add verbosity, e.g. report status using iBRAIN XML scheme'''
        step_name = self.get_step_name(process.name)
        parameters['pipes_module'] = self.pipes_module
        parameters['process_path'] = os.path.join(
            self.pipes_module._get_flag_prefix(),
            self.name,
        )
        parameters['step_name'] = step_name
        try:
            super(BrainyPipe, self).execute_process(process, parameters)

            print('''
             <status action="%(step_name)s">passed
             </status>
            ''' % {
                'step_name': step_name,
            })
        except BrainyProcessError as error:
            print('''
            <status action="%(step_name)s">failed
                <warning>ALERT: PIPES STEP FAILED</warning>
                <output>
                %(error_message)s
                </output>
            </status>
            ''' % {
                'step_name': step_name,
                'error_message': error.message,
            })


class PipesModule(BrainyModule):

    def __init__(self, name, env):
        BrainyModule.__init__(self, 'pipes', env)
        self.pipes_namespace = 'brainy.pipes'
        self.pipes_folder_files = [
            os.path.join(self.env['pipes_path'], filename)
            for filename in os.listdir(self.env['pipes_path'])
        ]
        self.__flag_prefix = self.env['pipes_path']
        self.__pipelines = None

    def _get_flag_prefix(self):
        return self.__flag_prefix

    def get_class(self, pipe_type):
        pipe_type = self.pipes_namespace + '.' + pipe_type
        module_name, class_name = pipe_type.rsplit('.', 1)
        module = __import__(module_name, {}, {}, [class_name])
        return getattr(module, class_name)

    @property
    def pipelines(self):
        if self.__pipelines is None:
            # Repopulate dictionary.
            pipes = dict()
            for definition_filename in self.pipes_folder_files:
                if not definition_filename.endswith('Pipe.json'):
                    continue
                definition = pipette.Pipe.parse_definition(definition_filename)
                cls = self.get_class(definition['type'])
                # Note that we pass itself as a pipes_module
                pipes[definition['name']] = cls(self, definition)
            self.__pipelines = self.sort_pipelines(pipes)
        return self.__pipelines

    def sort_pipelines(self, pipes):
        '''Reorder, tolerating declared dependencies found in definitions'''
        after_dag = dict()
        before_dag = dict()
        for depended_pipename in pipes:
            pipe = pipes[depended_pipename]
            if 'after' in pipe.definition:
                dependends_on = pipe.definition['after']
                if not dependends_on in after_dag:
                    after_dag[dependends_on] = list()
                after_dag[dependends_on].append(depended_pipename)
            if 'before' in pipe.definition:
                dependends_on = pipe.definition['before']
                if not dependends_on in before_dag:
                    before_dag[dependends_on] = list()
                before_dag[dependends_on].append(depended_pipename)

        def resolve_dependecy(name_a, name_b):
            # After
            if name_a in after_dag:
                if not name_b in after_dag:
                    # Second argument has no "after" dependencies.
                    if name_b in after_dag[name_a]:
                        return 1
                else:
                    # Second argument has "after" dependencies.
                    if name_b in after_dag[name_a] \
                            and name_a in after_dag[name_b]:
                        raise Exception('Recursive dependencies')
                    if name_b in after_dag[name_a]:
                        return 1
            if name_b in after_dag:
                if not name_a in after_dag:
                    # First argument has no "after" dependencies.
                    if name_a in after_dag[name_b]:
                        return -1
                else:
                    # First argument has "after" dependencies.
                    if name_a in after_dag[name_b] \
                            and name_b in after_dag[name_a]:
                        raise Exception('Recursive dependencies')
                    if name_a in after_dag[name_b]:
                        return -1
            # Before
            if name_a in before_dag:
                if not name_b in before_dag:
                    # Second argument has no "before" dependencies.
                    if name_b in before_dag[name_a]:
                        return 1
                else:
                    # Second argument has "before" dependencies.
                    if name_b in before_dag[name_a] \
                            and name_a in before_dag[name_b]:
                        raise Exception('Recursive dependencies')
                    if name_b in before_dag[name_a]:
                        return 1
            if name_b in after_dag:
                if not name_a in before_dag:
                    # First argument has no "before" dependencies.
                    if name_a in before_dag[name_b]:
                        return -1
                else:
                    # First argument has "before" dependencies.
                    if name_a in before_dag[name_b] \
                            and name_b in before_dag[name_a]:
                        raise Exception('Recursive dependencies')
                    if name_a in before_dag[name_b]:
                        return -1
            return 0

        pipenames = list(pipes.keys())
        sorted_pipenames = sorted(pipenames, cmp=resolve_dependecy)
        result = list()
        for pipename in sorted_pipenames:
            result.append(pipes[pipename])
        return result

    def process_pipelines(self):
        for pipeline in self.pipelines:
            self.execute_pipeline(pipeline)

    def execute_pipeline(self, pipeline):
        '''
        Execute passed pipeline process within the context of this
        PipesModule.
        '''
        pipeline.communicate()
