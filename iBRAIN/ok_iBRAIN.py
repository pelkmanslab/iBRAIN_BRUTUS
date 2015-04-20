#!/usr/bin/python
'''
Realization of special "ok iBRAIN" interface - a more flexible support
for controlling and monitoring projects.


'''
import os
import sys
from ext_path import get_root_path
import brainy.modules
import argparse
from pprint import pformat


brainy.modules.IBRAIN_ROOT = get_root_path(
    os.path.abspath(__file__), 'root', readlink=False)
config = brainy.get_config()


VERBOSE = False

INTRO = '''
Hi, I am an "ok iBRAIN" interface.

You can ask me about your project and I can help you to control and monitor it
better.

TIP: you can start with creating an empty file saying help.

  cd ok
  touch help

Other examples are:

  cd ok
  echo list_jobs > help

iBRAIN will respond by creating a file called "ok_help" providing more info.

More examples:

You can try another command:

  cd ok
  touch list_jobs

iBRAIN will respond by creating a file called ok_job_list containing info about
currently running jobs for this project.

'''.lstrip()


class OkCommand(object):

    def __init__(self, request, response):
        self.request = request
        self.response = response

    def is_requested(self, ok_path):
        request_path = os.path.join(ok_path, self.response)
        return os.path.exists(request_path)

    def reply(self, ok_path):
        request_path = os.path.join(ok_path, self.request)
        result = self.run(request_path)
        os.unlink(request_path)
        reponse_path = os.path.join(ok_path, self.response)
        reponse = open(reponse_path, 'w+')
        reponse.write(result)
        reponse.close()

    def __repr__(self):
        return self.request


class HelpCommand(OkCommand):

    def __init__(self):
        OkCommand.__init__(self, 'help', 'ok_help')

    def run(self, request_path):
        return '''
Type help command, to get detailed info on any command from the list.

  help list_jobs
  help kill_jobs

'''


class ListJobsCommand(OkCommand):

    def __init__(self):
        OkCommand.__init__(self, 'list_jobs', 'ok_job_list')

    def run(self, request_path):
        result = 'Currently running jobs are: '
        return result


class KillJobsCommand(OkCommand):

    def __init__(self):
        OkCommand.__init__(self, 'kill_jobs', 'ok_job_killed')

    def run(self, request_path):
        result = 'The following jobs were killed: '
        return result


class ProjectScanner(object):

    def __init__(self):
        self.__project_pathnames = None
        # Init commands
        command_list = list()
        command_list.append(HelpCommand())
        command_list.append(ListJobsCommand())
        command_list.append(KillJobsCommand())
        self.commands = dict()
        for command in command_list:
            self.commands[repr(command)] = command

    @property
    def project_pathnames(self):
        if self.__project_pathnames is None:
            pathnames_config = os.path.join(config['etc_path'], 'paths.txt')
            project_pathnames = [project_path.strip() for project_path
                                 in open(pathnames_config).readlines()]
            self.__project_pathnames = [project_path for project_path
                                        in project_pathnames
                                        if len(project_path) > 0
                                        and os.path.isdir(project_path)]
        return self.__project_pathnames

    def respond(self, ok_path):
        ok_files = os.listdir(ok_path)
        if len(ok_files) == 0:
            intro_filename = os.path.join(ok_path, 'Hello')
            with open(intro_filename, 'w+') as intro:
                intro.write(INTRO)
        else:
            for ok_file in ok_files:
                if not ok_file in self.commands:
                    continue
                command = self.commands[ok_file]
                command.reply(ok_path)

    def scan(self):
        for project_path in self.project_pathnames:
            ok_path = os.path.join(project_path, 'ok')
            if not os.path.exists(ok_path):
                continue
            self.respond(ok_path)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='ok IBRAIN',
                                     epilog='Example: ./ok_iBRAIN.py --scan')

    parser.add_argument('-v', '--verbose', dest='verbose',
                        action='store_true', help='Verbose mode')

    parser.add_argument('-s', '--scan', dest='scan',
                        action='store_true',
                        help='Manual or crontab call to scan projects and'
                        ' respond')

    args = parser.parse_args()

    if args.verbose:
        VERBOSE = True

    if args.scan:
        ProjectScanner().scan()
    else:
        sys.stderr.write('Nothing to do.. quiting.\n')
