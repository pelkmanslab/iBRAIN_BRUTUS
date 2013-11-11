'''
iBRAINPipes is an integration of pipette processes into iBRAIN modules.
'''
import os
import pipette
from brainy.process import BrainyProcessError
from brainy.modules import BrainyModule


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

            # Makes sense only if the was no output
            # print('''
            #  <status action="%(step_name)s">passed
            #  </status>
            # ''' % {
            #     'step_name': step_name,
            # })
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
