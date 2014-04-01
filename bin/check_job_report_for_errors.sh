#!/bin/bash
# This script will call the routine as it is used by Brainy PIPES for error 
# checking.
REPORT_FILE_PATH=$1
BRAINYDIR="$(dirname "$(dirname "${BASH_SOURCE[0]}")")/lib/python"
python - <<PYTHON
# Import iBRAIN environment.
import sys
import os
sys.path = [os.path.abspath('$BRAINYDIR')] + sys.path
from brainy.errors import (check_report_file_for_errors, KnownError, 
                           UnknownError)

report_file_path = '$REPORT_FILE_PATH'
assert os.path.exists(report_file_path)
try:
	check_report_file_for_errors(report_file_path)
except KnownError as error:
	print 'KnownError message: %s \nDetails:\n%s' % (error.message, error.details)
except UnknownError as error:
	print 'UnknownError message: %s \nDetails:\n%s' % (error.message, error.details)

PYTHON
