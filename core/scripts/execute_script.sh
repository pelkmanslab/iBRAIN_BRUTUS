#! /bin/bash	
#
# execute_script.sh execute this file in order to put content of standard output
# and error descriptors into respective variables $STDOUT and $STDERR.

if [ ! "$SCRIPT_NAME" ]; then
    echo "SCRIPT_NAME variable is not defined" > /dev/stderr
    exit 1
fi

# Clear previous variables (to avoid potential conflicts).
unset STDOUT
unset STDERR
unset EXITCODE

# Wrap arround the invocation and capture STDOUT and STDERR.
ERRORLOG=$(mktemp)
export STDOUT=$( $SCRIPT_NAME 2> $ERRORLOG)
export EXITCODE=$?
export STDERR=$(cat $ERRORLOG )
rm $ERRORLOG
unset ERRORLOG
unset SCRIPT_NAME

