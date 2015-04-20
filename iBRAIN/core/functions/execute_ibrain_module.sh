#! /bin/bash
#
# execute_ibrain_module.sh

# execute_ibrain_module is the standard function called at the end of iBRAIN modules that have a "main" function.
# It does basic BASH error handling & reporting, and imporves robustness to crashes from individual modules by
# escaping their XML output.
function execute_ibrain_module {

	echo "<!-- executing module function"
	ERRORLOG=$(mktemp)
	MODULEOUT=$( main 2> $ERRORLOG )
	MODULEEXITCODE=$?
	MODULERR="$( cat $ERRORLOG )"
	rm $ERRORLOG
	echo "end of module function -->"

    # We can ignore certain errors,  such as "MATLAB job.", which our cluster throws upon submission of a matlab job :)
    MODULERR=$(echo "$MODULERR" | sed -e "s/MATLAB job.//g")
    MODULERR=$(echo "$MODULERR" | sed -e "s/Generic job.//g")
    MODULERR=$(echo "$MODULERR" | ${IBRAIN_BIN_PATH}/escape_xml.py )
    #MODULERR=$(echo "$MODULERR" | sed -e "s/ //g")

	if [ "$MODULERR" ]; then
        # We can check if despite the error the module still produced valid xml. If so, just show the module xml, otherwise, revert to error-message
        MODULEXMLVALIDATION=$(echo $MODULEOUT | xmllint --noout - 2>&1)
        if [ "$MODULEXMLVALIDATION" ]; then
            echo "     <status action=\"${MODULENAME}\">failed"
            echo "      <warning>"
            echo "    iBRAIN module \"${MODULEPATH}\" had a bash error that resulted in invalid XML. The error message is as follows: \"${MODULERR}\""
            echo "      </warning>"
            echo "      <output>"
            # print output while escaping reserved xml characters
            echo $(echo ${MODULEOUT} | sed -e 's~&~\&amp;~g' -e 's~<~\&lt;~g' -e  's~>~\&gt;~g' -e 's~--~\-~g')
            echo "      </output>"
            echo "     </status>"
        else
            # As the xml was still valid, we will just show that and ignore the error. Error does get logged to errorlog.xml though.
            echo "${MODULEOUT}"
        fi
        # Append result file link and description to some log file
        echo "<MODULEFILE>$MODULEPATH</MODULEFILE><ERRORDESCRIPTION>$MODULERR</ERRORDESCRIPTION><ERRORTIME>$(date +'%Y%m%d%H%M')</ERRORTIME><MODULEOUT>$(echo ${MODULEOUT} | sed -e 's~&~\&amp;~g' -e 's~<~\&lt;~g' -e  's~>~\&gt;~g' -e 's~--~\-~g')</MODULEOUT>" >> $IBRAIN_DATABASE_PATH/errorlog.xml
	else
	    echo "${MODULEOUT}"
	fi
}
