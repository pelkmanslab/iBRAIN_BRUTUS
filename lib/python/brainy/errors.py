import re


class UnknownError(Exception):
    '''Unknown error found in iBRAIN job report'''


class KnownError(Exception):
    '''Known error found in iBRAIN job report'''

    def __init__(self, message, details=None):
        super(Exception, self).message = message
        self.details = details


class TermRunLimitError(KnownError):
    '''Job exceeded runlimit, resetting job and placing timeout flag file'''

# if [ $(cat $resultFile | grep "TERM_RUNLIMIT" | wc -l ) -gt 0 ]; then
#     if [ -e $(dirname $SUBMITTEDFILE)/$(basename $SUBMITTEDFILE .submitted).runlimit ]; then
#         echo "<warning>"
#             echo " Error: Job  $(basename $resultFile) timed out too many times."
#             echo "      <result_file>$resultFile</result_file>"
#             echo "</warning>"
#         return
#                 ERRORCAUSE="[KNOWN] Timed out too many times."

UNKNOWN_ERROR = re.compile('ERROR', re.IGNORECASE)


KNOWN_ERRORS = {
    # needle => explanation
    'TERM_RUNLIMIT': 'Timed out too many times',
    'TERM_OWNER': 'Owner terminated job',
    'License Manager Error': 'Matlab License Manager Error',
    'License Manager Error -15': 'Matlab License Manager Error',
    'Problem calling GhostScript': 'Problem calling GhostScript',
    'Undefined function or method': 'MATLAB: Undefined function or method',
    'matlab: command not found': 'Environment error: Matlab command not found',
}


def check_for_known_error(line):
    for error_token in KNOWN_ERRORS:
        if error_token in line:
            error_cause = KNOWN_ERRORS[error_token]
            if error_token == 'TERM_RUNLIMIT':
                raise TermRunLimitError('[KNOWN] %s' % error_cause)
            else:
                raise KnownError('[KNOWN] %s' % error_cause)
    # Empty error message <-> no error.
    return ''


def has_unknown_error(line):
    if UNKNOWN_ERROR.search(line):
        return True
    return False


def check_report_file_for_errors(report_filepath):
    report_text = open(report_filepath).readlines()
    for num, line in enumerate(report_text):
        try:
            check_for_known_error(line)
        except KnownError as error:
            error.details = report_text[num:]
            raise error
        if has_unknown_error(line):
            error = UnknownError('[UNKNOWN] Unknown error found')
            error.details = report_text[num:]
            raise error
