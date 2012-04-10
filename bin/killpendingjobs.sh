#! /bin/sh

echo prioritizing $1 jobs

for JOBID in $( bjobs -pw | grep "$1" | cut -c1-7 ); do

if [ $JOBID -eq $JOBID 2> /dev/null ]; then

bkill $JOBID

fi
 
done
