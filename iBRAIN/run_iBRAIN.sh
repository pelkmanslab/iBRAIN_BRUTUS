#!/bin/bash

#############################################
### INCLUDE IBRAIN CONFIGURATION
if [ ! "$IBRAIN_ROOT" ]; then 
    IBRAIN_ROOT=$(dirname `readlink -m $0`)
fi
if [ -f $IBRAIN_ROOT/etc/config ]; then
    . $IBRAIN_ROOT/etc/config
else
    echo "Aborting $(basename $0) (missing configuration at $IBRAIN_ROOT/etc/config)"
    exit 1
fi


# note that sedTransformLogPc actually makes the XML valid, by removing erroneous/accidental XML outputted by bsub, such as the job id: "<1235523>" and queue "<ether.m>"

LOGFILENAME="$(date +"%y%m%d%H%M%S")"_wrapper_brutus.xml
LOGFILENAME_PC="$(date +"%y%m%d%H%M%S")"_wrapper_brutus_pc.xml

# run iBRAIN and store results locally

$IBRAIN_ROOT/iBRAIN.sh > $IBRAIN_LOG_PATH/$LOGFILENAME 2>&1

# generate HTML
. $IBRAIN_ROOT/core/scripts/gen_html.sh

# clean up log file
rm $IBRAIN_LOG_PATH/$LOGFILENAME 2>/dev/null
rm $IBRAIN_LOG_PATH/$LOGFILENAME_PC 2>/dev/null

exit 0

