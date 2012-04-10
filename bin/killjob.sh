#! /bin/sh

echo killing all $1 jobs

for JOBID in $( bjobs -w | grep "$1" | cut -c1-7 ); do

if [ $(($JOBID + 0)) -gt 0 ]; then

bkill $JOBID

fi

done
