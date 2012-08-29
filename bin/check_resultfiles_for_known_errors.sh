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

for resultFile in $(ls $BATCHDIR/${RESULTFILESUFFIX}*.results -tr 2>/dev/null | tail -1); do
  #echo "$resultFile: "
  if ([ $(cat $resultFile | grep "TERM_RUNLIMIT" | wc -l ) -gt 0 ] ||
      [ $(cat $resultFile | grep "TERM_OWNER" | wc -l ) -gt 0 ] ||
      [ $(cat $resultFile | grep "TERM_ADMIN" | wc -l ) -gt 0 ] ||
      [ $(cat $resultFile | grep "Problem calling GhostScript" | wc -l ) -gt 0 ] ||
      [ $(cat $resultFile | grep "Opening log file:" | wc -l ) -gt 0 ] ||
      [ $(cat $resultFile | grep "Assertion detected at" | wc -l ) -gt 0 ] ||
      [ $(cat $resultFile | grep "matlab: command not found" | wc -l ) -gt 0 ] ||
      [ $(cat $resultFile | grep "License Manager Error" | wc -l ) -gt 0 ]);
  then
    if [ $(cat $resultFile | grep "TERM_RUNLIMIT" | wc -l ) -gt 0 ]; then
      echo "        [KNOWN ERROR FOUND]: Job exceeded runlimit, resetting job & placing timeout flag file"
      touch $(dirname $SUBMITTEDFILE)/$(basename $SUBMITTEDFILE .submitted).runlimit
    elif [ $(cat $resultFile | grep "TERM_OWNER" | wc -l ) -gt 0 ]; then
      echo "        [KNOWN ERROR FOUND]: Owner terminated job, resetting job"
    elif [ $(cat $resultFile | grep "TERM_ADMIN" | wc -l ) -gt 0 ]; then
      echo "        [KNOWN ERROR FOUND]: Administrator terminated job, resetting job"
    elif [ $(cat $resultFile | grep "License Manager Error" | wc -l ) -gt 0 ]; then
      echo "        [KNOWN ERROR FOUND]: Matlab License Magager Error, resetting job"
    elif [ $(cat $resultFile | grep "License Manager Error -15" | wc -l ) -gt 0 ]; then
      echo "        [KNOWN ERROR FOUND]: Matlab License Magager Error (-15), resetting job"
    elif [ $(cat $resultFile | grep "Problem calling GhostScript" | wc -l ) -gt 0 ]; then
      echo "        [KNOWN ERROR FOUND]: Problem calling GhostScript, resetting job"
    elif [ $(cat $resultFile | grep "matlab: command not found" | wc -l ) -gt 0 ]; then
      echo "        [KNOWN ERROR FOUND]: known environment error: matlab:command not found, resetting job"
    fi
    echo "          removing $resultFile"
    rm $resultFile
    if [ -e $SUBMITTEDFILE ]; then
      echo "          removing $SUBMITTEDFILE"
      rm $SUBMITTEDFILE
    fi
  elif [ $(cat $resultFile | grep -i -e "Error" | wc -l ) -gt 0 ]; then
    echo "<warning>"
    echo " Unknown error found in result file $(basename $resultFile)"
    echo "      <result_file>$resultFile</result_file>"
    echo "</warning>"
  else
  ### THERE IS NO 'ERROR' (KNOWN OR UNKNOWN) IN THE FILE...
    echo "      <warning>Strangely, no known or unknown errors were found. <result_file>$resultFile</result_file></warning>"
  fi
done
###

