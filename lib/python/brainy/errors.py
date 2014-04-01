import re


MAX_ERROR_MSG_SIZE = 1000


class UnknownError(Exception):
    '''Unknown error found in iBRAIN job report'''


class KnownError(Exception):
    '''Known error found in iBRAIN job report'''

    def __init__(self, message, details=None, error_type=None):
        super(KnownError, self).__init__(message)
        self.details = details
        self.type = error_type


class TermRunLimitError(KnownError):
    '''Job exceeded time limit, resetting job and placing timeout flag file.'''


class OutOfMemoryError(KnownError):
    '''
    Job exceeded memory limit, resetting job and placing timeout flag file.
    '''


UNKNOWN_ERROR = re.compile('ERROR', re.IGNORECASE)


KNOWN_ERRORS = {
    # type -> (needle, explanation)
    'out_of_time': {
        'token': 'TERM_RUNLIMIT',
        'cause': 'Timed out too many times',
    },
    'out_of_memory': {
        #'token': '"Out of memory. Type HELP MEMORY for your options."',
        'token': 'Out of memory.',
        'cause': 'Job exceeded memory limit',
    },
    'job_terminated': {
        'token': 'TERM_OWNER',
        'cause': 'Owner terminated job',
    },
    'no_license_1': {
        'token': 'License Manager Error',
        'cause': 'Matlab License Manager Error',
    },
    'no_license_2': {
        'token': 'License Manager Error -15',
        'cause': 'Matlab License Manager Error',
    },
    'ghostscript_call_failed': {
        'token': 'Problem calling GhostScript',
        'cause': 'Problem calling GhostScript',
    },
    'matlab_function_not_found': {
        'token': 'Undefined function or method',
        'cause': 'MATLAB: Undefined function or method',
    },
    'matlab_command_not_found': {
        'token': 'matlab: command not found',
        'cause': 'Environment error: Matlab command not found',
    },
}


def grab_details(text, token):
    start_pos = text.find(token)
    details_span = start_pos + MAX_ERROR_MSG_SIZE
    return text[start_pos:details_span]


def check_for_known_error(text):
    for error_type in KNOWN_ERRORS:
        error = KNOWN_ERRORS[error_type]
        if error['token'] in text:
            if error_type == 'out_of_time':
                raise TermRunLimitError(
                    '[KNOWN] %s' % error['cause'],
                    details=grab_details(text, error['token']),
                    error_type=error_type)
            elif error_type == 'out_of_memory':
                raise OutOfMemoryError(
                    '[KNOWN] %s' % error['cause'],
                    details=grab_details(text, error['token']),
                    error_type=error_type)
            else:
                raise KnownError(
                    '[KNOWN] %s' % error['cause'],
                    details=grab_details(text, error['token']),
                    error_type=error_type)
    # Empty error message <-> no error.
    return ''


def check_report_file_for_errors(report_filepath):
    report_text = open(report_filepath).read()
    try:
        check_for_known_error(report_text)
    except KnownError as error:
        raise
    # Has unknown error?
    match = UNKNOWN_ERROR.search(report_text)
    if not match:
        return
    error = UnknownError('[UNKNOWN] Unknown error found')
    error.details = grab_details(report_text, match.group(0))
    raise error
