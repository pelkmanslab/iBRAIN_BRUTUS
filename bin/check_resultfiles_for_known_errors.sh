#! /bin/sh

####################################
### RESULT FILE ERROR MANAGEMENT ###
####################################
### Loop over all result files, check for errors that should be retried.
### If found, also remove .submitted file to allow for retry
###
### If no result files are found, remove submitted file and retry (Is this safe?)
###

BATCHDIR=$1
RESULTFILESUFFIX=$2
SUBMITTEDFILE=$3

if [ ! -d $BATCHDIR ] ||
   [ ! "$RESULTFILESUFFIX" ] ||
   [ ! "$BATCHDIR" ] ||
   [ ! "$SUBMITTEDFILE" ]; then
  echo "  FAILED to check resultfile for known errors: incorrect input"
  echo "    BATCHDIR=$BATCHDIR"
  echo "    RESULTFILESUFFIX=$RESULTFILESUFFIX"
  echo "    SUBMITTEDFILE=$SUBMITTEDFILE"
  exit 1
fi

###  FOR DEBUG PURPOSES ONLY!
#  echo "    BATCHDIR=$BATCHDIR"
#  echo "    RESULTFILESUFFIX=$RESULTFILESUFFIX"
#  echo "    SUBMITTEDFILE=$SUBMITTEDFILE"
# echo $(find $BATCHDIR -maxdepth 1 -name "${RESULTFILESUFFIX}*.results")
###

ERRORCAUSE="[UNKNOWN]"
ERRORGREP=""
for resultFile in $(ls $BATCHDIR/${RESULTFILESUFFIX}*.results -tr 2>/dev/null | tail -1); do
  #echo "$resultFile: "
  if ([ $(cat $resultFile | grep "TERM_RUNLIMIT" | wc -l ) -gt 0 ] ||
      [ $(cat $resultFile | grep "TERM_OWNER" | wc -l ) -gt 0 ] ||
      [ $(cat $resultFile | grep "Problem calling GhostScript" | wc -l ) -gt 0 ] ||
      [ $(cat $resultFile | grep "Opening log file:" | wc -l ) -gt 0 ] ||
      [ $(cat $resultFile | grep "Assertion detected at" | wc -l ) -gt 0 ] ||
      [ $(cat $resultFile | grep "matlab: command not found" | wc -l ) -gt 0 ] ||
      [ $(cat $resultFile | grep "DISABLEDBYBEREND IMRESIZE" | wc -l ) -gt 0 ] ||
      [ $(cat $resultFile | grep "Undefined function or method " | wc -l ) -gt 0 ] ||
      [ $(cat $resultFile | grep "License Manager Error" | wc -l ) -gt 0 ]);
  then
    if ([ $(cat $resultFile | grep "TERM_RUNLIMIT" | wc -l ) -gt 0 ] ||
      [ $(cat $resultFile | grep "Out of memory. Type HELP MEMORY for your options" | wc -l ) -gt 0 ]); then
	if [ -e $(dirname $SUBMITTEDFILE)/$(basename $SUBMITTEDFILE .submitted).runlimit ]; then
		echo "<warning>"
    		echo " Error: Job  $(basename $resultFile) timed out too many times."
    		echo "      <result_file>$resultFile</result_file>"
    		echo "</warning>"
		return
                ERRORCAUSE="[KNOWN] Timed out too many times."
	else
		echo "        [KNOWN ERROR FOUND]: Job exceeded runlimit, resetting job and placing timeout flag file"
      		touch $(dirname $SUBMITTEDFILE)/$(basename $SUBMITTEDFILE .submitted).runlimit
                ERRORCAUSE="[KNOWN] Timed out; Trying in longer queue."
	fi
    elif [ $(cat $resultFile | grep "TERM_OWNER" | wc -l ) -gt 0 ]; then
      echo "        [KNOWN ERROR FOUND]: Owner terminated job, resetting job"
      ERRORCAUSE="[KNOWN] Owner terminated job"
    elif [ $(cat $resultFile | grep "License Manager Error" | wc -l ) -gt 0 ]; then
      echo "        [KNOWN ERROR FOUND]: Matlab License Manager Error, resetting job"
      ERRORCAUSE="[KNOWN] Matlab License Manager Error"
      ERRORGREP=$(cat $resultFile | grep -A2 "Matlab License Manager Error")
    elif [ $(cat $resultFile | grep "License Manager Error -15" | wc -l ) -gt 0 ]; then
      echo "        [KNOWN ERROR FOUND]: Matlab License Manager Error (-15), resetting job"
      ERRORCAUSE="[KNOWN] Matlab License Manager Error (-15)"
    elif [ $(cat $resultFile | grep "Problem calling GhostScript" | wc -l ) -gt 0 ]; then
      echo "        [KNOWN ERROR FOUND]: Problem calling GhostScript, resetting job"
      ERRORCAUSE="[KNOWN] Problem calling GhostScript"
    elif [ $(cat $resultFile | grep "Undefined function or method " | wc -l ) -gt 0 ]; then
      echo "        [KNOWN ERROR FOUND]: MATLAB: Undefined function or method ... missing function, which gets temporarily restarted"
      ERRORCAUSE="[KNOWN] MATLAB: Undefined function or method"
      ERRORGREP=$(cat $resultFile | grep -A2 "Undefined function or method ")
    elif [ $(cat $resultFile | grep "matlab: command not found" | wc -l ) -gt 0 ]; then
      echo "        [KNOWN ERROR FOUND]: known environment error: matlab:command not found, resetting job"
      ERRORCAUSE="[KNOWN] Environment error: Matlab command not found"
    fi
    echo "          removing $resultFile"
    rm $resultFile
    if [ -e $SUBMITTEDFILE ]; then
      echo "          removing $SUBMITTEDFILE"
      rm $SUBMITTEDFILE
    fi
    # We could create a little error-log that links to the file and reports the error-type, which could be shown on the main iBRAIN page.
  elif [ $(cat $resultFile | grep -i -e "Error" | wc -l ) -gt 0 ]; then
    echo "<warning>"
    echo " Unknown error found in result file $(basename $resultFile)"
    echo "      <result_file>$resultFile</result_file>"
    echo "</warning>"
    ERRORCAUSE="[UNKNOWN] Unknown error found"
    ERRORGREP=$(cat $resultFile | grep -A2 "Error")
  else
  ### THERE IS NO 'ERROR' (KNOWN OR UNKNOWN) IN THE FILE...
    echo "      <warning>Strangely, no known or unknown errors were found. <result_file>$resultFile</result_file></warning>"
    ERRORCAUSE="[UNKNOWN] No error found"
  fi

  # Append result file link and description to some log file
  ERRORLOG=~/iBRAIN_errorlog.xml # FIXME
  echo "<RESULTFILE>$resultFile</RESULTFILE><ERRORDESCRIPTION>$ERRORCAUSE</ERRORDESCRIPTION><ERRORTIME>$(date +'%Y%m%d%H%M')</ERRORTIME><ERRORGREP>$ERRORGREP</ERRORGREP>" >> $ERRORLOG
done
###


