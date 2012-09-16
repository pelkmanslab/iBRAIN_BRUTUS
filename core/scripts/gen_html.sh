#!/bin/bash
#
# Use XSLT to generate HTML files from XML output 
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

