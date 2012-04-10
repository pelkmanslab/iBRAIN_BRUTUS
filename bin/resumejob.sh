#! /bin/sh

echo resuming all running suspended $1 jobs

for JOBID in $( bjobs -sw | grep "$1" | cut -c1-7 ); do

if [ $(($JOBID + 0)) -gt 0 ]; then

bresume $JOBID

fi

done
