#! /bin/sh

echo killing running jobs from user $1

for JOBID in $( bjobs -rw | grep "$1" | cut -c1-7 ); do

if [ $JOBID -eq $JOBID 2> /dev/null ]; then

bkill $JOBID

fi
 
done
