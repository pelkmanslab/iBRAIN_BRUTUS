#! /bin/sh

echo prioritizing $1 jobs

for JOBID in $( bjobs -w | grep "$1" | cut -c1-7 ); do

if [ $(($JOBID + 0)) -gt 0 ]; then

bbot $JOBID

fi

done
