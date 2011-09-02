#! /bin/sh

echo prioritizing $1 jobs

for JOBID in $( bjobs -w | grep "$1" | cut -c1-7 ); do

if [ $(($JOBID + 0)) -gt 0 ]; then

# add to top of queue
btop $JOBID
# # set priority to 100 (default is 50)
# bmod -sp 99 $JOBID

fi

done
