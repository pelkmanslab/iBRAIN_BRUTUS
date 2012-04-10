#! /bin/sh

echo killing 15 running $1 jobs

RESUMEDCOUNTER=0;

for JOBID in $( bjobs -rw | grep "$1" | cut -c1-7 ); do

if [ $JOBID -eq $JOBID 2> /dev/null ]; then
#echo $JOBID

RESUMEDCOUNTER=$(( $RESUMEDCOUNTER + 1))

if [ $JOBID -gt 0 ] && [ $RESUMEDCOUNTER -lt 16 ]; then

bkill $JOBID

fi

fi
 
done
