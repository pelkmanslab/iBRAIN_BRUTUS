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

# check if iBRAIN actually ran, 
if [ ! -f $IBRAIN_LOG_PATH/$LOGFILENAME ]; then

    echo "iBRAIN produced no output. Please check your configuration."

#or if it was already running
elif [ $(cat $IBRAIN_LOG_PATH/$LOGFILENAME | grep "^Aborting:" | wc -l) -eq 0 ]; then

    # if it actually did a full run, execute script (on brutus) that does XML-fixing, and possibly url-fixing for PC
    $IBRAIN_BIN_PATH/sedTransformLogWeb.sed $IBRAIN_LOG_PATH/$LOGFILENAME > $IBRAIN_LOG_PATH/$LOGFILENAME_PC
    
    # or calculate directly on login-node
    xsltproc -o $IBRAIN_LOG_PATH/wrapper.html $IBRAIN_DATABASE_PATH/wrapper.xsl $IBRAIN_LOG_PATH/$LOGFILENAME_PC
    xsltproc -o $IBRAIN_LOG_PATH/home.html $IBRAIN_DATABASE_PATH/home.xsl $IBRAIN_LOG_PATH/$LOGFILENAME_PC

    # copy the sed transformed log file (XML fixing and URL parsing) and the HTML file to the public iBRIAN log directory
    cp $IBRAIN_LOG_PATH/$LOGFILENAME_PC $IBRAIN_DATABASE_PATH/wrapper_xml/$LOGFILENAME
    cp -f $IBRAIN_LOG_PATH/wrapper.html $IBRAIN_DATABASE_PATH/wrapper_xml/wrapper.html
    cp -f $IBRAIN_LOG_PATH/home.html $IBRAIN_DATABASE_PATH/wrapper_xml/home.html

else

    echo "iBRAIN is already running"

fi

# clean up log file
rm $IBRAIN_LOG_PATH/$LOGFILENAME 2>/dev/null
rm $IBRAIN_LOG_PATH/$LOGFILENAME_PC 2>/dev/null

exit 0

