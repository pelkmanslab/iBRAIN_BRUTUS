#!/bin/bash

#############################################
### INCLUDE IBRAIN CONFIGURATION
export IBRAIN_ROOT=$(dirname `readlink -m $0`)/../mock/root
if [ -f $IBRAIN_ROOT/etc/config ]; then
    . $IBRAIN_ROOT/etc/config
else
    echo "Aborting $(basename $0) (missing configuration at $IBRAIN_ROOT/etc/config)"
    exit 1
fi

# Export variables into a closure enviroment of execute_script.sh.
export LOGFILENAME=test_wrapper.xml
export LOGFILENAME_PC=test_wrapper_pc.xml

# Put mock data into the log folder.
cp $IBRAIN_ROOT/../database/$LOGFILENAME $IBRAIN_LOG_PATH/$LOGFILENAME 

SCRIPT_NAME="$IBRAIN_ROOT/core/scripts/gen_html.sh"
. $IBRAIN_ROOT/core/scripts/execute_script.sh

echo "$STDOUT"
echo "$STDERR"

exit 0

