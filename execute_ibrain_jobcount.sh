#!/bin/bash

#############################################
### INCLUDE IBRAIN CONFIGURATION
IBRAIN_ROOT=$(dirname `readlink -m $0`)
if [ -f $IBRAIN_ROOT/etc/config ]; then
    . $IBRAIN_ROOT/etc/config
else
    echo "Aborting $(basename $0) (missing configuration at $IBRAIN_ROOT/etc/config)"
    exit 1
fi

#############################################
$iBRAIN_BIN_PATH/run_temp_parse_ibrain_jobcount.sh > /dev/null 2>&1

exit 0

