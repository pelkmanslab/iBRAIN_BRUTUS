#! /bin/sh

echo resuming 15 $1 jobs

RESUMEDCOUNTER=0;

for JOBID in $( bjobs -sw | grep "$1" | cut -c1-7 ); do

if [ $JOBID -eq $JOBID 2> /dev/null ]; then
#echo $JOBID

RESUMEDCOUNTER=$(( $RESUMEDCOUNTER + 1))

if [ $JOBID -gt 0 ] && [ $RESUMEDCOUNTER -lt 16 ]; then

bresume $JOBID

fi

fi
 
done
